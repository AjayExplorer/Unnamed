import 'dart:math';
import 'package:intl/intl.dart';
import '../models/tracking_model.dart';

class RoutingService {
  // Haversine distance in kilometers
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Earth's radius in km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
        
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Calculate local ETA string (assumes 30 km/h average speed)
  static String calculateLocalETA(double distanceInKm) {
    if (distanceInKm < 0.05) return "Arrived";
    const double avgSpeedKmh = 30.0;
    final double hours = distanceInKm / avgSpeedKmh;
    final int minutes = (hours * 60).round();
    if (minutes <= 0) return "1 min";
    return "$minutes mins";
  }

  // Process route progress logic
  static BusTrackingState updateRouteProgress({
    required BusTrackingState currentState,
    required double busLat,
    required double busLng,
    required double speed,
  }) {
    List<RouteStopStatus> updatedStops = List.from(currentState.stopsStatus);
    String currentStopName = currentState.currentStop;
    String nextStopName = currentState.nextStop;
    
    // Check if the bus entered the 75 meters radius of any upcoming/current stop
    const double checkRadiusKm = 0.075; // 75 meters
    final String timeStr = DateFormat('hh:mm a').format(DateTime.now());

    int currentActiveIndex = -1;

    for (int i = 0; i < updatedStops.length; i++) {
      final stop = updatedStops[i];
      final distance = calculateDistance(busLat, busLng, stop.latitude, stop.longitude);
      
      if (distance <= checkRadiusKm) {
        // If the stop is not already marked as reached, we update it
        if (stop.status != 'reached') {
          updatedStops[i] = stop.copyWith(
            status: 'reached',
            arrivalTime: timeStr,
          );
        }
        currentActiveIndex = i;
      }
    }

    // Adjust states based on reached stops
    if (currentActiveIndex != -1) {
      currentStopName = updatedStops[currentActiveIndex].name;
      
      // Update other stop statuses to represent the proper sequence
      // All stops before the active index are 'reached'
      for (int i = 0; i < currentActiveIndex; i++) {
        if (updatedStops[i].status != 'reached') {
          updatedStops[i] = updatedStops[i].copyWith(
            status: 'reached',
            arrivalTime: updatedStops[i].arrivalTime ?? timeStr,
          );
        }
      }
      
      // The reached stop is marked as reached, now look for the next upcoming stop
      int nextIndex = currentActiveIndex + 1;
      if (nextIndex < updatedStops.length) {
        nextStopName = updatedStops[nextIndex].name;
        
        // Mark next stop status as 'current' for active targeting
        if (updatedStops[nextIndex].status == 'upcoming' || updatedStops[nextIndex].status == 'reached') {
          updatedStops[nextIndex] = updatedStops[nextIndex].copyWith(status: 'current');
        }
      } else {
        nextStopName = "Destination Reached";
      }
    }

    // Calculate distance and ETA to the next stop
    double distToNext = 0.0;
    String calculatedEta = "--";

    if (nextStopName != "Destination Reached") {
      final nextStopIndex = updatedStops.indexWhere((s) => s.name == nextStopName);
      if (nextStopIndex != -1) {
        final targetStop = updatedStops[nextStopIndex];
        distToNext = calculateDistance(busLat, busLng, targetStop.latitude, targetStop.longitude);
        calculatedEta = calculateLocalETA(distToNext);
      }
    }

    return BusTrackingState(
      busId: currentState.busId,
      driverId: currentState.driverId,
      latitude: busLat,
      longitude: busLng,
      currentSpeed: speed,
      timestamp: DateTime.now(),
      currentStop: currentStopName,
      nextStop: nextStopName,
      distanceToNextStop: distToNext,
      eta: calculatedEta,
      trackingActive: currentState.trackingActive,
      stopsStatus: updatedStops,
    );
  }
}
