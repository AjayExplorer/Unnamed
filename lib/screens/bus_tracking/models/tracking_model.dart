import 'package:cloud_firestore/cloud_firestore.dart';

class RouteStopStatus {
  final String name;
  final double latitude;
  final double longitude;
  final String status; // 'reached', 'current', 'upcoming'
  final String? arrivalTime; // e.g. "09:45 AM" or null

  RouteStopStatus({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.arrivalTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'arrivalTime': arrivalTime,
    };
  }

  factory RouteStopStatus.fromMap(Map<String, dynamic> map) {
    return RouteStopStatus(
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'upcoming',
      arrivalTime: map['arrivalTime'],
    );
  }

  RouteStopStatus copyWith({
    String? status,
    String? arrivalTime,
  }) {
    return RouteStopStatus(
      name: name,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }
}

class BusTrackingState {
  final String busId;
  final String driverId;
  final double latitude;
  final double longitude;
  final double currentSpeed;
  final DateTime timestamp;
  final String currentStop;
  final String nextStop;
  final double distanceToNextStop;
  final String eta;
  final bool trackingActive;
  final List<RouteStopStatus> stopsStatus;

  BusTrackingState({
    required this.busId,
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.currentSpeed,
    required this.timestamp,
    required this.currentStop,
    required this.nextStop,
    required this.distanceToNextStop,
    required this.eta,
    required this.trackingActive,
    required this.stopsStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'currentSpeed': currentSpeed,
      'timestamp': Timestamp.fromDate(timestamp),
      'currentStop': currentStop,
      'nextStop': nextStop,
      'distanceToNextStop': distanceToNextStop,
      'eta': eta,
      'trackingActive': trackingActive,
      'stopsStatus': stopsStatus.map((x) => x.toMap()).toList(),
    };
  }

  factory BusTrackingState.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedTime;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else if (ts is String) {
      parsedTime = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return BusTrackingState(
      busId: documentId,
      driverId: map['driverId'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      currentSpeed: (map['currentSpeed'] as num?)?.toDouble() ?? 0.0,
      timestamp: parsedTime,
      currentStop: map['currentStop'] ?? '',
      nextStop: map['nextStop'] ?? '',
      distanceToNextStop: (map['distanceToNextStop'] as num?)?.toDouble() ?? 0.0,
      eta: map['eta'] ?? '',
      trackingActive: map['trackingActive'] ?? false,
      stopsStatus: (map['stopsStatus'] as List?)
              ?.map((x) => RouteStopStatus.fromMap(Map<String, dynamic>.from(x)))
              .toList() ??
          [],
    );
  }
}
