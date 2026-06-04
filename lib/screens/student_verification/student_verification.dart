import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';

class StudentVerification extends StatefulWidget {
  const StudentVerification({super.key});

  @override
  State<StudentVerification> createState() => _StudentVerificationState();
}

class _StudentVerificationState extends State<StudentVerification> {
  final _formKey = GlobalKey<FormState>();
  final _admissionController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  int _verificationMode = 0; // 0: Verify Credentials, 1: Cross-Check Details

  @override
  void dispose() {
    _admissionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
              Color(0xFF174EA6),
              Color(0xFF174EA6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Verify Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
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
                        // Verification Mode Selection
                        _buildLabel('Verification Mode'),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE4E7EC)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildModeOption(
                                'Verify Credentials',
                                'Verify student with admission number and password',
                                0,
                              ),
                              const SizedBox(height: 8),
                              _buildModeOption(
                                'Cross-Check Details',
                                'Verify student by matching all details',
                                1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Common Fields
                        _buildLabel('Admission Number'),
                        _buildInputField(
                          controller: _admissionController,
                          hintText: 'KGR23CS001',
                          validator: (v) =>
                              v!.isEmpty ? 'Please enter admission number' : null,
                        ),
                        const SizedBox(height: 16),

                        // Mode 0: Credentials Verification
                        if (_verificationMode == 0) ...[
                          _buildLabel('Password'),
                          _buildInputField(
                            controller: _passwordController,
                            hintText: 'Enter password',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: textGrey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Please enter password' : null,
                          ),
                        ]
                        // Mode 1: Cross-Check Details
                        else ...[
                          _buildLabel('Full Name'),
                          _buildInputField(
                            controller: _nameController,
                            hintText: 'Your name',
                            keyboardType: TextInputType.name,
                            validator: (v) =>
                                v!.isEmpty ? 'Please enter your name' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Phone Number'),
                          _buildInputField(
                            controller: _phoneController,
                            hintText: '+91 9876543210',
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v!.isEmpty ? 'Please enter phone number' : null,
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Consumer<StudentProvider>(
                            builder: (context, studentProvider, _) {
                              return ElevatedButton(
                                onPressed: studentProvider.isLoading
                                    ? null
                                    : () =>
                                        _handleVerification(context, studentProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF174EA6),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: studentProvider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _verificationMode == 0
                                            ? 'Verify Credentials'
                                            : 'Cross-Check Details',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info Messages
                        Consumer<StudentProvider>(
                          builder: (context, studentProvider, _) {
                            if (studentProvider.successMessage != null) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        studentProvider.successMessage ?? '',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (studentProvider.errorMessage != null) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.red),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        studentProvider.errorMessage ?? '',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),

                        // Display verified student details
                        Consumer<StudentProvider>(
                          builder: (context, studentProvider, _) {
                            if (studentProvider.currentStudent != null) {
                              final student = studentProvider.currentStudent!;
                              return Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      border: Border.all(
                                        color: const Color(0xFFE4E7EC),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Student Details',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildDetailRow('Name:', student.fullName),
                                        _buildDetailRow(
                                          'Admission Number:',
                                          student.admissionNumber,
                                        ),
                                        _buildDetailRow(
                                          'Phone Number:',
                                          student.phoneNumber,
                                        ),
                                        _buildDetailRow(
                                          'Registered On:',
                                          '${student.registrationDate.day}/${student.registrationDate.month}/${student.registrationDate.year}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
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

  Widget _buildModeOption(String title, String subtitle, int mode) {
    return GestureDetector(
      onTap: () => setState(() => _verificationMode = mode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _verificationMode == mode
              ? const Color(0xFF174EA6).withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: _verificationMode == mode
                ? const Color(0xFF174EA6)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: mode,
              groupValue: _verificationMode,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _verificationMode = value);
                }
              },
              activeColor: const Color(0xFF174EA6),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667085),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
      ),
    );
  }

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

  Future<void> _handleVerification(
    BuildContext context,
    StudentProvider studentProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_verificationMode == 0) {
      // Verify Credentials
      await studentProvider.verifyStudentCredentials(
        _admissionController.text.trim().toUpperCase(),
        _passwordController.text,
      );
    } else {
      // Cross-Check Details
      await studentProvider.crossCheckStudentDetails(
        _admissionController.text.trim().toUpperCase(),
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );
    }
  }
}
