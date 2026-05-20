import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../shared/project_card.dart';
import 'project_details_screen.dart';
import '../shared/empty_state_widget.dart';
import 'add_project_screen.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});
  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _sortBy = 'newest';
  bool _gridView = false;
  final _searchFocus = FocusNode();

  static const _filters = ['All', 'Pending', 'In Progress', 'Completed'];
  static const _filterValues = ['All', 'pending', 'in_progress', 'completed'];
  static const _filterColors = [
    Color(0xFF0F9D8A),
    Color(0xFFF59E0B),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        if (user.role == 'supervisor') {
          Provider.of<ProjectProvider>(context, listen: false)
              .listenToSupervisorProjects(user.uid);
        } else {
          Provider.of<ProjectProvider>(context, listen: false)
              .listenToStudentProjects(user.uid);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Search + Filter Bar ───────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              // Search row
              Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _searchFocus.hasFocus
                              ? const Color(0xFF0F9D8A)
                              : Theme.of(context).dividerColor,
                          width: _searchFocus.hasFocus ? 1.5 : 1,
                        ),
                      ),
                      child: TextField(
                        focusNode: _searchFocus,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search projects...',
                          prefixIcon: Icon(Icons.search_rounded,
                              size: 20,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 14),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 18),
                                  onPressed: () =>
                                      setState(() => _searchQuery = ''),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sort button
                  PopupMenuButton<String>(
                    onSelected: (v) => setState(() => _sortBy = v),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Theme.of(context).dividerColor),
                      ),
                      child: Icon(Icons.sort_rounded,
                          size: 20,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color),
                    ),
                    itemBuilder: (_) => [
                      _popItem('newest', Icons.schedule_rounded, 'Newest First'),
                      _popItem('oldest', Icons.history_rounded, 'Oldest First'),
                      _popItem('name', Icons.sort_by_alpha_rounded, 'By Name'),
                      _popItem('progress', Icons.trending_up_rounded, 'By Progress'),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Grid/List toggle
                  GestureDetector(
                    onTap: () => setState(() => _gridView = !_gridView),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _gridView
                            ? const Color(0xFF0F9D8A).withOpacity(0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _gridView
                              ? const Color(0xFF0F9D8A).withOpacity(0.3)
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Icon(
                        _gridView ? Icons.grid_view_rounded : Icons.list_rounded,
                        size: 20,
                        color: _gridView
                            ? const Color(0xFF0F9D8A)
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    final selected = _selectedStatus == _filterValues[i];
                    return Padding(
                      padding: EdgeInsets.only(right: i < _filters.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedStatus = _filterValues[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? _filterColors[i]
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? _filterColors[i]
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // ── Project List ─────────────────────────────────────
        Expanded(
          child: Consumer<ProjectProvider>(builder: (context, pp, _) {
            var projects = pp.projects.where((p) {
              final matchSearch = p.title
                      .toLowerCase()
                      .contains(_searchQuery) ||
                  p.description.toLowerCase().contains(_searchQuery);
              final matchStatus = _selectedStatus == 'All' ||
                  p.status == _selectedStatus;
              return matchSearch && matchStatus;
            }).toList();

            if (_sortBy == 'newest') {
              projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            } else if (_sortBy == 'oldest') {
              projects.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            } else if (_sortBy == 'name') {
              projects.sort((a, b) => a.title.compareTo(b.title));
            } else if (_sortBy == 'progress') {
              projects.sort((a, b) =>
                  b.progressPercentage.compareTo(a.progressPercentage));
            }

            if (projects.isEmpty) {
              return EmptyStateWidget(
                icon: _searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.folder_off_outlined,
                title: _searchQuery.isNotEmpty
                    ? 'No results for "$_searchQuery"'
                    : 'No Projects Found',
                subtitle: _searchQuery.isNotEmpty
                    ? 'Try a different search term'
                    : 'Adjust your filters or create a new project',
                actionLabel: _searchQuery.isEmpty ? 'New Project' : null,
                onAction: _searchQuery.isEmpty
                    ? () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AddProjectScreen()))
                    : null,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              physics: const BouncingScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (ctx, i) => ProjectCard(
                project: projects[i],
                delay: i * 50,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ProjectDetailsScreen(project: projects[i])),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  PopupMenuItem<String> _popItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18,
            color: _sortBy == value
                ? const Color(0xFF0F9D8A)
                : Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                fontWeight: _sortBy == value
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: _sortBy == value
                    ? const Color(0xFF0F9D8A)
                    : null)),
      ]),
    );
  }
}
