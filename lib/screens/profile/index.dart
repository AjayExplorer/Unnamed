import 'package:flutter/material.dart';
import 'package:openpro/models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _placeController;
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _phoneController;
  late final TextEditingController _photoController;
  late final TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();

    final profile = userProfileNotifier.value;
    _nameController = TextEditingController(text: profile.name);
    _placeController = TextEditingController(text: profile.place);
    _bloodGroupController = TextEditingController(text: profile.bloodGroup);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _photoController = TextEditingController(text: profile.photoUrl);
    _departmentController = TextEditingController(text: profile.department);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _bloodGroupController.dispose();
    _phoneController.dispose();
    _photoController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: const Color(0xFFA4C3AC),
        foregroundColor: const Color(0xFF101828),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Center(
            child: Column(
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _photoController,
                  builder: (context, value, _) {
                    return CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFFD8ECE0),
                      backgroundImage: value.text.isEmpty
                          ? null
                          : NetworkImage(value.text),
                      child: value.text.isEmpty
                          ? const Icon(Icons.person, size: 44)
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Update your details',
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ProfileField(label: 'Name', controller: _nameController),
          _ProfileField(label: 'Place', controller: _placeController),
          _ProfileField(
            label: 'Blood Group',
            controller: _bloodGroupController,
          ),
          _ProfileField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          _ProfileField(
            label: 'Photo URL',
            controller: _photoController,
            keyboardType: TextInputType.url,
          ),
          _ProfileField(label: 'Department', controller: _departmentController),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                userProfileNotifier.value = userProfileNotifier.value.copyWith(
                  name: _nameController.text.trim(),
                  place: _placeController.text.trim(),
                  bloodGroup: _bloodGroupController.text.trim(),
                  phoneNumber: _phoneController.text.trim(),
                  photoUrl: _photoController.text.trim(),
                  department: _departmentController.text.trim(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF174EA6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF344054),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF174EA6),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
