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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusTrackingProvider>().loadDrivers();
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

  void _registerBus() async {
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

    final success = await provider.registerBus(
      busNumber: _busNumberController.text.trim(),
      numberPlate: _numberPlateController.text.trim(),
      busName: _busNameController.text.trim().isEmpty ? null : _busNameController.text.trim(),
      driverId: _selectedDriverId!,
      route: route,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus and Route registered successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Registration failed.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);
    final provider = context.watch<BusTrackingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Register Bus & Route', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Left Form Section
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bus Specifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
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
                              initialValue: _selectedDriverId,
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
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _registerBus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Register Bus & Route', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right Map Section for Pinning
          Expanded(
            flex: 5,
            child: Stack(
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
            ),
          ),
        ],
      ),
    );
  }
}
