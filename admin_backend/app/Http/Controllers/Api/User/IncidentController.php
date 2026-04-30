<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Models\Incident;
use Illuminate\Http\Request;

class IncidentController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'type' => 'required|string',
            'description' => 'required|string',
            'photo_path' => 'nullable|string',
            'barangay' => 'required|string',
            'location_details' => 'nullable|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'address' => 'required|string',
            'persons_involved' => 'nullable|integer',
        ]);

        $incident = Incident::create([
            'user_id' => $request->user()->id,
            'type' => $request->type,
            'description' => $request->description,
            'photo_path' => $request->photo_path,
            'barangay' => $request->barangay,
            'location_details' => $request->location_details,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'address' => $request->address,
            'status' => 'Pending',
            'reported_at' => now(),
            'persons_involved' => $request->persons_involved,
        ]);

        return response()->json($incident, 201);
    }

    public function myIncidents(Request $request)
    {
        $incidents = Incident::where('user_id', $request->user()->id)
            ->orderBy('reported_at', 'desc')
            ->get();
        return response()->json($incidents);
    }

    public function show($id)
    {
        $incident = Incident::with(['reporter', 'assignedTo'])->findOrFail($id);
        return response()->json($incident);
    }
}