import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../request_letter/faculty/models/faculty_model.dart';
import '../models/bus_model.dart';
import '../models/tracking_model.dart';
import '../repositories/bus_tracking_repository.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';

class BusTrackingProvider extends ChangeNotifier {
  final BusTrackingRepository _repository = BusTrackingRepository();

  List<Faculty> _drivers = [];
  List<Bus> _buses = [];
  List<BusTrackingState> _allTrackingStates = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Driver details
  Faculty? _currentDriver;
  Bus? _assignedBus;
  BusTrackingState? _activeTrackingState;
  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<BusTrackingState?>? _activeTrackingSubscription;
  StreamSubscription<List<BusTrackingState>>? _allTrackingSubscription;
  bool _isTracking = false;
  String _gpsStatus = 'Inactive'; // 'Active', 'Inactive', 'Waiting'
  double _gpsAccuracy = 0.0;
  DateTime? _lastUpdateTime;

  // Student Search
  String _searchQuery = '';
  List<Bus> _matchingBuses = [];

  // Getters
  List<Faculty> get drivers => _drivers;
  List<Bus> get buses => _buses;
  List<BusTrackingState> get allTrackingStates => _allTrackingStates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Faculty? get currentDriver => _currentDriver;
  Bus? get assignedBus => _assignedBus;
  BusTrackingState? get activeTrackingState => _activeTrackingState;
  bool get isTracking => _isTracking;
  String get gpsStatus => _gpsStatus;
  double get gpsAccuracy => _gpsAccuracy;
  DateTime? get lastUpdateTime => _lastUpdateTime;

  String get searchQuery => _searchQuery;
  List<Bus> get matchingBuses => _matchingBuses;

  // --- Admin Methods ---

  Future<void> loadDrivers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _drivers = await _repository.getAllDrivers();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadBuses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _buses = await _repository.getAllBuses();
      _matchingBuses = List.from(_buses);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> registerDriver({
    required String name,
    required String phone,
    required String address,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final driverId = DateTime.now().millisecondsSinceEpoch.toString();
      final newDriver = Faculty(
        facultyId: driverId,
        name: name,
        designation: 'Bus Driver',
        department: 'Transport',
        username: username,
        password: password,
        phone: phone,
        email: '$username@school.com',
        availabilityStatus: 'Present',
        role: FacultyRole.driver,
        address: address,
      );
      await _repository.registerDriver(newDriver);
      await loadDrivers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerBus({
    required String busNumber,
    required String numberPlate,
    String? busName,
    required String driverId,
    required BusRoute route,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final driver = _drivers.firstWhere((d) => d.facultyId == driverId);
      final busId = DateTime.now().millisecondsSinceEpoch.toString();
      final newBus = Bus(
        busId: busId,
        busNumber: busNumber,
        numberPlate: numberPlate,
        busName: busName,
        driverId: driverId,
        driverName: driver.name,
        driverPhone: driver.phone,
        route: route,
      );
      await _repository.registerBus(newBus);
      await loadBuses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing driver's details
  Future<bool> updateDriver({
    required String driverId,
    required String name,
    required String phone,
    required String address,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateDriverProfile(driverId, {
        'name': name,
        'phone': phone,
        'address': address,
        'username': username,
        'password': password,
      });
      await loadDrivers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing bus
  Future<bool> updateBus({
    required String busId,
    required String busNumber,
    required String numberPlate,
    String? busName,
    required String driverId,
    required BusRoute route,
    String? previousDriverId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final driver = _drivers.firstWhere((d) => d.facultyId == driverId);
      final updatedBus = Bus(
        busId: busId,
        busNumber: busNumber,
        numberPlate: numberPlate,
        busName: busName,
        driverId: driverId,
        driverName: driver.name,
        driverPhone: driver.phone,
        route: route,
      );
      await _repository.updateBus(
        updatedBus,
        previousDriverId: previousDriverId,
      );
      await loadBuses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a bus
  Future<bool> deleteBus(String busId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteBus(busId);
      await loadBuses();
      await loadDrivers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Driver Actions ---

  Future<void> initializeDriver(Faculty driver) async {
    _currentDriver = driver;
    _gpsStatus = 'Inactive';
    _isTracking = false;
    _assignedBus = null;
    notifyListeners();
    try {
      await loadBuses();
      // Find assigned bus if exists
      final foundBuses = _buses
          .where((b) => b.driverId == driver.facultyId)
          .toList();
      if (foundBuses.isNotEmpty) {
        _assignedBus = foundBuses.first;
      } else if (driver.assignedBusId != null &&
          driver.assignedBusId!.isNotEmpty) {
        final matching = _buses
            .where((b) => b.busId == driver.assignedBusId)
            .toList();
        if (matching.isNotEmpty) {
          _assignedBus = matching.first;
        }
      }

      if (_assignedBus != null) {
        // Listen to their own tracking state doc
        _activeTrackingSubscription?.cancel();
        _activeTrackingSubscription = _repository
            .streamBusTracking(_assignedBus!.busId)
            .listen((state) {
              if (state != null) {
                _activeTrackingState = state;
                _isTracking = state.trackingActive;
                if (_isTracking && _gpsStatus == 'Waiting') {
                  _gpsStatus = 'Active';
                }
                notifyListeners();
              }
            });
      }
    } catch (e) {
      debugPrint('Driver initialization error: $e');
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    if (_currentDriver == null) return;
    try {
      await _repository.updateDriverProfile(_currentDriver!.facultyId, {
        'profilePhoto': photoUrl,
      });
      _currentDriver = Faculty(
        facultyId: _currentDriver!.facultyId,
        name: _currentDriver!.name,
        designation: _currentDriver!.designation,
        department: _currentDriver!.department,
        username: _currentDriver!.username,
        password: _currentDriver!.password,
        phone: _currentDriver!.phone,
        email: _currentDriver!.email,
        availabilityStatus: _currentDriver!.availabilityStatus,
        role: _currentDriver!.role,
        address: _currentDriver!.address,
        assignedBusId: _currentDriver!.assignedBusId,
        profilePhoto: photoUrl,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
    }
  }

  Future<bool> startTracking() async {
    if (_assignedBus == null || _assignedBus!.busId.isEmpty) return false;

    final hasPermission = await LocationService.handleLocationPermission();
    if (!hasPermission) {
      _errorMessage = 'GPS permission is required to start tracking.';
      notifyListeners();
      return false;
    }

    _gpsStatus = 'Waiting';
    _isTracking = true;
    notifyListeners();

    try {
      await _repository.setTrackingActive(_assignedBus!.busId, true);

      // Cancel existing gps subscription if any
      _gpsSubscription?.cancel();

      // Start listening to GPS stream
      _gpsSubscription = LocationService.getPositionStream().listen(
        (Position position) async {
          _gpsStatus = 'Active';
          _gpsAccuracy = position.accuracy;
          _lastUpdateTime = DateTime.now();

          if (_activeTrackingState != null) {
            final speedInKmh = position.speed * 3.6; // convert m/s to km/h

            // Compute stop logic and return new state
            final newState = RoutingService.updateRouteProgress(
              currentState: _activeTrackingState!,
              busLat: position.latitude,
              busLng: position.longitude,
              speed: speedInKmh,
            );

            await _repository.updateTrackingState(newState);
          } else {
            // If Firestore active state is null, fetch static route and create one
            final staticBus = await _repository.getBus(_assignedBus!.busId);
            if (staticBus != null) {
              final initialState = BusTrackingState(
                busId: staticBus.busId,
                driverId: staticBus.driverId,
                latitude: position.latitude,
                longitude: position.longitude,
                currentSpeed: position.speed * 3.6,
                timestamp: DateTime.now(),
                currentStop: staticBus.route.source.name,
                nextStop: staticBus.route.stops.isNotEmpty
                    ? staticBus.route.stops.first.name
                    : staticBus.route.destination.name,
                distanceToNextStop: 0.0,
                eta: '--',
                trackingActive: true,
                stopsStatus: [
                  RouteStopStatus(
                    name: staticBus.route.source.name,
                    latitude: staticBus.route.source.latitude,
                    longitude: staticBus.route.source.longitude,
                    status: 'current',
                  ),
                  ...staticBus.route.stops.map(
                    (s) => RouteStopStatus(
                      name: s.name,
                      latitude: s.latitude,
                      longitude: s.longitude,
                      status: 'upcoming',
                    ),
                  ),
                  RouteStopStatus(
                    name: staticBus.route.destination.name,
                    latitude: staticBus.route.destination.latitude,
                    longitude: staticBus.route.destination.longitude,
                    status: 'upcoming',
                  ),
                ],
              );
              await _repository.updateTrackingState(initialState);
            }
          }
          notifyListeners();
        },
        onError: (e) {
          _gpsStatus = 'Inactive';
          _isTracking = false;
          notifyListeners();
        },
      );

      return true;
    } catch (e) {
      _gpsStatus = 'Inactive';
      _isTracking = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> stopTracking() async {
    if (_assignedBus == null || _assignedBus!.busId.isEmpty) return;

    _gpsSubscription?.cancel();
    _gpsSubscription = null;
    _gpsStatus = 'Inactive';
    _isTracking = false;
    notifyListeners();

    try {
      await _repository.setTrackingActive(_assignedBus!.busId, false);
    } catch (e) {
      debugPrint('Error stopping tracking in Firestore: $e');
    }
  }

  // --- Student Actions ---

  // Listen to all tracking records to show active indicators on cards
  void startAllTrackingStream() {
    _allTrackingSubscription?.cancel();
    _allTrackingSubscription = _repository.streamAllActiveTracking().listen((
      states,
    ) {
      _allTrackingStates = states;
      notifyListeners();
    });
  }

  void stopAllTrackingStream() {
    _allTrackingSubscription?.cancel();
    _allTrackingSubscription = null;
  }

  void searchBuses(String query) {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _matchingBuses = List.from(_buses);
    } else {
      final q = query.toLowerCase();
      _matchingBuses = _buses.where((bus) {
        final numberMatch = bus.busNumber.toLowerCase().contains(q);
        final routeNameMatch = (bus.busName ?? '').toLowerCase().contains(q);
        final stopsMatch = bus.route.stops.any(
          (s) => s.name.toLowerCase().contains(q),
        );
        final sourceDestMatch =
            bus.route.source.name.toLowerCase().contains(q) ||
            bus.route.destination.name.toLowerCase().contains(q);
        return numberMatch || routeNameMatch || stopsMatch || sourceDestMatch;
      }).toList();
    }
    notifyListeners();
  }

  // Listen to single bus location updates for student
  void listenToBusLive(String busId) {
    _activeTrackingSubscription?.cancel();
    _activeTrackingSubscription = _repository.streamBusTracking(busId).listen((
      state,
    ) {
      _activeTrackingState = state;
      notifyListeners();
    });
  }

  void stopListeningToBusLive() {
    _activeTrackingSubscription?.cancel();
    _activeTrackingSubscription = null;
    _activeTrackingState = null;
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    _activeTrackingSubscription?.cancel();
    _allTrackingSubscription?.cancel();
    super.dispose();
  }
}
