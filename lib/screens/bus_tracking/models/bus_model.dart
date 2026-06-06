class BusStop {
  final String name;
  final double latitude;
  final double longitude;

  BusStop({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory BusStop.fromMap(Map<String, dynamic> map) {
    return BusStop(
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BusRoute {
  final BusStop source;
  final BusStop destination;
  final List<BusStop> stops;

  BusRoute({
    required this.source,
    required this.destination,
    required this.stops,
  });

  Map<String, dynamic> toMap() {
    return {
      'source': source.toMap(),
      'destination': destination.toMap(),
      'stops': stops.map((x) => x.toMap()).toList(),
    };
  }

  factory BusRoute.fromMap(Map<String, dynamic> map) {
    return BusRoute(
      source: BusStop.fromMap(Map<String, dynamic>.from(map['source'] ?? {})),
      destination: BusStop.fromMap(Map<String, dynamic>.from(map['destination'] ?? {})),
      stops: (map['stops'] as List?)
              ?.map((x) => BusStop.fromMap(Map<String, dynamic>.from(x)))
              .toList() ??
          [],
    );
  }
}

class Bus {
  final String busId;
  final String busNumber;
  final String numberPlate;
  final String? busName;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final BusRoute route;

  Bus({
    required this.busId,
    required this.busNumber,
    required this.numberPlate,
    this.busName,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.route,
  });

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'busNumber': busNumber,
      'numberPlate': numberPlate,
      'busName': busName,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'route': route.toMap(),
    };
  }

  factory Bus.fromMap(Map<String, dynamic> map, String documentId) {
    return Bus(
      busId: documentId,
      busNumber: map['busNumber'] ?? '',
      numberPlate: map['numberPlate'] ?? '',
      busName: map['busName'],
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      route: BusRoute.fromMap(Map<String, dynamic>.from(map['route'] ?? {})),
    );
  }
}
