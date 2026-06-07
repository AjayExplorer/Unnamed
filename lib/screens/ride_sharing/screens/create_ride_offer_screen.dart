import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';
import '../models/ride_offer.dart';
import '../services/ride_sharing_service.dart';

class CreateRideOfferScreen extends StatefulWidget {
  const CreateRideOfferScreen({super.key});

  @override
  State<CreateRideOfferScreen> createState() => _CreateRideOfferScreenState();
}

class _CreateRideOfferScreenState extends State<CreateRideOfferScreen> {
  static const _teal = Color(0xFF2AADC4);
  static const _tealDark = Color(0xFF1A8FA5);

  final _formKey = GlobalKey<FormState>();
  final _sourceCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  VehicleType _vehicleType = VehicleType.car;
  int _seats = 2;
  bool _isSubmitting = false;

  final _service = RideSharingService();

  @override
  void dispose() {
    _sourceCtrl.dispose();
    _destCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  // ── Date helpers ──────────────────────────────────────────────────────
  void _setToday() => setState(() => _selectedDate = DateTime.now());

  void _setTomorrow() =>
      setState(() => _selectedDate = DateTime.now().add(const Duration(days: 1)));

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String get _dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    if (sel == today) return 'Today';
    if (sel == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  // ── Submit ────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final student = context.read<StudentProvider>().currentStudent;
    if (student == null) return;

    // Build combined rideDateTime
    final rideDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (rideDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride date/time must be in the future.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final offer = RideOffer(
        creatorId: student.id ?? '',
        creatorName: student.fullName,
        source: _sourceCtrl.text.trim(),
        destination: _destCtrl.text.trim(),
        rideDateTime: rideDateTime,
        vehicleType: _vehicleType,
        totalSeats: _seats,
        availableSeats: _seats,
        additionalDetails: _detailsCtrl.text.trim(),
        status: RideStatus.active,
        createdAt: DateTime.now(),
      );

      await _service.createRideOffer(offer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride offer created successfully!'),
            backgroundColor: _tealDark,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create ride: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FB),
      appBar: AppBar(
        title: const Text('Create a Ride Offer',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Source ────────────────────────────────────────
            _SectionLabel(label: 'Pick-up Location'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _sourceCtrl,
              hint: 'Enter pick-up / source location',
              icon: Icons.location_on_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Source is required' : null,
            ),
            const SizedBox(height: 16),

            // ── Destination ───────────────────────────────────
            _SectionLabel(label: 'Destination'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _destCtrl,
              hint: 'Enter destination',
              icon: Icons.flag_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Destination is required' : null,
            ),
            const SizedBox(height: 20),

            // ── Date & Time ───────────────────────────────────
            _SectionLabel(label: 'Ride Date & Time'),
            const SizedBox(height: 10),
            _buildDateTimeRow(),
            const SizedBox(height: 20),

            // ── Vehicle type ──────────────────────────────────
            _SectionLabel(label: 'Vehicle Type'),
            const SizedBox(height: 10),
            _buildVehicleSelector(),
            const SizedBox(height: 20),

            // ── Seats ─────────────────────────────────────────
            _SectionLabel(label: 'Available Seats'),
            const SizedBox(height: 10),
            _buildSeatCounter(),
            const SizedBox(height: 20),

            // ── Details ───────────────────────────────────────
            _SectionLabel(label: 'Additional Details (Optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _detailsCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Any extra info (vehicle colour, contact, meeting point…)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFD0EFF4), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _teal, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ── Confirm button ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Offer'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.black54, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _teal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFD0EFF4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Date buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateButton(
                label: 'Today',
                isSelected: _dateLabel == 'Today',
                onTap: _setToday,
              ),
              const SizedBox(height: 8),
              _DateButton(
                label: 'Tomorrow',
                isSelected: _dateLabel == 'Tomorrow',
                onTap: _setTomorrow,
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Current date display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _dateLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Time picker
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: _teal, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                        color: _teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector() {
    final options = [
      (VehicleType.car, Icons.directions_car_rounded, 'Car'),
      (VehicleType.bike, Icons.two_wheeler_rounded, 'Bike'),
    ];
    return Row(
      children: options.map((o) {
        final (type, icon, label) = o;
        final selected = _vehicleType == type;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => setState(() => _vehicleType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? _teal : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? _teal : const Color(0xFFD0EFF4),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      color: selected ? Colors.white : _teal, size: 22),
                  const SizedBox(width: 8),
                  Text(label,
                      style: TextStyle(
                          color: selected ? Colors.white : _teal,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeatCounter() {
    return Row(
      children: [
        _CounterButton(
          icon: Icons.remove_rounded,
          onTap: () {
            if (_seats > 1) setState(() => _seats--);
          },
        ),
        const SizedBox(width: 20),
        Text(
          '$_seats',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: _tealDark),
        ),
        const SizedBox(width: 20),
        _CounterButton(
          icon: Icons.add_rounded,
          onTap: () {
            if (_seats < 8) setState(() => _seats++);
          },
        ),
      ],
    );
  }
}

// ── Small helper widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A8FA5),
          letterSpacing: 0.4),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF1A8FA5)
                : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF2AADC4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
