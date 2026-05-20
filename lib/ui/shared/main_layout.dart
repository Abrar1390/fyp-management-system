import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../student/student_dashboard.dart';
import '../supervisor/supervisor_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../student/projects_list_screen.dart';
import '../student/global_progress_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'app_drawer.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _sidebarExpanded = true;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const double _expandedWidth = 248;
  static const double _collapsedWidth = 72;

  // Teal-based brand color
  static const _brandColor = Color(0xFF0F9D8A);
  static const _brandLight = Color(0xFF14B8A6);

  // Nav items
  static const _navItems = [
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_rounded, 'Dashboard'),
    _NavItem(Icons.folder_rounded, Icons.folder_outlined, 'Projects'),
    _NavItem(Icons.timeline_rounded, Icons.timeline_outlined, 'Progress'),
    _NavItem(Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _sidebarAnimation =
        Tween<double>(begin: _expandedWidth, end: _collapsedWidth).animate(
      CurvedAnimation(parent: _sidebarController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _onItemSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
    if (_sidebarExpanded) {
      _sidebarController.reverse();
    } else {
      _sidebarController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isWide = MediaQuery.of(context).size.width > 820;

    if (user == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final isSupervisor = user.role == 'supervisor';
    final isAdmin = user.role == 'admin';

    Widget getDashboard() {
      if (isAdmin) return const AdminDashboard();
      if (isSupervisor) return const SupervisorDashboard();
      return const StudentDashboard();
    }

    final List<Widget> screens = [
      getDashboard(),
      const ProjectsListScreen(),
      const GlobalProgressScreen(),
      const SettingsScreen(),
    ];

    Widget buildPageTransition(Widget child) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: child,
        ),
      );
    }

    if (isWide) {
      return Scaffold(
        key: _scaffoldKey,
        body: Row(
          children: [
            AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, _) {
                final w = _sidebarAnimation.value;
                final expanded =
                    w > (_expandedWidth + _collapsedWidth) / 2;
                final textOpacity =
                    ((w - _collapsedWidth) / (_expandedWidth - _collapsedWidth))
                        .clamp(0.0, 1.0);

                return _PremiumSidebar(
                  width: w,
                  expanded: expanded,
                  textOpacity: textOpacity,
                  currentIndex: _currentIndex,
                  navItems: _navItems,
                  onItemSelected: _onItemSelected,
                  onToggle: _toggleSidebar,
                  user: user,
                );
              },
            ),

            // Main content
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    title: _navItems[_currentIndex].label,
                    userName: user.name,
                  ),
                  Expanded(
                    child: buildPageTransition(screens[_currentIndex]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(_navItems[_currentIndex].label),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: _AvatarButton(user: user),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onItemSelected: _onItemSelected,
      ),
      body: buildPageTransition(screens[_currentIndex]),
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemSelected,
        items: _navItems,
      ),
    );
  }
}

// ─── Premium Sidebar ────────────────────────────────────────────────────────

class _PremiumSidebar extends StatelessWidget {
  final double width;
  final bool expanded;
  final double textOpacity;
  final int currentIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onToggle;
  final dynamic user;

  const _PremiumSidebar({
    required this.width,
    required this.expanded,
    required this.textOpacity,
    required this.currentIndex,
    required this.navItems,
    required this.onItemSelected,
    required this.onToggle,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1320) : const Color(0xFFFFFFFF);
    final borderColor =
        isDark ? const Color(0xFF1A2640) : const Color(0xFFE8EDF5);

    return Container(
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ─── Logo header ──────────────────────────────────────
          SizedBox(
            height: 72,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                    child: Row(
                      children: [
                        _LogoMark(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Opacity(
                            opacity: textOpacity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FYP Manager',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip),
                                Text('Academic Platform',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontSize: 10),
                                    maxLines: 1),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onToggle,
                          icon: Icon(Icons.menu_open_rounded,
                              size: 20,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color),
                          tooltip: 'Collapse sidebar',
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: IconButton(
                      onPressed: onToggle,
                      icon: const Icon(Icons.menu_rounded, size: 22),
                      tooltip: 'Expand sidebar',
                    ),
                  ),
          ),

          Container(
              height: 1,
              color: isDark
                  ? const Color(0xFF1A2640)
                  : const Color(0xFFEEF2F6)),
          const SizedBox(height: 8),

          // ─── Nav items ────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                return _SidebarItem(
                  item: navItems[index],
                  isSelected: currentIndex == index,
                  expanded: expanded,
                  textOpacity: textOpacity,
                  onTap: () => onItemSelected(index),
                  delay: index * 30,
                );
              },
            ),
          ),

          // ─── User footer ──────────────────────────────────────
          Container(
              height: 1,
              color: isDark
                  ? const Color(0xFF1A2640)
                  : const Color(0xFFEEF2F6)),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: _UserFooter(
                user: user,
                expanded: expanded,
                textOpacity: textOpacity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F9D8A), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F9D8A).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final bool expanded;
  final double textOpacity;
  final VoidCallback onTap;
  final int delay;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.expanded,
    required this.textOpacity,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  static const _teal = Color(0xFF0F9D8A);
  static const _tealLight = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark
        ? _teal.withOpacity(0.10)
        : _teal.withOpacity(0.06);
    final hoverBg = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.black.withOpacity(0.03);

    if (!widget.expanded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Tooltip(
          message: widget.item.label,
          preferBelow: false,
          waitDuration: const Duration(milliseconds: 300),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? selectedBg
                      : (_hovered ? hoverBg : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    widget.isSelected
                        ? widget.item.selectedIcon
                        : widget.item.icon,
                    size: 20,
                    color: widget.isSelected
                        ? _teal
                        : (_hovered
                            ? _teal.withOpacity(0.7)
                            : Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? selectedBg
                  : (_hovered ? hoverBg : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Simple icon — no gradient box
                Icon(
                  widget.isSelected
                      ? widget.item.selectedIcon
                      : widget.item.icon,
                  size: 20,
                  color: widget.isSelected
                      ? _teal
                      : (_hovered
                          ? _teal.withOpacity(0.7)
                          : Theme.of(context).textTheme.bodySmall?.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Opacity(
                    opacity: widget.textOpacity,
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: widget.isSelected
                            ? _teal
                            : (_hovered
                                ? Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
                // Active indicator — thin teal bar
                if (widget.isSelected)
                  Opacity(
                    opacity: widget.textOpacity,
                    child: Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 300.ms);
  }
}

class _UserFooter extends StatelessWidget {
  final dynamic user;
  final bool expanded;
  final double textOpacity;

  const _UserFooter({
    required this.user,
    required this.expanded,
    required this.textOpacity,
  });

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0F9D8A);

    return Padding(
      padding: EdgeInsets.all(expanded ? 14 : 10),
      child: expanded
          ? Row(
              children: [
                _UserAvatar(user: user, radius: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Opacity(
                    opacity: textOpacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: teal,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(child: _UserAvatar(user: user, radius: 17)),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final dynamic user;
  final double radius;
  const _UserAvatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF0F9D8A), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        radius: radius - 2,
        backgroundColor: const Color(0xFF0F9D8A),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.85,
          ),
        ),
      ),
    );
  }
}

// ─── Top Bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final String userName;

  const _TopBar({
    required this.title,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const teal = Color(0xFF0F9D8A);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Title with teal dot
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: teal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          const Spacer(),
          // Theme toggle quick-access
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final isDark = themeProvider.currentTheme != ThemeType.light;
              return Tooltip(
                message: isDark ? 'Switch to Light' : 'Switch to Dark',
                child: IconButton(
                  onPressed: () {
                    themeProvider.setTheme(
                      isDark ? ThemeType.light : ThemeType.dark,
                    );
                  },
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 20,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          if (user != null)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? teal.withOpacity(0.1)
                        : const Color(0xFFE6F7F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: teal.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _UserAvatar(user: user, radius: 10),
                      const SizedBox(width: 8),
                      Text(
                        userName.split(' ').first,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  final dynamic user;
  const _AvatarButton({required this.user});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 17,
      backgroundColor: const Color(0xFF0F9D8A),
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14),
      ),
    );
  }
}

// ─── Premium Bottom Nav ─────────────────────────────────────────────────────

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const teal = Color(0xFF0F9D8A);
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? const Color(0xFF0D1320) : Colors.white,
        border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: selected
                              ? BoxDecoration(
                                  color: teal.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: Icon(
                            selected ? items[i].selectedIcon : items[i].icon,
                            size: 22,
                            color: selected
                                ? teal
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: selected
                                ? teal
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Data class ─────────────────────────────────────────────────────────────

class _NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;
  const _NavItem(this.selectedIcon, this.icon, this.label);
}
