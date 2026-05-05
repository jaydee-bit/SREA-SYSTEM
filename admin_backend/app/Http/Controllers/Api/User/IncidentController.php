<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Models\Incident;
use Illuminate\Http\Request;

class IncidentController extends Controller
{
    // Create a new incident report
    public function store(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|string',
            'description' => 'required|string',
            'barangay' => 'required|string',
            'location_details' => 'nullable|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'address' => 'required|string',
            'persons_involved' => 'nullable|integer',
            'photo_path' => 'nullable|string',
        ]);

        $incident = Incident::create([
            'user_id' => $request->user()->id,
            'type' => $validated['type'],
            'description' => $validated['description'],
            'barangay' => $validated['barangay'],
            'location_details' => $validated['location_details'],
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'address' => $validated['address'],
            'persons_involved' => $validated['persons_involved'] ?? null,
            'photo_path' => $validated['photo_path'] ?? null,
            'status' => 'Pending',
            'reported_at' => now(),
        ]);

        return response()->json($incident, 201);
    }

    // Get the authenticated user's incidents
    public function myIncidents(Request $request)
    {
        $incidents = Incident::with('reporter')
            ->where('user_id', $request->user()->id)
            ->orderBy('reported_at', 'desc')
            ->get();

        return response()->json($incidents);
    }

    // Get a single incident by ID (for the current user)
    public function show(Request $request, $id)
    {
        $incident = Incident::with('reporter')
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json($incident);
    }
}
