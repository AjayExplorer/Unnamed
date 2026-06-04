import '../models/student.dart';
import 'database_service.dart';

class ValidationResult {
  final bool isValid;
  final String message;
  final Student? student;

  ValidationResult({
    required this.isValid,
    required this.message,
    this.student,
  });
}

class StudentValidationService {
  static final StudentValidationService _instance = StudentValidationService._internal();
  final DatabaseService _databaseService = DatabaseService();

  StudentValidationService._internal();

  factory StudentValidationService() {
    return _instance;
  }

  /// Validate student registration data format
  ValidationResult validateStudentData(
    String fullName,
    String phoneNumber,
    String admissionNumber,
    String password,
    String confirmPassword,
  ) {
    // Validate full name
    if (fullName.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Full name cannot be empty',
      );
    }
    if (fullName.trim().length < 3) {
      return ValidationResult(
        isValid: false,
        message: 'Full name must be at least 3 characters',
      );
    }

    // Validate phone number
    if (phoneNumber.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Phone number cannot be empty',
      );
    }
    if (!isValidPhoneNumber(phoneNumber)) {
      return ValidationResult(
        isValid: false,
        message: 'Please enter a valid phone number',
      );
    }

    // Validate admission number
    if (admissionNumber.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Admission number cannot be empty',
      );
    }
    if (!isValidAdmissionNumber(admissionNumber)) {
      return ValidationResult(
        isValid: false,
        message: 'Please enter a valid admission number (e.g., KGR23CS001)',
      );
    }

    // Validate password
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Password cannot be empty',
      );
    }
    if (password.length < 6) {
      return ValidationResult(
        isValid: false,
        message: 'Password must be at least 6 characters',
      );
    }

    // Validate password match
    if (password != confirmPassword) {
      return ValidationResult(
        isValid: false,
        message: 'Passwords do not match',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Validation successful',
    );
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it's a valid Indian phone number (10 digits) or with country code
    return cleanNumber.length >= 10;
  }

  /// Validate admission number format
  bool isValidAdmissionNumber(String admissionNumber) {
    // Pattern: KGR23CS001 or similar
    final pattern = RegExp(r'^[A-Z]{3}\d{2}[A-Z]{2}\d{3,4}$');
    return pattern.hasMatch(admissionNumber.toUpperCase());
  }

  /// Check if student exists in database and verify credentials
  Future<ValidationResult> verifyStudentCredentials(
    String admissionNumber,
    String password,
  ) async {
    try {
      final normalizedAdmission = admissionNumber.toUpperCase();
      final student =
          await _databaseService.getStudentByAdmissionNumber(normalizedAdmission);

      if (student == null) {
        return ValidationResult(
          isValid: false,
          message: 'Student with this admission number not found',
        );
      }

      if (student.password != password) {
        return ValidationResult(
          isValid: false,
          message: 'Invalid password',
        );
      }

      return ValidationResult(
        isValid: true,
        message: 'Student verified successfully',
        student: student,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        message: 'Error verifying student: $e',
      );
    }
  }

  /// Cross-check student details against stored data
  Future<ValidationResult> crossCheckStudentDetails(
    String admissionNumber,
    String fullName,
    String phoneNumber,
  ) async {
    try {
      final normalizedAdmission = admissionNumber.toUpperCase();
      final student =
          await _databaseService.getStudentByAdmissionNumber(normalizedAdmission);

      if (student == null) {
        return ValidationResult(
          isValid: false,
          message: 'Student with admission number "$admissionNumber" not found',
        );
      }

      // Check if name matches
      if (student.fullName.toLowerCase().trim() !=
          fullName.toLowerCase().trim()) {
        return ValidationResult(
          isValid: false,
          message:
              'Name mismatch. Expected: ${student.fullName}, Got: $fullName',
        );
      }

      // Check if phone number matches
      if (student.phoneNumber.replaceAll(RegExp(r'[^\d]'), '') !=
          phoneNumber.replaceAll(RegExp(r'[^\d]'), '')) {
        return ValidationResult(
          isValid: false,
          message:
              'Phone number mismatch. Expected: ${student.phoneNumber}, Got: $phoneNumber',
        );
      }

      return ValidationResult(
        isValid: true,
        message: 'All student details matched successfully',
        student: student,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        message: 'Error during cross-check: $e',
      );
    }
  }

  /// Check for duplicate registrations
  Future<ValidationResult> checkDuplicateRegistration(
    String admissionNumber,
    String phoneNumber,
  ) async {
    try {
      final normalizedAdmission = admissionNumber.toUpperCase();
      final byAdmission =
          await _databaseService.admissionNumberExists(normalizedAdmission);
      if (byAdmission) {
        return ValidationResult(
          isValid: false,
          message: 'This admission number is already registered',
        );
      }

      final byPhone =
          await _databaseService.getStudentByPhoneNumber(phoneNumber);
      if (byPhone != null) {
        return ValidationResult(
          isValid: false,
          message: 'This phone number is already registered',
        );
      }

      return ValidationResult(
        isValid: true,
        message: 'No duplicate registration found',
      );
    } catch (e) {
      if (e.toString().toLowerCase().contains('permission-denied')) {
        return ValidationResult(
          isValid: true,
          message:
              'Duplicate check skipped because Firestore permissions prevent reads. Registration will continue, but Firestore write permissions still need to be enabled.',
        );
      }
      return ValidationResult(
        isValid: false,
        message: 'Error checking duplicates: $e',
      );
    }
  }
}
