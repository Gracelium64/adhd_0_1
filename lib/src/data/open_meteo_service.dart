import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherSummary {
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final String date; // ISO date

  WeatherSummary({
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.date,
  });
}

class OpenMeteoService {
  OpenMeteoService._();
  static final OpenMeteoService instance = OpenMeteoService._();

  /// Fetch daily weather summary for given lat/lon and timezone for the date at index 0 (today).
  Future<WeatherSummary> fetchDailySummary({
    required double lat,
    required double lon,
    required String timezone,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'daily': 'weathercode,temperature_2m_max,temperature_2m_min',
      'timezone': timezone,
    });

    final resp = await http.get(uri).timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) {
      throw Exception('OpenMeteo error: ${resp.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(resp.body);
    if (data['daily'] == null) throw Exception('OpenMeteo: missing daily');
    final daily = data['daily'] as Map<String, dynamic>;
    final List<dynamic> codes = daily['weathercode'] ?? [];
    final List<dynamic> tmax = daily['temperature_2m_max'] ?? [];
    final List<dynamic> tmin = daily['temperature_2m_min'] ?? [];
    final List<dynamic> dates = daily['time'] ?? [];

    if (codes.isEmpty || tmax.isEmpty || tmin.isEmpty || dates.isEmpty) {
      throw Exception('OpenMeteo: incomplete daily arrays');
    }

    final int code =
        (codes[0] is int) ? codes[0] as int : int.parse(codes[0].toString());
    final double max =
        (tmax[0] is num)
            ? (tmax[0] as num).toDouble()
            : double.parse(tmax[0].toString());
    final double min =
        (tmin[0] is num)
            ? (tmin[0] as num).toDouble()
            : double.parse(tmin[0].toString());
    final String date = dates[0].toString();

    return WeatherSummary(
      weatherCode: code,
      maxTemp: max,
      minTemp: min,
      date: date,
    );
  }
}
