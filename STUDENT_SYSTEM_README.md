# Student Registration and Validation System

This document describes the student registration, database storage, and validation system created for the CollabSolve application.

## Overview

The system allows students to:
1. **Register** with their details (name, phone, admission number, password)
2. **Store** all details securely in Firebase Firestore
3. **Verify** their identity using two methods:
   - **Verify Credentials**: Login with admission number and password
   - **Cross-Check Details**: Verify by matching name, phone, and admission number

## Created Files

### 1. **Models** (`lib/models/student.dart`)
Defines the `Student` class with the following fields:
- `id`: Unique Firestore document ID
- `fullName`: Student's full name
- `phoneNumber`: Contact phone number
- `admissionNumber`: Unique admission number (e.g., KGR23CS001)
- `password`: Encrypted password
- `registrationDate`: Timestamp of registration

**Key Methods:**
- `toMap()`: Convert to Firestore-compatible map
- `fromMap()`: Create from Firestore data
- `copyWith()`: Create modified copy

### 2. **Database Service** (`lib/services/database_service.dart`)
Singleton service for Firestore operations:

**Methods:**
- `addStudent(Student)`: Register a new student
- `updateStudent(Student)`: Update existing student
- `getStudentById(String)`: Fetch by ID
- `getStudentByAdmissionNumber(String)`: Fetch by admission number
- `getStudentByPhoneNumber(String)`: Fetch by phone
- `getAllStudents()`: Retrieve all students
- `admissionNumberExists(String)`: Check for duplicates
- `searchStudentsByName(String)`: Search by name
- `getRecentStudents(int)`: Get latest registrations
- `deleteStudent(String)`: Remove a student

### 3. **Validation Service** (`lib/services/student_validation_service.dart`)
Singleton service for data validation:

**Validation Methods:**
- `validateStudentData()`: Validate all input fields
  - Name: 3+ characters
  - Phone: Valid format (10+ digits)
  - Admission: Pattern `KGR23CS001`
  - Password: 6+ characters
  - Password match: Confirm password matches

- `isValidPhoneNumber()`: Check phone format
- `isValidAdmissionNumber()`: Check admission pattern

**Verification Methods:**
- `verifyStudentCredentials()`: Verify admission number + password
- `crossCheckStudentDetails()`: Verify name + phone + admission number
- `checkDuplicateRegistration()`: Prevent duplicate registrations

Returns `ValidationResult` object with:
- `isValid`: Boolean result
- `message`: Error/success message
- `student`: Student object (if verified)

### 4. **Student Provider** (`lib/providers/student_provider.dart`)
ChangeNotifier for state management:

**Properties:**
- `students`: List of all students
- `currentStudent`: Currently logged-in student
- `isLoading`: Loading state
- `errorMessage`: Error message (if any)
- `successMessage`: Success message (if any)

**Methods:**
- `registerStudent()`: Complete registration flow
- `verifyStudentCredentials()`: Login with credentials
- `crossCheckStudentDetails()`: Verify with cross-check
- `loadAllStudents()`: Fetch all from database
- `searchStudents()`: Search by name
- `getStudentById()`: Get specific student
- `clearMessages()`: Clear messages

### 5. **Updated Student Registration Screen** 
(`lib/screens/request_letter/student_registration/student_registration.dart`)

**Changes:**
- Integrated with StudentProvider
- Stores all data to Firestore database
- Shows success/error messages
- Input validation with helpful error messages
- Loading state with spinner
- Auto-clears form on success
- Navigates back after successful registration

### 6. **Student Verification Screen** 
(`lib/screens/student_verification/student_verification.dart`)

**Features:**
- Two verification modes (toggle between them):
  1. **Verify Credentials**: Admission number + password
  2. **Cross-Check Details**: Name + phone + admission number

- Shows verified student details:
  - Full name
  - Admission number
  - Phone number
  - Registration date

- Success/error message display
- Real-time validation

## Database Schema

**Firestore Collection: `students`**

```json
{
  "fullName": "string",
  "phoneNumber": "string",
  "admissionNumber": "string",
  "password": "string",
  "registrationDate": "Timestamp"
}
```

## Usage Flow

### Registration Flow
1. User navigates to `/register` route
2. Fills in registration form
3. System validates data locally
4. System checks for duplicate admissions/phones
5. If valid, creates new Student and stores in Firestore
6. Shows success message and navigates back

### Verification Flow
1. User navigates to `/verify` route
2. Selects verification mode
3. **Mode 1 - Verify Credentials:**
   - Enters admission number and password
   - System queries Firestore for matching admission number
   - Compares passwords
   - Shows student details if match
4. **Mode 2 - Cross-Check Details:**
   - Enters admission number, name, and phone
   - System queries by admission number
   - Compares name and phone with database
   - Shows student details if all match

## Route Navigation

```dart
'/register'    // Student Registration Screen
'/verify'      // Student Verification Screen
```

Add navigation buttons in your UI:

```dart
// Navigate to registration
Navigator.pushNamed(context, '/register');

// Navigate to verification
Navigator.pushNamed(context, '/verify');
```

## Firebase Setup

Ensure your Firebase project has:
1. **Firestore Database**: Create collection `students`
2. **Security Rules**: Configure appropriate read/write rules

Example Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /students/{document=**} {
      allow create: if request.auth != null;
      allow read, write: if request.auth != null;
    }
  }
}
```

## Error Handling

The system includes comprehensive error messages:
- **Registration errors**: Duplicate admission, duplicate phone, validation failures
- **Verification errors**: Student not found, password mismatch, detail mismatch
- **Database errors**: Network issues, Firestore errors

All errors are shown to users via SnackBar notifications.

## Security Notes

⚠️ **Important**: The current implementation stores passwords in plain text. For production:
1. Implement password hashing (use `bcrypt` or similar)
2. Use Firebase Authentication instead
3. Never transmit unencrypted passwords
4. Implement refresh tokens for sessions

## Testing the System

### Test Case 1: Register New Student
1. Go to `/register`
2. Fill in:
   - Name: "John Doe"
   - Phone: "9876543210"
   - Admission: "KGR23CS001"
   - Password: "password123"
3. Click Register
4. Should see success message
5. Check Firebase Console - data should appear in `students` collection

### Test Case 2: Verify with Credentials
1. Go to `/verify`
2. Select "Verify Credentials"
3. Enter:
   - Admission: "KGR23CS001"
   - Password: "password123"
4. Should see student details displayed

### Test Case 3: Cross-Check Details
1. Go to `/verify`
2. Select "Cross-Check Details"
3. Enter:
   - Admission: "KGR23CS001"
   - Name: "John Doe"
   - Phone: "9876543210"
4. Should see student details displayed

### Test Case 4: Invalid Details
1. Try registering with:
   - Invalid phone (too short)
   - Invalid admission number (wrong format)
   - Non-matching passwords
2. Should see appropriate error messages

## Dependencies Required

Ensure these are in `pubspec.yaml`:
```yaml
provider: ^6.1.5+1
cloud_firestore: ^6.5.0
firebase_core: ^4.10.0
```

## File Structure

```
lib/
├── models/
│   └── student.dart
├── services/
│   ├── database_service.dart
│   └── student_validation_service.dart
├── providers/
│   └── student_provider.dart
├── screens/
│   ├── request_letter/
│   │   └── student_registration/
│   │       └── student_registration.dart (updated)
│   └── student_verification/
│       └── student_verification.dart (new)
└── main.dart (updated)
```

## Future Enhancements

Possible improvements:
1. Add password hashing with `crypto` package
2. Implement Firebase Authentication
3. Add email verification
4. Add student profile management
5. Add export/import student data
6. Add admin dashboard
7. Implement role-based access control
8. Add audit logs for registrations

---

**Created**: June 2, 2026
**System**: Student Registration & Validation with Firebase Firestore
