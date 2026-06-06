import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnimatedBusMap extends StatefulWidget {
  final LatLng busLocation;
  final LatLng? studentLocation;
  final LatLng sourceLocation;
  final LatLng destinationLocation;
  final List<LatLng> stopLocations;
  final bool trackingActive;

  const AnimatedBusMap({
    super.key,
    required this.busLocation,
    this.studentLocation,
    required this.sourceLocation,
    required this.destinationLocation,
    required this.stopLocations,
    required this.trackingActive,
  });

  @override
  State<AnimatedBusMap> createState() => _AnimatedBusMapState();
}

class _AnimatedBusMapState extends State<AnimatedBusMap> with SingleTickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _animationController;
  LatLng? _prevBusLocation;
  LatLng _currentAnimatedLocation = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentAnimatedLocation = widget.busLocation;
    _prevBusLocation = widget.busLocation;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController.addListener(() {
      if (_prevBusLocation != null) {
        final double t = _animationController.value;
        final double lat = _prevBusLocation!.latitude + (widget.busLocation.latitude - _prevBusLocation!.latitude) * t;
        final double lng = _prevBusLocation!.longitude + (widget.busLocation.longitude - _prevBusLocation!.longitude) * t;
        
        setState(() {
          _currentAnimatedLocation = LatLng(lat, lng);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedBusMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.busLocation.latitude != widget.busLocation.latitude ||
        oldWidget.busLocation.longitude != widget.busLocation.longitude) {
      _prevBusLocation = _currentAnimatedLocation;
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnBus() {
    _mapController.move(_currentAnimatedLocation, 15.0);
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    // Generate polyline points
    final List<LatLng> polylinePoints = [
      widget.sourceLocation,
      ...widget.stopLocations,
      widget.destinationLocation,
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.busLocation,
            initialZoom: 14.0,
            maxZoom: 18.0,
            minZoom: 10.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.school.openpro',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: polylinePoints,
                  color: const Color(0xFF174EA6).withOpacity(0.8),
                  strokeWidth: 5.0,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                // Source Marker
                Marker(
                  point: widget.sourceLocation,
                  width: 32,
                  height: 32,
                  child: const Tooltip(
                    message: "Source",
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(Icons.play_circle_fill, color: Colors.green, size: 24),
                    ),
                  ),
                ),
                // Destination Marker
                Marker(
                  point: widget.destinationLocation,
                  width: 32,
                  height: 32,
                  child: const Tooltip(
                    message: "Destination",
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(Icons.stars, color: Colors.red, size: 24),
                    ),
                  ),
                ),
                // Stops Markers
                ...widget.stopLocations.map((stop) => Marker(
                      point: stop,
                      width: 24,
                      height: 24,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 12,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2F6BDA),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    )),
                // Student Marker
                if (widget.studentLocation != null)
                  Marker(
                    point: widget.studentLocation!,
                    width: 32,
                    height: 32,
                    child: Tooltip(
                      message: "My Location",
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.person_pin_circle, color: Colors.red, size: 20),
                        ),
                      ),
                    ),
                  ),
                // Bus Marker (with animated movements)
                Marker(
                  point: _currentAnimatedLocation,
                  width: 44,
                  height: 44,
                  child: widget.trackingActive
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981), // Emerald Green for Active as per palettes
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.directions_bus, color: Colors.white, size: 24),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.directions_bus_filled, color: Colors.white, size: 24),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
        // Overlay Zoom and Center Controls
        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            children: [
              // Center on Bus
              FloatingActionButton.small(
                heroTag: 'center_bus',
                onPressed: _centerOnBus,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF174EA6),
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 8),
              // Zoom In
              FloatingActionButton.small(
                heroTag: 'zoom_in',
                onPressed: _zoomIn,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF344054),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 4),
              // Zoom Out
              FloatingActionButton.small(
                heroTag: 'zoom_out',
                onPressed: _zoomOut,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF344054),
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
