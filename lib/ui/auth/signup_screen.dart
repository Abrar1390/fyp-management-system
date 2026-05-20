import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../shared/custom_textfield.dart';
import '../shared/custom_button.dart';
import '../shared/main_layout.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'student';
  String? _selectedDepartment;
  String? _selectedSemester;

  static const List<String> departments = [
    'Computer Science',
    'Software Engineering',
    'Information Technology',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Data Science',
    'Artificial Intelligence',
  ];

  static const List<String> semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match'), backgroundColor: Color(0xFFEF4444)),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
        department: _selectedDepartment,
        semester: _selectedRole == 'student' ? _selectedSemester : null,
      );

      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withOpacity(isDark ? 0.08 : 0.04),
              Theme.of(context).scaffoldBackgroundColor,
              primary.withOpacity(isDark ? 0.05 : 0.02),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                            const SizedBox(height: 8),
                            Text(
                              'Join the FYP Management Platform',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                            ).animate().fadeIn(delay: 100.ms),
                            const SizedBox(height: 32),

                            // Role Selection Cards
                            Text('I am a', style: Theme.of(context).textTheme.titleMedium)
                                .animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildRoleCard('student', Icons.school_rounded, 'Student')),
                                const SizedBox(width: 12),
                                Expanded(child: _buildRoleCard('supervisor', Icons.supervisor_account_rounded, 'Supervisor')),
                              ],
                            ).animate().fadeIn(delay: 300.ms),
                            const SizedBox(height: 24),

                            // Form Card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor.withOpacity(isDark ? 0.6 : 0.8),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                                  ),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        label: 'Full Name',
                                        controller: _nameController,
                                        prefixIcon: Icons.person_outline,
                                        validator: (val) => val != null && val.isNotEmpty ? null : 'Enter your name',
                                      ),
                                      CustomTextField(
                                        label: 'Email',
                                        controller: _emailController,
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (val) => val != null && val.contains('@') ? null : 'Enter a valid email',
                                      ),

                                      // Department Dropdown
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _selectedDepartment,
                                          decoration: const InputDecoration(
                                            labelText: 'Department',
                                            prefixIcon: Icon(Icons.business_outlined, size: 20),
                                          ),
                                          items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14)))).toList(),
                                          onChanged: (val) => setState(() => _selectedDepartment = val),
                                          validator: (val) => val == null ? 'Select your department' : null,
                                        ),
                                      ),

                                      // Semester Dropdown (only for students)
                                      if (_selectedRole == 'student')
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: DropdownButtonFormField<String>(
                                            initialValue: _selectedSemester,
                                            decoration: const InputDecoration(
                                              labelText: 'Semester',
                                              prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                                            ),
                                            items: semesters.map((s) => DropdownMenuItem(value: s, child: Text('Semester $s', style: const TextStyle(fontSize: 14)))).toList(),
                                            onChanged: (val) => setState(() => _selectedSemester = val),
                                            validator: (val) => val == null ? 'Select your semester' : null,
                                          ),
                                        ),

                                      CustomTextField(
                                        label: 'Password',
                                        controller: _passwordController,
                                        isPassword: true,
                                        prefixIcon: Icons.lock_outline,
                                        validator: (val) => val != null && val.length > 5 ? null : 'Password must be 6+ characters',
                                      ),
                                      CustomTextField(
                                        label: 'Confirm Password',
                                        controller: _confirmPasswordController,
                                        isPassword: true,
                                        prefixIcon: Icons.lock_outline,
                                        validator: (val) => val != null && val.length > 5 ? null : 'Confirm your password',
                                      ),
                                      const SizedBox(height: 8),
                                      Consumer<AuthProvider>(
                                        builder: (context, authProvider, child) {
                                          return CustomButton(
                                            text: 'Create Account',
                                            icon: Icons.person_add_outlined,
                                            isLoading: authProvider.isLoading,
                                            onPressed: _signup,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon, String label) {
    final isSelected = _selectedRole == role;
    final primary = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? primary : Theme.of(context).textTheme.bodySmall?.color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primary : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
