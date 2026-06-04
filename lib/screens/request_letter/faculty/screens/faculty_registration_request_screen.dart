import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/faculty_registration_provider.dart';

class FacultyRegistrationRequestScreen extends StatefulWidget {
  const FacultyRegistrationRequestScreen({super.key});

  @override
  State<FacultyRegistrationRequestScreen> createState() => _FacultyRegistrationRequestScreenState();
}

class _FacultyRegistrationRequestScreenState extends State<FacultyRegistrationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'teacher';

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Registration', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Consumer<FacultyRegistrationProvider>(
              builder: (context, provider, _) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField('Name', _nameController, 'Enter full name'),
                      const SizedBox(height: 12),
                      _buildField('Username', _usernameController, 'Choose a username'),
                      const SizedBox(height: 12),
                      _buildField('Email', _emailController, 'Enter email address', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildField('Phone', _phoneController, 'Enter phone number', keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      _buildDropdown(),
                      const SizedBox(height: 12),
                      _buildField('Password', _passwordController, 'Choose a password', obscureText: true),
                      const SizedBox(height: 12),
                      _buildField('Confirm Password', _confirmPasswordController, 'Confirm password', obscureText: true),
                      const SizedBox(height: 20),
                      if (provider.errorMessage != null)
                        Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                      if (provider.successMessage != null)
                        Text(provider.successMessage!, style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: provider.isSubmitting ? null : () => _submit(context),
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: provider.isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hintText, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label.toLowerCase()';
            }
            if (label == 'Confirm Password' && value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          items: const [
            DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
            DropdownMenuItem(value: 'hod', child: Text('HOD')),
            DropdownMenuItem(value: 'principal', child: Text('Principal')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedRole = value);
            }
          },
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<FacultyRegistrationProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await provider.submitRegistrationRequest(
      name: _nameController.text.trim(),
      designation: '',
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('Request submitted. Admin will review it.')));
      _formKey.currentState?.reset();
      setState(() => _selectedRole = 'teacher');
    }
  }
}
