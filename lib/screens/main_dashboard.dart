import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/haptic_utils.dart';
import 'upload_data_screen.dart';
import 'evaluation_metrics_screen.dart';
import 'explainability_screen.dart';
import 'medicine_reminder_screen.dart';
import 'diet_plan_tab.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  String _userName = '';
  String _gender = '';
  String _location = '';
  int _age = 0;
  double? _height;
  double? _weight;
  double? _bmi;
  String _bmiCategory = '';
  bool _underlyingAllergies = false;
  bool _drink = false;
  bool _smoke = false;
  bool _t2diabetes = false;
  bool _hypertension = false;
  bool _cvd = false;

  @override
  void initState() {
    super.initState();
    _loadProfileFromPrefs();
  }

  Future<void> _loadProfileFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name') ?? '';
        _gender = prefs.getString('gender') ?? '';
        _location = prefs.getString('location') ?? '';
        _age = int.tryParse(prefs.getString('age') ?? '') ?? 0;
        _weight = double.tryParse(prefs.getString('weight') ?? '');
        _height = double.tryParse(prefs.getString('height') ?? '');
        _bmi = prefs.getDouble('bmi');
        _bmiCategory = prefs.getString('bmi_category') ?? '';
        _underlyingAllergies = prefs.getBool('underlying_allergies') ?? false;
        _drink = prefs.getBool('drink') ?? false;
        _smoke = prefs.getBool('smoke') ?? false;
        _t2diabetes = prefs.getBool('t2diabetes') ?? false;
        _hypertension = prefs.getBool('hypertension') ?? false;
        _cvd = prefs.getBool('cvd') ?? false;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildProfileScreen(),
          const UploadDataScreen(),
          const EvaluationMetricsScreen(),
          const ExplainabilityScreen(),
          _buildDietPlanTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) async {
          await HapticUtils.selectionClick();
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Metrics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Explain',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Diet Plan',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'CareSight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AI Risk Prediction',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.upload_file,
            title: 'Upload Data',
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.analytics,
            title: 'Evaluation Metrics',
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.psychology,
            title: 'Explainability',
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.medication,
            title: 'Medicine Reminders',
            onTap: () async {
              await HapticUtils.lightImpact();
              if (mounted) {
                Navigator.pop(context);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            const MedicineReminderScreen(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastEaseInToSlowEaseOut,
                          ),
                        ),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                );
              }
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // Handle settings
            },
          ),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              // Handle help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildProfileScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFF7FFF8)],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfileFromPrefs,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 100,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildProfileHeader(),
                const SizedBox(height: 16),
                _buildInfoCards(),
                const SizedBox(height: 16),
                _buildHealthFlags(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDietPlanTab() {
    return const DietPlanTabView();
  }

  Widget _buildInfoCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        int crossAxisCount;
        if (maxW < 340) {
          crossAxisCount = 1;
        } else if (maxW < 700) {
          crossAxisCount = 2;
        } else if (maxW < 1000) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 4;
        }
        final items = [
          _InfoItem('Age', _age > 0 ? '$_age yrs' : '—', Icons.cake),
          _InfoItem('Gender', _gender.isNotEmpty ? _gender : '—', Icons.wc),
          _InfoItem(
            'Height',
            _height != null ? '${_height!.toStringAsFixed(0)} cm' : '—',
            Icons.height,
          ),
          _InfoItem(
            'Weight',
            _weight != null ? '${_weight!.toStringAsFixed(0)} kg' : '—',
            Icons.monitor_weight,
          ),
          _InfoItem(
            'Location',
            _location.isNotEmpty ? _location : '—',
            Icons.location_on,
          ),
          _InfoItem(
            'BMI',
            _bmi != null
                ? '${_bmi!.toStringAsFixed(1)}${_bmiCategory.isNotEmpty ? ' • $_bmiCategory' : ''}'
                : '—',
            Icons.assessment,
          ),
        ];

        // Choose aspect ratio responsively to avoid vertical overflow on short screens
        double childAspectRatio;
        if (maxW < 340) {
          childAspectRatio = 1.8; // more height on extra-narrow screens
        } else if (maxW < 400) {
          childAspectRatio = 2.0;
        } else if (maxW < 700) {
          childAspectRatio = 2.0; // ensure no vertical overflow on phones
        } else if (maxW < 1000) {
          childAspectRatio = 3.0;
        } else {
          childAspectRatio = 3.2;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final it = items[index];
              return _statCard(it.title, it.value, it.icon);
            },
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textLight.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthFlags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final useSingleColumn = maxW < 400;
          final tileW =
              useSingleColumn ? maxW : (maxW - 12) / 2; // responsive columns
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.health_and_safety, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'Health Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _flagTile('Allergies', _underlyingAllergies, width: tileW),
                  _flagTile('Drinks', _drink, width: tileW),
                  _flagTile('Smokes', _smoke, width: tileW),
                  _flagTile('Type 2 Diabetes', _t2diabetes, width: tileW),
                  _flagTile('Hypertension', _hypertension, width: tileW),
                  _flagTile('CVD', _cvd, width: tileW),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _flagTile(String label, bool value, {double? width}) {
    final color = value ? AppColors.lightGreen : AppColors.textLight;
    final icon = value ? Icons.check_circle : Icons.remove_circle_outline;
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final hasProfile = _userName.isNotEmpty || _age > 0 || _gender.isNotEmpty;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.lightGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasProfile
                        ? (_userName.isEmpty ? 'Your Profile' : _userName)
                        : 'Complete your profile',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_age > 0) _buildPill('$_age y'),
                      if (_gender.isNotEmpty) _buildPill(_gender),
                      if (_location.isNotEmpty) _buildPill(_location),
                      if (_bmi != null && _bmi! > 0)
                        _buildPill(
                          'BMI ${_bmi!.toStringAsFixed(1)}${_bmiCategory.isNotEmpty ? ' • $_bmiCategory' : ''}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoItem {
  final String title;
  final String value;
  final IconData icon;
  _InfoItem(this.title, this.value, this.icon);
}
