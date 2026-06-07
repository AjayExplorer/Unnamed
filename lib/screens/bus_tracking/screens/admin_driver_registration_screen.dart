import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_tracking_provider.dart';

class AdminDriverRegistrationScreen extends StatefulWidget {
  const AdminDriverRegistrationScreen({super.key});

  @override
  State<AdminDriverRegistrationScreen> createState() => _AdminDriverRegistrationScreenState();
}

class _AdminDriverRegistrationScreenState extends State<AdminDriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Edit mode state
  String? _editingDriverId;
  bool get _isEditMode => _editingDriverId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusTrackingProvider>().loadDrivers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _usernameController.clear();
    _passwordController.clear();
    setState(() {
      _editingDriverId = null;
    });
  }

  void _startEditing(dynamic driver) {
    _nameController.text = driver.name;
    _phoneController.text = driver.phone;
    _addressController.text = driver.address ?? '';
    _usernameController.text = driver.username;
    _passwordController.text = driver.password;
    setState(() {
      _editingDriverId = driver.facultyId;
    });
    // Scroll to top of form
    Scrollable.ensureVisible(
      _formKey.currentContext ?? context,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BusTrackingProvider>();
    bool success;

    if (_isEditMode) {
      success = await provider.updateDriver(
        driverId: _editingDriverId!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      success = await provider.registerDriver(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Driver updated successfully!' : 'Driver registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Operation failed.'),
          backgroundColor: Colors.red,
        ),
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
        title: const Text('Manage Drivers', style: TextStyle(fontWeight: FontWeight.w700)),
        foregroundColor: Colors.white,
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Form Section ---
            const SizedBox(height: 10),
            Text(
              _isEditMode ? 'Update Driver Details' : 'Create Driver Account',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isEditMode
                  ? 'Modify the driver details below and click Update.'
                  : 'Fill in the driver details below. Driver credentials will be created dynamically.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Driver Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Driver Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter driver full name' : null,
                      ),
                      const SizedBox(height: 16),
                      // Phone Number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter phone number' : null,
                      ),
                      const SizedBox(height: 16),
                      // Address
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.home_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter address' : null,
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 32),
                      const Text(
                        'Login Credentials',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.alternate_email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 16),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter password' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_isEditMode) ...[
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _clearForm,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF667085)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: const Text(
                          'Cancel Edit',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF667085)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditMode ? const Color(0xFF0F766E) : primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        elevation: 0,
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isEditMode ? 'Update Driver' : 'Register Driver',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // --- Existing Drivers List ---
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Existing Drivers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap Edit to modify any driver\'s details.',
              style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading && provider.drivers.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (provider.drivers.isEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.person_off_outlined, size: 48, color: Color(0xFF98A2B3)),
                        SizedBox(height: 12),
                        Text(
                          'No drivers registered yet.',
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
                itemCount: provider.drivers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final driver = provider.drivers[index];
                  final isCurrentlyEditing = _editingDriverId == driver.facultyId;
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
                                child: const Icon(Icons.person, color: primaryBlue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF101828),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Username: ${driver.username}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
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
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF667085)),
                              const SizedBox(width: 6),
                              Text(driver.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
                              const SizedBox(width: 16),
                              const Icon(Icons.home_outlined, size: 14, color: Color(0xFF667085)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  driver.address ?? 'N/A',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (driver.assignedBusId != null && driver.assignedBusId!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.directions_bus_outlined, size: 14, color: Color(0xFF0F766E)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Bus Assigned: ${driver.assignedBusId}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F766E), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber[700]),
                                  const SizedBox(width: 6),
                                  Text(
                                    'No bus assigned',
                                    style: TextStyle(fontSize: 12, color: Colors.amber[700], fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: isCurrentlyEditing ? null : () => _startEditing(driver),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text(isCurrentlyEditing ? 'Currently Editing' : 'Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryBlue,
                                side: BorderSide(color: isCurrentlyEditing ? Colors.grey[300]! : primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
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
      ),
    );
  }
}
