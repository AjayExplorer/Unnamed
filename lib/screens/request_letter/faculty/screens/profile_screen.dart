
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../Login_page/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final faculty = context.read<AuthProvider>().currentFaculty;
    if (faculty != null) {
      _phoneController.text = faculty.phone;
      _emailController.text = faculty.email;
      _passwordController.text = faculty.password;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);
    final authProvider = context.watch<AuthProvider>();
    final faculty = authProvider.currentFaculty;

    if (faculty == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w700, color: primaryBlue)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: primaryBlue),
            onPressed: () {
              if (_isEditing) {
                authProvider.updateProfile({
                  'phone': _phoneController.text,
                  'email': _emailController.text,
                  'password': _passwordController.text,
                });
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryBlue.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 60, color: primaryBlue),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(faculty.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(faculty.designation, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            _buildInfoCard(primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildField('Faculty ID', TextEditingController(text: context.read<AuthProvider>().currentFaculty?.facultyId), false),
          const Divider(height: 32),
          _buildField('Phone Number', _phoneController, _isEditing, keyboardType: TextInputType.phone),
          const Divider(height: 32),
          _buildField('Email Address', _emailController, _isEditing, keyboardType: TextInputType.emailAddress),
          const Divider(height: 32),
          _buildField('Password', _passwordController, _isEditing, obscureText: true),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool enabled, {bool obscureText = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF98A2B3), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: enabled ? const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE4E7EC))) : InputBorder.none,
          ),
        ),
      ],
    );
  }
}
