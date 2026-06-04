
import '../repositories/base_repository.dart';
import '../repositories/mock_repository.dart';
import '../repositories/firebase_repository.dart';

class ServiceConfig {
  static const bool useFirebase = true; // Toggle this for switching

  static final MockRepository _mock = MockRepository();
  static final FirebaseRepository _firebase = FirebaseRepository();

  static IFacultyRepository get facultyRepo => useFirebase ? _firebase : _mock;
  static IRequestRepository get requestRepo => useFirebase ? _firebase : _mock;
}
