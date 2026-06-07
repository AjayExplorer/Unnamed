import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../request_letter/faculty/models/faculty_model.dart';
import '../models/bus_model.dart';
import '../providers/bus_tracking_provider.dart';

class AdminBusRegistrationScreen extends StatefulWidget {
  const AdminBusRegistrationScreen({super.key});

  @override
  State<AdminBusRegistrationScreen> createState() => _AdminBusRegistrationScreenState();
}

class _AdminBusRegistrationScreenState extends State<AdminBusRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _busNumberController = TextEditingController();
  final _numberPlateController = TextEditingController();
  final _busNameController = TextEditingController();
  String? _selectedDriverId;

  // Route fields
  final _sourceNameController = TextEditingController(text: 'Main Campus');
  LatLng _sourceLatLng = const LatLng(10.0158, 76.3507);
  
  final _destNameController = TextEditingController(text: 'City Terminal');
  LatLng _destLatLng = const LatLng(10.0358, 76.3707);

  final List<BusStop> _intermediateStops = [];
  final _stopNameController = TextEditingController();
  LatLng _selectedMapLatLng = const LatLng(10.0258, 76.3607);
  
  String _pinningTarget = 'none'; // 'source', 'destination', 'stop'
  late MapController _mapController;

  // Edit mode state
  String? _editingBusId;
  String? _previousDriverId; // to handle driver reassignment
  bool get _isEditMode => _editingBusId != null;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BusTrackingProvider>();
      provider.loadDrivers();
      provider.loadBuses();
    });
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _numberPlateController.dispose();
    _busNameController.dispose();
    _sourceNameController.dispose();
    _destNameController.dispose();
    _stopNameController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _busNumberController.clear();
    _numberPlateController.clear();
    _busNameController.clear();
    _sourceNameController.text = 'Main Campus';
    _destNameController.text = 'City Terminal';
    _stopNameController.clear();
    setState(() {
      _selectedDriverId = null;
      _sourceLatLng = const LatLng(10.0158, 76.3507);
      _destLatLng = const LatLng(10.0358, 76.3707);
      _selectedMapLatLng = const LatLng(10.0258, 76.3607);
      _intermediateStops.clear();
      _pinningTarget = 'none';
      _editingBusId = null;
      _previousDriverId = null;
    });
  }

  void _startEditingBus(Bus bus) {
    _busNumberController.text = bus.busNumber;
    _numberPlateController.text = bus.numberPlate;
    _busNameController.text = bus.busName ?? '';
    _sourceNameController.text = bus.route.source.name;
    _destNameController.text = bus.route.destination.name;

    setState(() {
      _selectedDriverId = bus.driverId;
      _previousDriverId = bus.driverId;
      _editingBusId = bus.busId;
      _sourceLatLng = LatLng(bus.route.source.latitude, bus.route.source.longitude);
      _destLatLng = LatLng(bus.route.destination.latitude, bus.route.destination.longitude);
      _intermediateStops.clear();
      _intermediateStops.addAll(bus.route.stops);
      _pinningTarget = 'none';
    });

    // Center map on the route
    try {
      _mapController.move(_sourceLatLng, 13.0);
    } catch (_) {
      // MapController may not be ready
    }
  }

  void _addStop() {
    if (_stopNameController.text.trim().isEmpty) return;
    setState(() {
      _intermediateStops.add(
        BusStop(
          name: _stopNameController.text.trim(),
          latitude: _selectedMapLatLng.latitude,
          longitude: _selectedMapLatLng.longitude,
        ),
      );
      _stopNameController.clear();
      _pinningTarget = 'none';
    });
  }

  void _submitBus() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assigned driver.'), backgroundColor: Colors.red),
      );
      return;
    }

    final provider = context.read<BusTrackingProvider>();
    final route = BusRoute(
      source: BusStop(name: _sourceNameController.text.trim(), latitude: _sourceLatLng.latitude, longitude: _sourceLatLng.longitude),
      destination: BusStop(name: _destNameController.text.trim(), latitude: _destLatLng.latitude, longitude: _destLatLng.longitude),
      stops: _intermediateStops,
    );

    bool success;

    if (_isEditMode) {
      success = await provider.updateBus(
        busId: _editingBusId!,
        busNumber: _busNumberController.text.trim(),
        numberPlate: _numberPlateController.text.trim(),
        busName: _busNameController.text.trim().isEmpty ? null : _busNameController.text.trim(),
        driverId: _selectedDriverId!,
        route: route,
        previousDriverId: _previousDriverId,
      );
    } else {
      success = await provider.registerBus(
        busNumber: _busNumberController.text.trim(),
        numberPlate: _numberPlateController.text.trim(),
        busName: _busNameController.text.trim().isEmpty ? null : _busNameController.text.trim(),
        driverId: _selectedDriverId!,
        route: route,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Bus updated successfully!' : 'Bus and Route registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Operation failed.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);
    final provider = context.watch<BusTrackingProvider>();
    final isWide = MediaQuery.of(context).size.width > 768;

    final formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditMode ? 'Update Bus Details' : 'Bus Specifications',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _busNumberController,
                    decoration: InputDecoration(
                      labelText: 'Bus Number (e.g. Bus 42)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter bus number' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _numberPlateController,
                    decoration: InputDecoration(
                      labelText: 'Number Plate (e.g. KL-01-CA-1234)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter number plate' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _busNameController,
                    decoration: InputDecoration(
                      labelText: 'Route Name (e.g. Green Valley - Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedDriverId,
                    hint: const Text('Assign Driver'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: provider.drivers.map((driver) {
                      return DropdownMenuItem<String>(
                        value: driver.facultyId,
                        child: Text('${driver.name} (${driver.phone})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDriverId = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Route Definition',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source Setup
                  const Text('Source (Start)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sourceNameController,
                          decoration: InputDecoration(
                            labelText: 'Source Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Enter source name' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _pinningTarget = 'source'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pinningTarget == 'source' ? Colors.orange : Colors.grey[200],
                          foregroundColor: _pinningTarget == 'source' ? Colors.white : Colors.black,
                        ),
                        icon: const Icon(Icons.pin_drop),
                        label: const Text('Pin'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Destination Setup
                  const Text('Destination (End)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _destNameController,
                          decoration: InputDecoration(
                            labelText: 'Destination Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Enter destination name' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _pinningTarget = 'destination'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pinningTarget == 'destination' ? Colors.orange : Colors.grey[200],
                          foregroundColor: _pinningTarget == 'destination' ? Colors.white : Colors.black,
                        ),
                        icon: const Icon(Icons.pin_drop),
                        label: const Text('Pin'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Add Intermediate Stops', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stopNameController,
                          decoration: InputDecoration(
                            labelText: 'Stop Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _pinningTarget = 'stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pinningTarget == 'stop' ? Colors.orange : Colors.grey[200],
                          foregroundColor: _pinningTarget == 'stop' ? Colors.white : Colors.black,
                        ),
                        icon: const Icon(Icons.pin_drop),
                        label: const Text('Pin'),
                      ),
                    ],
                  ),
                  if (_pinningTarget == 'stop') ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addStop,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
                        child: const Text('Confirm & Add Stop'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_intermediateStops.isNotEmpty) ...[
                    const Text('Stops Added:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _intermediateStops.length,
                      itemBuilder: (context, index) {
                        final stop = _intermediateStops[index];
                        return Card(
                          color: Colors.grey[100],
                          elevation: 0,
                          child: ListTile(
                            title: Text(stop.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('Lat: ${stop.latitude.toStringAsFixed(4)}, Lng: ${stop.longitude.toStringAsFixed(4)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => _intermediateStops.removeAt(index)),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_isEditMode) ...[
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF667085)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF667085))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitBus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditMode ? const Color(0xFF0F766E) : primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditMode ? 'Update Bus & Route' : 'Register Bus & Route',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),

          // --- Existing Buses List ---
          const SizedBox(height: 36),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Existing Buses',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap Edit to modify bus details or route.',
            style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
          ),
          const SizedBox(height: 16),
          if (provider.isLoading && provider.buses.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (provider.buses.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.directions_bus_outlined, size: 48, color: Color(0xFF98A2B3)),
                      SizedBox(height: 12),
                      Text(
                        'No buses registered yet.',
                        style: TextStyle(fontSize: 15, color: Color(0xFF667085), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.buses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final bus = provider.buses[index];
                final isCurrentlyEditing = _editingBusId == bus.busId;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isCurrentlyEditing
                        ? const BorderSide(color: Color(0xFF0F766E), width: 2)
                        : BorderSide.none,
                  ),
                  elevation: isCurrentlyEditing ? 4 : 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: primaryBlue.withOpacity(0.1),
                              child: const Icon(Icons.directions_bus, color: primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bus.busNumber,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF101828),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bus.numberPlate,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF667085), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrentlyEditing)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F766E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'EDITING',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (bus.busName != null && bus.busName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.route_outlined, size: 14, color: Color(0xFF667085)),
                                const SizedBox(width: 6),
                                Text(bus.busName!, style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: Color(0xFF667085)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${bus.driverName} (${bus.driverPhone})',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.play_circle_fill, size: 14, color: Colors.green),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${bus.route.source.name} → ${bus.route.destination.name}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (bus.route.stops.isNotEmpty)
                              Text(
                                '${bus.route.stops.length} stops',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF98A2B3), fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: isCurrentlyEditing ? null : () => _startEditingBus(bus),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text(isCurrentlyEditing ? 'Currently Editing' : 'Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryBlue,
                                side: BorderSide(color: isCurrentlyEditing ? Colors.grey[300]! : primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );

    final mapSection = Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(10.0158, 76.3507),
            initialZoom: 13.0,
            onTap: (tapPosition, point) {
              if (_pinningTarget == 'source') {
                setState(() {
                  _sourceLatLng = point;
                  _pinningTarget = 'none';
                });
              } else if (_pinningTarget == 'destination') {
                setState(() {
                  _destLatLng = point;
                  _pinningTarget = 'none';
                });
              } else if (_pinningTarget == 'stop') {
                setState(() {
                  _selectedMapLatLng = point;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.school.openpro',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    _sourceLatLng,
                    ..._intermediateStops.map((s) => LatLng(s.latitude, s.longitude)),
                    _destLatLng,
                  ],
                  color: primaryBlue.withValues(alpha: 0.7),
                  strokeWidth: 4,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                // Source
                Marker(
                  point: _sourceLatLng,
                  width: 30,
                  height: 30,
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 15,
                    child: Icon(Icons.play_circle_fill, color: Colors.green, size: 24),
                  ),
                ),
                // Destination
                Marker(
                  point: _destLatLng,
                  width: 30,
                  height: 30,
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 15,
                    child: Icon(Icons.stars, color: Colors.red, size: 24),
                  ),
                ),
                // Stops
                ..._intermediateStops.map((stop) => Marker(
                      point: LatLng(stop.latitude, stop.longitude),
                      width: 20,
                      height: 20,
                      child: const CircleAvatar(backgroundColor: Color(0xFF2F6BDA), radius: 10),
                    )),
                // Active Pinning marker
                if (_pinningTarget == 'stop')
                  Marker(
                    point: _selectedMapLatLng,
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.pin_drop, color: Colors.orange, size: 30),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            color: Colors.white.withValues(alpha: 0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                _pinningTarget == 'source'
                    ? 'Tap on map to set Source location coordinate.'
                    : _pinningTarget == 'destination'
                        ? 'Tap on map to set Destination location coordinate.'
                        : _pinningTarget == 'stop'
                            ? 'Tap on map to place the stop PIN, then type stop name and click Confirm.'
                            : 'Interactive Route Builder. Select "Pin" to place coordinates.',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF101828)),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Update Bus & Route' : 'Register Bus & Route',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isWide
          ? Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: formContent,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: mapSection,
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  formContent,
                  const SizedBox(height: 20),
                  const Text(
                    'Route Pinning Map',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 400,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: mapSection,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
