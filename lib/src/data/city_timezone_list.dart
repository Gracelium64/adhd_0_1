// Curated representative cities (timezone / label / lat / lon)
// This is a compact list covering common timezones and capitals.
class CityInfo {
  final String timezone; // IANA timezone
  final String label; // human label matching Settings/WorldCapital labels
  final double lat;
  final double lon;
  const CityInfo(this.timezone, this.label, this.lat, this.lon);
}

const List<CityInfo> representativeCities = [
  CityInfo('Europe/Berlin', 'Berlin', 52.52, 13.4050),
  CityInfo('Europe/Paris', 'Paris', 48.8566, 2.3522),
  CityInfo('Europe/London', 'London', 51.5074, -0.1278),
  CityInfo('America/New_York', 'Washington', 38.9072, -77.0369),
  CityInfo('America/Sao_Paulo', 'Brasilia', -15.7939, -47.8828),
  CityInfo('America/Los_Angeles', 'Los Angeles', 34.0522, -118.2437),
  CityInfo('America/Chicago', 'Chicago', 41.8781, -87.6298),
  CityInfo('America/Denver', 'Denver', 39.7392, -104.9903),
  CityInfo('Asia/Tokyo', 'Tokyo', 35.6895, 139.6917),
  CityInfo('Asia/Shanghai', 'Beijing', 39.9042, 116.4074),
  CityInfo('Asia/Kolkata', 'New Delhi', 28.6139, 77.2090),
  CityInfo('Asia/Dubai', 'Dubai', 25.2048, 55.2708),
  CityInfo('Asia/Singapore', 'Singapore', 1.3521, 103.8198),
  CityInfo('Australia/Sydney', 'Sydney', -33.8688, 151.2093),
  CityInfo('Pacific/Auckland', 'Wellington', -41.2865, 174.7762),
  CityInfo('Africa/Cairo', 'Cairo', 30.0444, 31.2357),
  CityInfo('Africa/Johannesburg', 'Johannesburg', -26.2041, 28.0473),
  CityInfo('Africa/Lagos', 'Lagos', 6.5244, 3.3792),
  CityInfo('Pacific/Guadalcanal', 'Honiara', -9.4456, 159.9729),
  CityInfo('Pacific/Fiji', 'Suva', -18.1248, 178.4501),
  CityInfo('America/Anchorage', 'Anchorage', 61.2181, -149.9003),
  CityInfo('Atlantic/Reykjavik', 'Reykjavik', 64.1466, -21.9426),
  CityInfo('Europe/Moscow', 'Moscow', 55.7558, 37.6173),
  CityInfo('Asia/Seoul', 'Seoul', 37.5665, 126.9780),
];
