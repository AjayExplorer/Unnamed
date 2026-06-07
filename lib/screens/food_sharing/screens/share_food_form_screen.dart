import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/student_provider.dart';
import '../models/food_post.dart';
import '../services/food_sharing_service.dart';

class ShareFoodFormScreen extends StatefulWidget {
  const ShareFoodFormScreen({super.key});

  @override
  State<ShareFoodFormScreen> createState() => _ShareFoodFormScreenState();
}

class _ShareFoodFormScreenState extends State<ShareFoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FoodSharingService();

  String _foodType = 'Veg';
  TimeOfDay? _selectedTime;
  String _pickupTimeString = '';
  final _placeController = TextEditingController();
  final _phoneController = TextEditingController();
  String _sharedByName = '';

  bool _isSubmitting = false;

  final List<String> _locationSuggestions = const [
    'College Canteen',
    'Kailasam',
    'Main Block',
    'First Year Block',
    'Auditorium',
    'Library ',
    'CS Department',
    'EC Department',
    'Electrical Department',
    'Civil Department',
    'Hostel ',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-fetch logged-in student name and phone number
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final student = studentProvider.currentStudent;
      if (student != null) {
        setState(() {
          _sharedByName = student.fullName;
          _phoneController.text = student.phoneNumber;
        });
      }
    });
  }

  @override
  void dispose() {
    _placeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C5E3B), // minty green primary
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final formatted = DateFormat('hh:mm a').format(dt);

      setState(() {
        _selectedTime = pickedTime;
        _pickupTimeString = formatted;
      });
    }
  }

  DateTime _calculatePickupTimestamp(TimeOfDay tod) {
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    
    // If the selected pickup time has already passed today, assume it is for tomorrow
    if (dt.isBefore(now)) {
      dt = dt.add(const Duration(days: 1));
    }
    return dt;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pickup time'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final pickupTimestamp = _calculatePickupTimestamp(_selectedTime!);
      final foodPost = FoodPost(
        foodType: _foodType,
        pickupTime: _pickupTimeString,
        pickupTimestamp: pickupTimestamp,
        pickupPlace: _placeController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        sharedBy: _sharedByName.isEmpty ? 'Student' : _sharedByName,
      );

      await _service.addFoodPost(foodPost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Food post shared successfully!'),
              ],
            ),
            backgroundColor: Color(0xFF2C5E3B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share food: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F7),
      appBar: AppBar(
        title: const Text(
          'Share Excess Food',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F3E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF2C5E3B)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sharing food helps reduce waste and supports fellow students. Ensure food is safe to consume.',
                          style: TextStyle(
                            color: const Color(0xFF2C5E3B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Food Type Selection
                Text(
                  'Food Type',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Veg'),
                        value: 'Veg',
                        groupValue: _foodType,
                        activeColor: const Color(0xFF2C5E3B),
                        onChanged: (value) {
                          setState(() {
                            _foodType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Non-Veg'),
                        value: 'Non-Veg',
                        groupValue: _foodType,
                        activeColor: const Color(0xFF2C5E3B),
                        onChanged: (value) {
                          setState(() {
                            _foodType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pickup Time Picker
                Text(
                  'Pickup Time',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectTime(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime == null
                              ? 'Select Pickup Time'
                              : 'Pickup: $_pickupTimeString',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedTime == null ? Colors.grey.shade600 : Colors.black,
                          ),
                        ),
                        const Icon(Icons.access_time_rounded, color: Color(0xFF2C5E3B)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Pickup Location Autocomplete/Textfield
                Text(
                  'Pickup Place',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _locationSuggestions;
                    }
                    return _locationSuggestions.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _placeController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    // Sync autocomplete controller with placeController
                    if (_placeController.text.isNotEmpty && controller.text.isEmpty) {
                      controller.text = _placeController.text;
                    }
                    controller.addListener(() {
                      _placeController.text = controller.text;
                    });
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'e.g. College Canteen',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2C5E3B), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a pickup place';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number
                Text(
                  'Contact Phone Number',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'e.g. 8078759239',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2C5E3B), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a phone number';
                    }
                    final cleanNum = value.replaceAll(RegExp(r'\D'), '');
                    if (cleanNum.length < 10) {
                      return 'Please enter a valid phone number (min 10 digits)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Shared By (Read Only)
                Text(
                  'Shared By',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _sharedByName.isEmpty ? 'Student' : _sharedByName,
                  key: ValueKey(_sharedByName),
                  enabled: false,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5E3B), // mint green
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Post',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
