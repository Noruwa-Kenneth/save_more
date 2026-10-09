/// A selectable Nova Scotia location used for weather + recommendations.
class AppLocation {
  final String id;
  final String name;
  final String shortName;
  final double latitude;
  final double longitude;

  const AppLocation({
    required this.id,
    required this.name,
    required this.shortName,
    required this.latitude,
    required this.longitude,
  });

  /// Supported cities for PeakSaver NS (coordinates for Open-Meteo).
  static const List<AppLocation> all = [
    AppLocation(
      id: 'halifax',
      name: 'Halifax, Nova Scotia',
      shortName: 'Halifax',
      latitude: 44.6488,
      longitude: -63.5752,
    ),
    AppLocation(
      id: 'dartmouth',
      name: 'Dartmouth, Nova Scotia',
      shortName: 'Dartmouth',
      latitude: 44.6652,
      longitude: -63.5677,
    ),
    AppLocation(
      id: 'bedford',
      name: 'Bedford, Nova Scotia',
      shortName: 'Bedford',
      latitude: 44.7294,
      longitude: -63.6578,
    ),
    AppLocation(
      id: 'sydney',
      name: 'Sydney, Nova Scotia',
      shortName: 'Sydney',
      latitude: 46.1368,
      longitude: -60.1942,
    ),
    AppLocation(
      id: 'truro',
      name: 'Truro, Nova Scotia',
      shortName: 'Truro',
      latitude: 45.3652,
      longitude: -63.2796,
    ),
  ];

  static AppLocation get defaultLocation => all.first;

  static AppLocation byId(String id) {
    return all.firstWhere(
      (loc) => loc.id == id,
      orElse: () => defaultLocation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLocation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
