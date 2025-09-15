import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../utils/haptic_utils.dart';
import '../services/user_api_service.dart';
import 'main_dashboard.dart';

class HealthRecordsScreen extends StatefulWidget {
  final String userName;

  const HealthRecordsScreen({super.key, required this.userName});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Form data
  String _gender = '';
  bool _underlyingAllergies = false;
  bool _drink = false;
  bool _smoke = false;
  bool _t2diabetes = false;
  bool _hypertension = false;
  bool _cvd = false;

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pageController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      // Changed to 4 pages total
      HapticUtils.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticUtils.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }

  Future<void> _saveHealthData() async {
    if (_formKey.currentState!.validate()) {
      await HapticUtils.mediumImpact();

      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();

        // Save all health data in the required format
        await prefs.setString('age', _ageController.text);
        await prefs.setString('weight', _weightController.text);
        await prefs.setString('height', _heightController.text);
        await prefs.setString('gender', _gender);
        await prefs.setString('location', _locationController.text);
        await prefs.setBool('underlying_allergies', _underlyingAllergies);
        await prefs.setBool('drink', _drink);
        await prefs.setBool('smoke', _smoke);
        await prefs.setBool('t2diabetes', _t2diabetes);
        await prefs.setBool('hypertension', _hypertension);
        await prefs.setBool('cvd', _cvd);

        // Calculate and store BMI
        final weight = double.tryParse(_weightController.text) ?? 0;
        final height = double.tryParse(_heightController.text) ?? 0;
        if (weight > 0 && height > 0) {
          final bmi = weight / ((height / 100) * (height / 100));
          await prefs.setDouble('bmi', bmi);
          await prefs.setString('bmi_category', _getBMICategory(bmi));
        }

        // Submit data to API
        final apiResponse = await UserApiService.submitUserData();

        // Feedback based on API response
        if (apiResponse.success) {
          await HapticUtils.success();
        } else {
          await HapticUtils.error();
        }

        // Show submission status
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(apiResponse.message),
              backgroundColor:
                  apiResponse.success
                      ? AppColors.lightGreen
                      : AppColors.riskYellow,
              duration: const Duration(seconds: 3),
              action:
                  !apiResponse.success
                      ? SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () async {
                          final retryResponse =
                              await UserApiService.retrySubmission();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(retryResponse.message),
                                backgroundColor:
                                    retryResponse.success
                                        ? AppColors.lightGreen
                                        : AppColors.riskOrange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      )
                      : null,
            ),
          );
        }

        // Navigate to main dashboard after health data collection
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const MainDashboard(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.fastEaseInToSlowEaseOut,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 1000),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        await HapticUtils.error();
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      await HapticUtils.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Health Profile - ${widget.userName}'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading:
            _currentPage > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousPage,
                )
                : null,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            index <= _currentPage
                                ? AppColors.primaryGreen
                                : AppColors.textLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildAllergicConditionsPage(),
                  _buildSubstanceAbusePage(),
                  _buildChronicConditionsPage(),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  if (_currentPage > 0) const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : (_currentPage < 3
                                  ? _nextPage
                                  : _saveHealthData),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                _currentPage < 3 ? 'Next' : 'Complete Setup',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about yourself to get personalized recommendations',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Age
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              hint: 'Enter your age',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your age';
                }
                final age = int.tryParse(value);
                if (age == null || age < 1 || age > 120) {
                  return 'Please enter a valid age';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Gender
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children:
                  ['Male', 'Female', 'Other'].map((gender) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(gender),
                          selected: _gender == gender,
                          onSelected: (selected) {
                            HapticUtils.selectionClick();
                            setState(() {
                              _gender = selected ? gender : '';
                            });
                          },
                          selectedColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            color:
                                _gender == gender
                                    ? Colors.white
                                    : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // Weight
            _buildTextField(
              controller: _weightController,
              label: 'Weight (kg)',
              hint: 'Enter your weight',
              icon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your weight';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight < 20 || weight > 300) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger BMI recalculation
              },
            ),

            const SizedBox(height: 16),

            // Height
            _buildTextField(
              controller: _heightController,
              label: 'Height (cm)',
              hint: 'Enter your height',
              icon: Icons.height,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your height';
                }
                final height = double.tryParse(value);
                if (height == null || height < 50 || height > 250) {
                  return 'Please enter a valid height';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger BMI recalculation
              },
            ),

            const SizedBox(height: 24),

            // BMI Display (if both height and weight are entered)
            _buildBMIDisplay(),

            const SizedBox(height: 16),

            // Location
            _buildTextField(
              controller: _locationController,
              label: 'Location (City, Country)',
              hint: 'Enter your location',
              icon: Icons.location_on,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIDisplay() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight != null && height != null && weight > 0 && height > 0) {
      final bmi = weight / ((height / 100) * (height / 100));
      final category = _getBMICategory(bmi);
      final color = _getBMIColor(bmi);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: color),
                const SizedBox(width: 8),
                const Text(
                  'BMI Calculator',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'BMI: ${bmi.toStringAsFixed(1)} - $category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return AppColors.riskOrange;
    if (bmi < 25) return AppColors.lightGreen;
    if (bmi < 30) return AppColors.riskYellow;
    return AppColors.highRisk;
  }

  Widget _buildAllergicConditionsPage() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allergic Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Do you have any underlying allergic conditions?',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),

            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.health_and_safety,
                      size: 60,
                      color: AppColors.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildYesNoButton('Yes', _underlyingAllergies, () {
                        HapticUtils.selectionClick();
                        setState(() {
                          _underlyingAllergies = true;
                        });
                      }),
                      _buildYesNoButton('No', !_underlyingAllergies, () {
                        HapticUtils.selectionClick();
                        setState(() {
                          _underlyingAllergies = false;
                        });
                      }),
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

  Widget _buildSubstanceAbusePage() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Substance Use',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This information helps us provide better health recommendations',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),

            // Drinking
            _buildHealthQuestion(
              'Do you drink alcohol?',
              Icons.local_bar,
              _drink,
              (value) {
                setState(() {
                  _drink = value;
                });
              },
            ),

            const SizedBox(height: 32),

            // Smoking
            _buildHealthQuestion('Do you smoke?', Icons.smoking_rooms, _smoke, (
              value,
            ) {
              setState(() {
                _smoke = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChronicConditionsPage() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chronic Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Do you have any of these chronic conditions?',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Type 2 Diabetes
            _buildHealthQuestion(
              'Do you have Type 2 Diabetes?',
              Icons.bloodtype,
              _t2diabetes,
              (value) {
                setState(() {
                  _t2diabetes = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Hypertension
            _buildHealthQuestion(
              'Do you have Hypertension?',
              Icons.monitor_heart,
              _hypertension,
              (value) {
                setState(() {
                  _hypertension = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Cardiovascular Disease
            _buildHealthQuestion(
              'Do you have Cardiovascular Disease?',
              Icons.favorite,
              _cvd,
              (value) {
                setState(() {
                  _cvd = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthQuestion(
    String question,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildYesNoButton('Yes', value, () {
                HapticUtils.selectionClick();
                onChanged(true);
              }),
              _buildYesNoButton('No', !value, () {
                HapticUtils.selectionClick();
                onChanged(false);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primaryGreen : Colors.white,
            foregroundColor: isSelected ? Colors.white : AppColors.primaryGreen,
            side: BorderSide(color: AppColors.primaryGreen, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
