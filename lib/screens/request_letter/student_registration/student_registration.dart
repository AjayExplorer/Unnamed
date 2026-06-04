import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';

class StudentRegistration extends StatefulWidget {
  const StudentRegistration({super.key});

  @override
  State<StudentRegistration> createState() => _StudentRegistrationState();
}

class _StudentRegistrationState extends State<StudentRegistration> {
  final _formKey = GlobalKey<FormState>();

  // Controllers matching teammate's standard instantiations
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _admissionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _admissionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textGrey = Color(0xFF667085); 

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
             Color(0xFF174EA6), // Target background Sage Green Top
              Color(0xFF174EA6), // Target background Sage Green Bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              children: [
                // Top Custom Header Navigation row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Section Title matching target text structure
                const Text(
                  'Register Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Core Form Card Container constrained for large screen sizes
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A0F172A),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Full Name
                            _buildLabel('Full Name'),
                            _buildInputField(
                              controller: _nameController,
                              hintText: 'Your name',
                              keyboardType: TextInputType.name,
                              validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                            ),
                            const SizedBox(height: 16),

                            // 2. Phone Number
                            _buildLabel('Phone Number'),
                            _buildInputField(
                              controller: _phoneController,
                              hintText: '+91 9876543210',
                              keyboardType: TextInputType.phone,
                              validator: (v) => v!.isEmpty ? 'Please enter phone number' : null,
                            ),
                            const SizedBox(height: 16),

                            // 3. Admission Number
                            _buildLabel('Admission Number'),
                            _buildInputField(
                              controller: _admissionController,
                              hintText: 'KGR23CS000',
                              validator: (v) => v!.isEmpty ? 'Please enter admission number' : null,
                            ),
                            const SizedBox(height: 16),

                            // 4. Password
                            _buildLabel('Password'),
                            _buildInputField(
                              controller: _passwordController,
                              hintText: 'Password',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: textGrey,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) => v!.length < 6 ? 'Password must be 6+ characters' : null,
                            ),
                            const SizedBox(height: 16),

                            // 5. Confirm Password
                            _buildLabel('Confirm Password'),
                            _buildInputField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: textGrey,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              validator: (v) {
                                if (v != _passwordController.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Registration Button Core Action Frame
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Consumer<StudentProvider>(
                                builder: (context, studentProvider, _) {
                                  return ElevatedButton(
                                    onPressed: _isRegistering || studentProvider.isLoading
                                        ? null
                                        : () => _handleRegistration(context, studentProvider),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF174EA6), // Custom Layout matching Sage Button tint
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                    child: _isRegistering || studentProvider.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Register',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Navigation Link Back to Sign In Screen
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: textGrey.withValues(alpha: 0.95), fontSize: 13),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF174EA6),
                                      padding: EdgeInsets.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration(
    BuildContext context,
    StudentProvider studentProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isRegistering = true);

    final success = await studentProvider.registerStudent(
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _admissionController.text.trim().toUpperCase(),
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (!mounted || !context.mounted) return;

    setState(() => _isRegistering = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(studentProvider.successMessage ?? 'Registration successful!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Clear controllers
      _nameController.clear();
      _phoneController.clear();
      _admissionController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Navigate back after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(studentProvider.errorMessage ?? 'Registration failed!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    studentProvider.clearMessages();
  }

  // Label configuration helper matching teammate layout semantics
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
      ),
    );
  }

  // Robust TextFormField builder borrowing style choices from teammate's StyledField
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9FAFB), 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
        hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14), 
        errorStyle: const TextStyle(height: 0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF96B79D), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }
}
