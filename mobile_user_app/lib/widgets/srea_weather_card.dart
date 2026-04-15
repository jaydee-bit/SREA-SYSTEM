import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import '../services/weather_service.dart';

// ─────────────────────────────────────────────────────────────
// SreaWeatherCard — Live weather widget for home screen
//
// Usage:
// SreaWeatherCard(barangay: 'Brgy. Poblacion')
// ─────────────────────────────────────────────────────────────
class SreaWeatherCard extends StatefulWidget {
  final String barangay;

  const SreaWeatherCard({super.key, this.barangay = ''});

  @override
  State<SreaWeatherCard> createState() => _SreaWeatherCardState();
}

class _SreaWeatherCardState extends State<SreaWeatherCard> {
  WeatherData? _weather;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await WeatherService.fetchWeather(
        barangay: widget.barangay,
      );
      if (mounted) setState(() => _weather = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SreaColors.primaryDark, SreaColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: SreaRadius.card,
        boxShadow: [
          BoxShadow(
            color: SreaColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? _LoadingState()
          : _error != null
              ? _ErrorState(error: _error!, onRetry: _loadWeather)
              : _WeatherContent(weather: _weather!),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Loading state
// ─────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SreaSpacing.cardPadding,
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SreaColors.textOnPrimary,
            ),
          ),
          SizedBox(width: SreaSpacing.iconGap),
          Text(
            'Loading weather...',
            style: SreaText.bodySmall
                .copyWith(color: SreaColors.textOnPrimary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error state with retry button
// ─────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SreaSpacing.cardPadding,
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              color: SreaColors.textOnPrimary, size: 28),
          SizedBox(width: SreaSpacing.iconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather unavailable',
                  style: SreaText.bodySmall.copyWith(
                    color: SreaColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  error,
                  style: SreaText.label.copyWith(
                    color: SreaColors.bottomNavInactive,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded,
                color: SreaColors.textOnPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main weather content
// ─────────────────────────────────────────────────────────────
class _WeatherContent extends StatelessWidget {
  final WeatherData weather;

  const _WeatherContent({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row — location + weather icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: SreaText.titleLarge.copyWith(
                        color: SreaColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weather.province,
                      style: SreaText.bodySmall.copyWith(
                        color: SreaColors.bottomNavInactive,
                      ),
                    ),
                    if (weather.barangay.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: SreaColors.bottomNavInactive,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            weather.barangay,
                            style: SreaText.label.copyWith(
                              color: SreaColors.bottomNavInactive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Weather icon from OpenWeatherMap
              Image.network(
                weather.iconUrl,
                width: 64,
                height: 64,
                errorBuilder: (_, _, _) => Text(
                  weather.weatherEmoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),

          const SizedBox(height: 12),

          // Bottom row — temp + details
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Temperature
              Text(
                weather.tempDisplay,
                style: SreaText.headlineLarge.copyWith(
                  color: SreaColors.textOnPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                ),
              ),

              SizedBox(width: SreaSpacing.md),

              // Details — description, feels like, humidity
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.description,
                        style: SreaText.bodySmall.copyWith(
                          color: SreaColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        weather.feelsLikeDisplay,
                        style: SreaText.label.copyWith(
                          color: SreaColors.bottomNavInactive,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _WeatherDetail(
                            icon: Icons.water_drop_outlined,
                            value: '${weather.humidity}%',
                          ),
                          SizedBox(width: SreaSpacing.sm),
                          _WeatherDetail(
                            icon: Icons.air_outlined,
                            value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Weather alert strip (shown only for rain/storm)
          if (weather.alertLevel != 'none') ...[
            const SizedBox(height: 12),
            _WeatherAlertStrip(level: weather.alertLevel),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small weather detail chip (humidity, wind)
// ─────────────────────────────────────────────────────────────
class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String value;

  const _WeatherDetail({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: SreaColors.bottomNavInactive),
        const SizedBox(width: 3),
        Text(
          value,
          style: SreaText.label.copyWith(
            color: SreaColors.bottomNavInactive,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Weather alert strip for rain/storm conditions
// ─────────────────────────────────────────────────────────────
class _WeatherAlertStrip extends StatelessWidget {
  final String level;

  const _WeatherAlertStrip({required this.level});

  Color get _color {
    switch (level) {
      case 'critical':
        return SreaColors.critical;
      case 'high':
        return SreaColors.high;
      default:
        return SreaColors.medium;
    }
  }

  String get _message {
    switch (level) {
      case 'critical':
        return '⚠️ Severe weather — stay indoors';
      case 'high':
        return '🌧️ Heavy rain expected — take precautions';
      default:
        return '🌦️ Light rain — bring an umbrella';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: SreaRadius.input,
        border: Border.all(
          color: _color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: SreaSpacing.sm),
          Text(
            _message,
            style: SreaText.label.copyWith(
              color: SreaColors.textOnPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
