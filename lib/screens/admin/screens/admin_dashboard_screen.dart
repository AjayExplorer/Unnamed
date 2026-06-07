import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../../request_letter/faculty/models/faculty_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF174EA6)),
            onPressed: () {
              context.read<AdminProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Logout',
          ),
        ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: primaryBlue,
            labelColor: primaryBlue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Add Faculty'),
              Tab(text: 'Faculty'),
              Tab(text: 'Alerts'),
            ],
          ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(provider),
          _buildAddFacultyTab(provider),
          _buildFacultyManagementTab(provider),
          _buildAlertsTab(provider),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(AdminProvider provider) {
    const primaryBlue = Color(0xFF174EA6);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMetricCard('Faculty', provider.facultyCount.toString(), primaryBlue),
                        const SizedBox(height: 12),
                        _buildMetricCard('Alerts', provider.allAlerts.length.toString(), primaryBlue),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildMetricCard('Faculty', provider.facultyCount.toString(), primaryBlue)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMetricCard('Alerts', provider.allAlerts.length.toString(), primaryBlue)),
                      ],
                    ),
              const SizedBox(height: 24),
              const Text('Quick Stats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Total Faculty Members: ${provider.allFaculty.length}'),
              Text('Active Alerts: ${provider.allAlerts.length}'),
              const SizedBox(height: 28),
              const Text('Transport & Bus Tracking Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pushNamed(context, '/admin_driver_registration');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          child: Column(
                            children: [
                              Icon(Icons.person_add_alt, color: primaryBlue, size: 28),
                              SizedBox(height: 8),
                              Text(
                                'Register Driver',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryBlue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pushNamed(context, '/admin_bus_registration');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          child: Column(
                            children: [
                              Icon(Icons.directions_bus_filled, color: primaryBlue, size: 28),
                              SizedBox(height: 8),
                              Text(
                                'Register Bus & Route',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryBlue),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }



  Widget _buildAddFacultyTab(AdminProvider provider) {
    return _AddFacultyForm(provider: provider);
  }

  Widget _buildFacultyManagementTab(AdminProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.allFaculty.isEmpty) {
      return const Center(child: Text('No faculty members registered.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: provider.allFaculty.length,
        separatorBuilder: (context, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final faculty = provider.allFaculty[index];
          return _buildFacultyCard(faculty, provider);
        },
      ),
    );
  }

  Widget _buildAlertsTab(AdminProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.allAlerts.isEmpty) {
      return const Center(child: Text('No alerts posted.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: provider.allAlerts.length,
        separatorBuilder: (context, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alert = provider.allAlerts[index];
          return _buildAlertCard(alert, provider);
        },
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF667085), fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: primaryBlue, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }



  Widget _buildFacultyCard(Faculty faculty, AdminProvider provider) {
    final Color statusColor = faculty.availabilityStatus.toLowerCase() == 'on leave'
        ? const Color(0xFFDC2626)
        : const Color(0xFF059669);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(faculty.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('${faculty.designation} • ${faculty.department}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    faculty.availabilityStatus,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Username: ${faculty.username}', style: const TextStyle(fontSize: 12)),
            Text('Email: ${faculty.email}', style: const TextStyle(fontSize: 12)),
            Text('Phone: ${faculty.phone}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showEditFacultyDialog(faculty, provider),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleDeleteFaculty(faculty, provider),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDC2626)),
                    ),
                    child: const Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, AdminProvider provider) {
    final DateTime createdAt = (alert['postedAt'] is String)
        ? DateTime.parse(alert['postedAt'])
        : (alert['postedAt'] as dynamic).toDate();

    final formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(createdAt);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert['author'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(alert['category'] ?? 'General', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(alert['details'] ?? 'No content', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _handleDeleteAlert(alert['id'], provider),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDC2626)),
                  ),
                  child: const Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  void _handleDeleteFaculty(Faculty faculty, AdminProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Faculty'),
          content: Text('Are you sure you want to delete ${faculty.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final success = await provider.deleteFaculty(faculty.facultyId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty deleted successfully.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Error deleting faculty.')));
      }
    }
  }

  void _handleDeleteAlert(String alertId, AdminProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Alert'),
          content: const Text('Are you sure you want to delete this alert?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final success = await provider.deleteAlert(alertId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert deleted successfully.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Error deleting alert.')));
      }
    }
  }

  void _showEditFacultyDialog(Faculty faculty, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _EditFacultyDialog(faculty: faculty, provider: provider),
    );
  }
}

class _AddFacultyForm extends StatefulWidget {
  final AdminProvider provider;

  const _AddFacultyForm({required this.provider});

  @override
  State<_AddFacultyForm> createState() => _AddFacultyFormState();
}

class _AddFacultyFormState extends State<_AddFacultyForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _designationController;
  late TextEditingController _departmentController;
  late TextEditingController _passwordController;
  String _selectedRole = 'teacher';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _designationController = TextEditingController();
    _departmentController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final faculty = Faculty(
        facultyId: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        designation: _designationController.text.trim(),
        department: _departmentController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        availabilityStatus: 'Present',
        role: _selectedRole == 'teacher'
            ? FacultyRole.teacher
            : _selectedRole == 'hod'
                ? FacultyRole.hod
                : _selectedRole == 'driver'
                    ? FacultyRole.driver
                    : FacultyRole.principal,
      );

      final success = await widget.provider.addFaculty(faculty);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty added successfully.')));
        _formKey.currentState!.reset();
        _nameController.clear();
        _usernameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _designationController.clear();
        _departmentController.clear();
        _passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.provider.errorMessage ?? 'Error adding faculty.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Faculty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Faculty Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter faculty name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter username' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter email';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Please enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter phone number' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'hod', child: Text('HOD')),
                DropdownMenuItem(value: 'principal', child: Text('Principal')),
                DropdownMenuItem(value: 'driver', child: Text('Driver')),
              ],
              onChanged: (value) => setState(() => _selectedRole = value ?? 'teacher'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _designationController,
              decoration: InputDecoration(
                labelText: 'Designation',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter designation' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter department' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              obscureText: true,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter password' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Add Faculty'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditFacultyDialog extends StatefulWidget {
  final Faculty faculty;
  final AdminProvider provider;

  const _EditFacultyDialog({required this.faculty, required this.provider});

  @override
  State<_EditFacultyDialog> createState() => _EditFacultyDialogState();
}

class _EditFacultyDialogState extends State<_EditFacultyDialog> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _designationController;
  late TextEditingController _departmentController;
  late TextEditingController _passwordController;
  late String _selectedRole;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.faculty.name);
    _usernameController = TextEditingController(text: widget.faculty.username);
    _emailController = TextEditingController(text: widget.faculty.email);
    _phoneController = TextEditingController(text: widget.faculty.phone);
    _designationController = TextEditingController(text: widget.faculty.designation);
    _departmentController = TextEditingController(text: widget.faculty.department);
    _passwordController = TextEditingController(text: widget.faculty.password);
    _selectedRole = widget.faculty.role.toString().split('.').last;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      final updatedFaculty = Faculty(
        facultyId: widget.faculty.facultyId,
        name: _nameController.text.trim(),
        designation: _designationController.text.trim(),
        department: _departmentController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        availabilityStatus: widget.faculty.availabilityStatus,
        role: _selectedRole == 'teacher'
            ? FacultyRole.teacher
            : _selectedRole == 'hod'
                ? FacultyRole.hod
                : _selectedRole == 'driver'
                    ? FacultyRole.driver
                    : FacultyRole.principal,
      );

      final success = await widget.provider.updateFaculty(updatedFaculty);

      if (!mounted) return;
      Navigator.of(context).pop();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty updated successfully.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.provider.errorMessage ?? 'Error updating faculty.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 480,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Faculty Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
                              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'hod', child: Text('HOD')),
                DropdownMenuItem(value: 'principal', child: Text('Principal')),
                DropdownMenuItem(value: 'driver', child: Text('Driver')),
              ],
              onChanged: (value) => setState(() => _selectedRole = value ?? 'teacher'),
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _designationController,
              decoration: InputDecoration(
                labelText: 'Designation',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _departmentController,
              decoration: InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  }
}

