import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/project_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../shared/custom_textfield.dart';
import '../shared/custom_button.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});
  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _techController = TextEditingController();
  UserModel? _selectedSupervisor;
  String _selectedCategory = 'General';
  DateTime? _deadline;
  final List<String> _technologies = [];

  static const List<String> categories = ['General', 'Web Development', 'Mobile App', 'Machine Learning', 'Data Science', 'IoT', 'Cybersecurity', 'Game Development', 'Cloud Computing', 'Other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchSupervisors();
    });
  }

  void _addTech() {
    final text = _techController.text.trim();
    if (text.isNotEmpty && !_technologies.contains(text)) {
      setState(() { _technologies.add(text); _techController.clear(); });
    }
  }

  void _pickDeadline() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (date != null) setState(() => _deadline = date);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSupervisor == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a supervisor'), backgroundColor: Color(0xFFEF4444)));
        return;
      }
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final pp = Provider.of<ProjectProvider>(context, listen: false);

      ProjectModel newProject = ProjectModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        technologies: _technologies,
        studentId: user!.uid,
        supervisorId: _selectedSupervisor!.uid,
        supervisorName: _selectedSupervisor!.name,
        status: 'pending',
        createdAt: DateTime.now(),
        category: _selectedCategory,
        deadline: _deadline,
      );

      bool success = await pp.addProject(newProject);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project created successfully!'), backgroundColor: Color(0xFF10B981)));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pp.errorMessage), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Project')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Project Details', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Fill in the details for your new project', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),

        CustomTextField(label: 'Project Title', controller: _titleController, prefixIcon: Icons.title, validator: (v) => v != null && v.isNotEmpty ? null : 'Required'),
        CustomTextField(label: 'Description', controller: _descController, prefixIcon: Icons.description_outlined, maxLines: 4, validator: (v) => v != null && v.isNotEmpty ? null : 'Required'),

        // Category
        Padding(padding: const EdgeInsets.only(bottom: 16), child: DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined, size: 20)),
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        )),

        // Technologies
        Row(children: [
          Expanded(child: CustomTextField(label: 'Add Technology', controller: _techController, prefixIcon: Icons.code)),
          const SizedBox(width: 8),
          Padding(padding: const EdgeInsets.only(bottom: 16), child: IconButton.filled(onPressed: _addTech, icon: const Icon(Icons.add, size: 20))),
        ]),
        if (_technologies.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 16), child: Wrap(spacing: 8, runSpacing: 8, children: _technologies.map((t) => Chip(
          label: Text(t), deleteIcon: const Icon(Icons.close, size: 16), onDeleted: () => setState(() => _technologies.remove(t)),
        )).toList())),

        // Deadline
        Padding(padding: const EdgeInsets.only(bottom: 16), child: InkWell(
          onTap: _pickDeadline,
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Deadline (optional)', prefixIcon: Icon(Icons.event, size: 20)),
            child: Text(_deadline != null ? DateFormat('MMM dd, yyyy').format(_deadline!) : 'Select a deadline', style: TextStyle(color: _deadline != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodySmall?.color)),
          ),
        )),

        // Supervisor
        Consumer<ProjectProvider>(builder: (context, provider, _) {
          if (provider.isLoading && provider.supervisors.isEmpty) return const Center(child: CircularProgressIndicator());
          return Padding(padding: const EdgeInsets.only(bottom: 16), child: DropdownButtonFormField<UserModel>(
            initialValue: _selectedSupervisor,
            decoration: const InputDecoration(labelText: 'Assign Supervisor', prefixIcon: Icon(Icons.supervisor_account, size: 20)),
            items: provider.supervisors.map((s) => DropdownMenuItem(value: s, child: Text(s.name, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _selectedSupervisor = v),
            validator: (v) => v == null ? 'Select a supervisor' : null,
          ));
        }),

        const SizedBox(height: 16),
        Consumer<ProjectProvider>(builder: (context, provider, _) => CustomButton(
          text: 'Create Project', icon: Icons.add_rounded, isLoading: provider.isLoading, onPressed: _submit,
        )),
        const SizedBox(height: 20),
      ])))),
    );
  }

  @override
  void dispose() { _titleController.dispose(); _descController.dispose(); _techController.dispose(); super.dispose(); }
}
