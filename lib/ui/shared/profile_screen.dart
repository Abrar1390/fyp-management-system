import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  static const List<String> departments = [
    'Computer Science', 'Software Engineering', 'Information Technology',
    'Electrical Engineering', 'Mechanical Engineering', 'Civil Engineering',
    'Data Science', 'Artificial Intelligence'
  ];
  static const List<String> semesters = ['1','2','3','4','5','6','7','8'];
  static const List<String> suggestedSkills = [
    'Flutter', 'Dart', 'Firebase', 'React', 'Node.js', 'Python',
    'Java', 'C++', 'Machine Learning', 'AI', 'MongoDB', 'SQL',
    'AWS', 'Docker', 'Git', 'REST API', 'UI/UX', 'Figma',
    'TensorFlow', 'Swift'
  ];

  static const _skillColors = [
    Color(0xFF0F9D8A), Color(0xFF10B981), Color(0xFF0EA5E9),
    Color(0xFF14B8A6), Color(0xFFF59E0B), Color(0xFFEC4899),
  ];



  void _editField(String field, String current,
      {bool isDropdown = false, List<String>? options}) {
    if (isDropdown && options != null) {
      String? selected = current == 'Not set' ? null : current;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Select $field', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(shrinkWrap: true, children: options.map((o) => ListTile(
                  title: Text(field == 'Semester' ? 'Semester $o' : o),
                  trailing: selected == o
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0F9D8A)) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await Provider.of<AuthProvider>(context, listen: false)
                        .updateProfile({field.toLowerCase(): o});
                  },
                )).toList()),
              ),
            ]),
          ),
        ),
      );
    } else {
      final controller = TextEditingController(text: current == 'Not set' ? '' : current);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Edit $field', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(controller: controller, decoration: InputDecoration(labelText: field),
                maxLines: field == 'Bio' ? 3 : 1, autofocus: true),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Provider.of<AuthProvider>(context, listen: false)
                      .updateProfile({field.toLowerCase(): controller.text.trim()});
                },
                child: const Text('Save Changes'),
              )),
          ]),
        ),
      );
    }
  }

  void _showSkillsEditor() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentSkills = List<String>.from(auth.user?.skills ?? []);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setBS) {
        return Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Manage Skills', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (currentSkills.isNotEmpty) ...[
              Wrap(spacing: 8, runSpacing: 8,
                children: currentSkills.asMap().entries.map((e) => Chip(
                  label: Text(e.value),
                  backgroundColor: _skillColors[e.key % _skillColors.length].withOpacity(0.12),
                  labelStyle: TextStyle(color: _skillColors[e.key % _skillColors.length], fontWeight: FontWeight.w600),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setBS(() => currentSkills.remove(e.value)),
                  side: BorderSide.none,
                )).toList()),
              const SizedBox(height: 16),
            ],
            Text('Add Skills', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8,
              children: suggestedSkills.where((s) => !currentSkills.contains(s)).map((s) =>
                ActionChip(
                  label: Text(s),
                  avatar: const Icon(Icons.add_rounded, size: 16),
                  onPressed: () => setBS(() => currentSkills.add(s)),
                )).toList()),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await auth.updateProfile({'skills': currentSkills});
                },
                child: const Text('Save Skills'),
              )),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0C1222) : const Color(0xFFF4F7F9),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          // ── Cover Banner + Avatar ─────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0A3D36), const Color(0xFF0D4A40)]
                        : [const Color(0xFF0F9D8A), const Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(children: [
                  Positioned(top: -30, right: -30, child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
                  )),
                ]),
              ),
              Positioned(
                bottom: -40,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0F9D8A), Color(0xFF10B981)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F9D8A).withOpacity(0.3), blurRadius: 12)],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF0F9D8A),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              ),
            ],
          ),

        const SizedBox(height: 52),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            // ── Name + Role ────────────────────────────────────
            Text(user.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: -0.5))
                .animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 4),
            Text(user.email, style: Theme.of(context).textTheme.bodySmall)
                .animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0F9D8A), Color(0xFF10B981)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(user.role.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.0)),
              ),
              if (user.department != null && user.department!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(user.department!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                ),
              ],
            ]).animate().fadeIn(delay: 200.ms),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(user.bio!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color, height: 1.5),
                  textAlign: TextAlign.center).animate().fadeIn(delay: 250.ms),
            ],
            const SizedBox(height: 20),

            // ── Stats Row ──────────────────────────────────────
            Consumer<ProjectProvider>(builder: (context, pp, _) {
              final projects = pp.projects;
              final completed = projects.where((p) => p.status == 'completed').length;
              final avgProg = projects.isEmpty ? 0.0
                  : projects.map((p) => p.progressPercentage).reduce((a,b) => a+b) / projects.length;
              return Row(children: [
                _StatBox(value: '${projects.length}', label: 'Projects',
                    icon: Icons.folder_rounded, color: const Color(0xFF0F9D8A)),
                const SizedBox(width: 10),
                _StatBox(value: '$completed', label: 'Completed',
                    icon: Icons.check_circle_rounded, color: const Color(0xFF10B981)),
                const SizedBox(width: 10),
                _StatBox(value: '${avgProg.toStringAsFixed(0)}%', label: 'Progress',
                    icon: Icons.speed_rounded, color: const Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                _StatBox(value: '${user.skills.length}', label: 'Skills',
                    icon: Icons.star_rounded, color: const Color(0xFF14B8A6)),
              ]);
            }).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 20),

            // ── Personal Info ──────────────────────────────────
            _SectionCard(
              title: 'Personal Info',
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF0F9D8A),
              actionIcon: Icons.edit_outlined,
              onAction: () => _editField('Name', user.name),
              children: [
                _infoRow(context, Icons.email_outlined, 'Email', user.email, color: const Color(0xFF0F9D8A)),
                _divider(context),
                _infoRow(context, Icons.business_outlined, 'Department', user.department ?? 'Not set',
                    color: const Color(0xFF0EA5E9),
                    onTap: () => _editField('Department', user.department ?? 'Not set',
                        isDropdown: true, options: departments)),
                _divider(context),
                if (user.role == 'student') ...[
                  _infoRow(context, Icons.school_outlined, 'Semester',
                      user.semester != null ? 'Semester ${user.semester}' : 'Not set',
                      color: const Color(0xFF10B981),
                      onTap: () => _editField('Semester', user.semester ?? 'Not set',
                          isDropdown: true, options: semesters)),
                  _divider(context),
                ],
                _infoRow(context, Icons.info_outline_rounded, 'Bio', user.bio ?? 'Not set',
                    color: const Color(0xFF14B8A6),
                    onTap: () => _editField('Bio', user.bio ?? 'Not set')),
              ],
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 14),

            // ── Skills ─────────────────────────────────────────
            _SectionCard(
              title: 'Skills & Technologies',
              icon: Icons.code_rounded,
              iconColor: const Color(0xFF10B981),
              actionIcon: Icons.add_rounded,
              onAction: _showSkillsEditor,
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: user.skills.isEmpty
                      ? Row(children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 16,
                              color: Theme.of(context).textTheme.bodySmall?.color),
                          const SizedBox(width: 8),
                          Text('Tap + to add your skills',
                              style: Theme.of(context).textTheme.bodySmall),
                        ])
                      : Wrap(
                          spacing: 8, runSpacing: 8,
                          children: user.skills.asMap().entries.map((e) {
                            final color = _skillColors[e.key % _skillColors.length];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: color.withOpacity(0.25)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 6, height: 6,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(e.value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                              ]),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 14),

            // ── Achievements ───────────────────────────────────
            _SectionCard(
              title: 'Achievements',
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFFF59E0B),
              actionIcon: Icons.add_rounded,
              onAction: () => _editField('Achievement', ''),
              children: [
                if (user.achievements.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Icon(Icons.emoji_events_outlined, size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                      const SizedBox(width: 8),
                      Text('No achievements yet. Keep working!',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  )
                else
                  ...user.achievements.map((a) => ListTile(
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 16),
                    ),
                    title: Text(a, style: Theme.of(context).textTheme.bodyMedium),
                  )),
              ],
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 40),
          ]),
        ),
      ]),
    ),
  );
}
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final IconData actionIcon;
  final VoidCallback onAction;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.actionIcon,
    required this.onAction,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 15),
            ),
            const SizedBox(width: 10),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(icon: Icon(actionIcon, size: 18), onPressed: onAction, color: iconColor),
          ]),
        ),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        ...children,
        const SizedBox(height: 4),
      ]),
    );
  }
}

Widget _infoRow(BuildContext context, IconData icon, String label, String value,
    {Color? color, VoidCallback? onTap}) {
  final c = color ?? Theme.of(context).primaryColor;
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(0),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(7)),
          child: Icon(icon, size: 15, color: c),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ])),
        if (onTap != null)
          Icon(Icons.chevron_right_rounded, size: 18,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4)),
      ]),
    ),
  );
}

Widget _divider(BuildContext context) =>
    Divider(height: 1, color: Theme.of(context).dividerColor);
