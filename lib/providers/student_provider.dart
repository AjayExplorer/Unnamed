import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/database_service.dart';
import '../services/student_validation_service.dart';

class StudentProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StudentValidationService _validationService = StudentValidationService();

  List<Student> _students = [];
  Student? _currentStudent;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  List<Student> get students => _students;
  Student? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Register a new student
  Future<bool> registerStudent(
    String fullName,
    String phoneNumber,
    String admissionNumber,
    String password,
    String confirmPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Validate data format
      final validationResult =
          _validationService.validateStudentData(
            fullName,
            phoneNumber,
            admissionNumber,
            password,
            confirmPassword,
          );

      if (!validationResult.isValid) {
        _errorMessage = validationResult.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check for duplicates
      final duplicateCheckResult =
          await _validationService.checkDuplicateRegistration(
            admissionNumber,
            phoneNumber,
          );

      if (!duplicateCheckResult.isValid) {
        _errorMessage = duplicateCheckResult.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create and add student to database
      final student = Student(
        fullName: fullName,
        phoneNumber: phoneNumber,
        admissionNumber: admissionNumber.toUpperCase(),
        password: password,
      );

      final studentId = await _databaseService.addStudent(student);
      _currentStudent = student.copyWith(id: studentId);
      _successMessage = 'Student registered successfully!';
      _students.add(_currentStudent!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final errorText = e.toString().toLowerCase().contains('permission-denied')
          ? 'Firebase permission denied. Check Firestore rules and app authorization.'
          : 'Registration failed: $e';
      _errorMessage = errorText;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify student credentials (login)
  Future<bool> verifyStudentCredentials(
    String admissionNumber,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _validationService.verifyStudentCredentials(
        admissionNumber.toUpperCase(),
        password,
      );

      if (!result.isValid) {
        _errorMessage = result.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentStudent = result.student;
      _successMessage = 'Student verified successfully!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Verification failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudentProfile({
    required String fullName,
    required String phoneNumber,
    String? place,
    String? bloodGroup,
    String? photoUrl,
    String? department,
  }) async {
    if (_currentStudent == null) {
      _errorMessage = 'No student is currently logged in.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedStudent = _currentStudent!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        place: place,
        bloodGroup: bloodGroup,
        photoUrl: photoUrl,
        department: department,
      );

      await _databaseService.updateStudent(updatedStudent);
      _currentStudent = updatedStudent;
      _successMessage = 'Profile updated successfully!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cross-check student details
  Future<bool> crossCheckStudentDetails(
    String admissionNumber,
    String fullName,
    String phoneNumber,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _validationService.crossCheckStudentDetails(
        admissionNumber,
        fullName,
        phoneNumber,
      );

      if (!result.isValid) {
        _errorMessage = result.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentStudent = result.student;
      _successMessage = result.message;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Cross-check failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load all students from database
  Future<void> loadAllStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _databaseService.getAllStudents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load students: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search students by name
  Future<void> searchStudents(String searchTerm) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _databaseService.searchStudentsByName(searchTerm);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get student by ID
  Future<Student?> getStudentById(String studentId) async {
    try {
      return await _databaseService.getStudentById(studentId);
    } catch (e) {
      _errorMessage = 'Failed to fetch student: $e';
      notifyListeners();
      return null;
    }
  }

  /// Clear error and success messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Clear current student
  void clearCurrentStudent() {
    _currentStudent = null;
    notifyListeners();
  }
}
