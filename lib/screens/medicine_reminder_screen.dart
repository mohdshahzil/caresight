import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_colors.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';
import '../utils/haptic_utils.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen>
    with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late final List<Medicine> _medicines;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _medicines = <Medicine>[];
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _initializeNotifications();
    _loadMedicines();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _loadMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicinesJson = prefs.getStringList('medicines') ?? [];

      _medicines.clear();
      for (final medicineJson in medicinesJson) {
        final medicine = Medicine.fromJson(json.decode(medicineJson));
        _medicines.add(medicine);
      }

      setState(() {
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicinesJson =
          _medicines.map((medicine) => json.encode(medicine.toJson())).toList();
      await prefs.setStringList('medicines', medicinesJson);
    } catch (e) {
      await HapticUtils.error();
    }
  }

  Future<void> _addMedicine() async {
    await HapticUtils.lightImpact();
    final medicine = await _showMedicineDialog();
    if (medicine != null) {
      setState(() {
        _medicines.add(medicine);
      });
      await _saveMedicines();
      await _notificationService.scheduleMedicineReminders(medicine);
      await HapticUtils.success();
    }
  }

  Future<void> _editMedicine(Medicine medicine) async {
    await HapticUtils.lightImpact();
    final updatedMedicine = await _showMedicineDialog(medicine: medicine);
    if (updatedMedicine != null) {
      final index = _medicines.indexWhere((m) => m.id == medicine.id);
      if (index != -1) {
        setState(() {
          _medicines[index] = updatedMedicine;
        });
        await _saveMedicines();
        await _notificationService.scheduleMedicineReminders(updatedMedicine);
        await HapticUtils.success();
      }
    }
  }

  Future<void> _deleteMedicine(Medicine medicine) async {
    await HapticUtils.mediumImpact();
    final confirmed = await _showDeleteConfirmation(medicine.name);
    if (confirmed) {
      setState(() {
        _medicines.removeWhere((m) => m.id == medicine.id);
      });
      await _saveMedicines();
      await _notificationService.cancelMedicineReminders(medicine.id);
      await HapticUtils.success();
    }
  }

  Future<void> _toggleMedicine(Medicine medicine) async {
    await HapticUtils.selectionClick();
    final updatedMedicine = medicine.copyWith(isActive: !medicine.isActive);
    final index = _medicines.indexWhere((m) => m.id == medicine.id);

    if (index != -1) {
      setState(() {
        _medicines[index] = updatedMedicine;
      });
      await _saveMedicines();

      if (updatedMedicine.isActive) {
        await _notificationService.scheduleMedicineReminders(updatedMedicine);
      } else {
        await _notificationService.cancelMedicineReminders(medicine.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addMedicine),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildMedicineList(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await HapticUtils.lightImpact();
            _addMedicine();
          },
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'Add Medicine',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your medicines...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineList() {
    if (_medicines.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          80,
        ), // Bottom padding for FAB
        itemCount: _medicines.length,
        itemBuilder: (context, index) {
          final medicine = _medicines[index];
          return _buildMedicineCard(medicine);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.medication,
              size: 80,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Medicine Reminders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add your first medicine reminder to never miss a dose',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addMedicine,
            icon: const Icon(Icons.add),
            label: const Text('Add Medicine'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            medicine.isActive
                ? AppColors.primaryGreen.withValues(alpha: 0.05)
                : AppColors.textLight.withValues(alpha: 0.03),
            medicine.isActive
                ? AppColors.lightGreen.withValues(alpha: 0.08)
                : AppColors.textLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              medicine.isActive
                  ? AppColors.primaryGreen.withValues(alpha: 0.3)
                  : AppColors.textLight.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                medicine.isActive
                    ? AppColors.primaryGreen.withValues(alpha: 0.1)
                    : AppColors.textLight.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _editMedicine(medicine),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            medicine.isActive
                                ? AppColors.primaryGreen
                                : AppColors.textLight,
                            medicine.isActive
                                ? AppColors.lightGreen
                                : AppColors.textLight.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                medicine.isActive
                                    ? AppColors.primaryGreen.withValues(
                                      alpha: 0.3,
                                    )
                                    : AppColors.textLight.withValues(
                                      alpha: 0.2,
                                    ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medication,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  medicine.isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.local_pharmacy,
                                size: 14,
                                color:
                                    medicine.isActive
                                        ? AppColors.textSecondary
                                        : AppColors.textLight,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  medicine.dosage,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        medicine.isActive
                                            ? AppColors.textSecondary
                                            : AppColors.textLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            medicine.isActive
                                ? AppColors.primaryGreen.withValues(alpha: 0.1)
                                : AppColors.textLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Switch(
                        value: medicine.isActive,
                        onChanged: (_) => _toggleMedicine(medicine),
                        activeColor: AppColors.primaryGreen,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color:
                            medicine.isActive
                                ? AppColors.primaryGreen
                                : AppColors.textLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColors.primaryGreen,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Edit Medicine'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'test',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active,
                                    size: 18,
                                    color: AppColors.riskYellow,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Test Notification'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.highRisk,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Delete Medicine',
                                    style: TextStyle(color: AppColors.highRisk),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            _editMedicine(medicine);
                            break;
                          case 'test':
                            if (medicine.times.isNotEmpty) {
                              await _notificationService.showImmediateReminder(
                                medicine,
                                medicine.times.first,
                              );
                              await HapticUtils.lightImpact();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Test notification sent for ${medicine.name}',
                                    ),
                                    backgroundColor: AppColors.lightGreen,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                            break;
                          case 'delete':
                            _deleteMedicine(medicine);
                            break;
                        }
                      },
                    ),
                  ],
                ),

                if (medicine.instructions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen.withValues(alpha: 0.05),
                          AppColors.primaryGreen.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            medicine.instructions,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Medicine times with better layout
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reminders (${medicine.times.length})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              medicine.times.map((time) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        time.isEnabled && medicine.isActive
                                            ? AppColors.lightGreen.withValues(
                                              alpha: 0.2,
                                            )
                                            : AppColors.textLight.withValues(
                                              alpha: 0.1,
                                            ),
                                        time.isEnabled && medicine.isActive
                                            ? AppColors.lightGreen.withValues(
                                              alpha: 0.3,
                                            )
                                            : AppColors.textLight.withValues(
                                              alpha: 0.2,
                                            ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          time.isEnabled && medicine.isActive
                                              ? AppColors.lightGreen
                                              : AppColors.textLight,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color:
                                            time.isEnabled && medicine.isActive
                                                ? AppColors.primaryGreen
                                                : AppColors.textLight,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        time.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              time.isEnabled &&
                                                      medicine.isActive
                                                  ? AppColors.textPrimary
                                                  : AppColors.textLight,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        time.timeString,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              time.isEnabled &&
                                                      medicine.isActive
                                                  ? AppColors.textSecondary
                                                  : AppColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Medicine?> _showMedicineDialog({Medicine? medicine}) async {
    final nameController = TextEditingController(text: medicine?.name ?? '');
    final dosageController = TextEditingController(
      text: medicine?.dosage ?? '',
    );
    final instructionsController = TextEditingController(
      text: medicine?.instructions ?? '',
    );
    final times = medicine?.times.map((t) => t).toList() ?? <MedicineTime>[];

    return showDialog<Medicine>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    medicine == null ? 'Add Medicine' : 'Edit Medicine',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDialogTextField(
                          controller: nameController,
                          label: 'Medicine Name',
                          hint: 'Enter medicine name',
                          icon: Icons.medication,
                        ),
                        const SizedBox(height: 16),
                        _buildDialogTextField(
                          controller: dosageController,
                          label: 'Dosage',
                          hint: 'Dosage (e.g., 1 tablet, 5ml)',
                          icon: Icons.local_pharmacy,
                        ),
                        const SizedBox(height: 16),
                        _buildDialogTextField(
                          controller: instructionsController,
                          label: 'Instructions (optional)',
                          hint: 'Take with food, before meals, etc.',
                          icon: Icons.note,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Times section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reminder Times',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final time = await _showTimePickerDialog();
                                if (time != null) {
                                  setDialogState(() {
                                    times.add(time);
                                  });
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Time'),
                            ),
                          ],
                        ),

                        ...times.map(
                          (time) => ListTile(
                            leading: const Icon(Icons.access_time),
                            title: Text('${time.label} - ${time.timeString}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setDialogState(() {
                                  times.remove(time);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            dosageController.text.isNotEmpty &&
                            times.isNotEmpty) {
                          final newMedicine = Medicine(
                            id:
                                medicine?.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            name: nameController.text,
                            dosage: dosageController.text,
                            instructions: instructionsController.text,
                            times: times,
                            isActive: medicine?.isActive ?? true,
                            createdAt: medicine?.createdAt ?? DateTime.now(),
                          );
                          Navigator.of(context).pop(newMedicine);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(medicine == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<MedicineTime?> _showTimePickerDialog() async {
    final labelController = TextEditingController();
    TimeOfDay? selectedTime;

    return showDialog<MedicineTime>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Add Reminder Time'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: labelController,
                        decoration: InputDecoration(
                          labelText: 'Label (e.g., Morning, Evening)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          selectedTime?.format(context) ?? 'Select Time',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (labelController.text.isNotEmpty &&
                            selectedTime != null) {
                          final medicineTime = MedicineTime(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            hour: selectedTime!.hour,
                            minute: selectedTime!.minute,
                            label: labelController.text,
                          );
                          Navigator.of(context).pop(medicineTime);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<bool> _showDeleteConfirmation(String medicineName) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Medicine'),
                  ],
                ),
                content: Text(
                  'Are you sure you want to delete "$medicineName"? This will cancel all reminders for this medicine.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
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
          maxLines: maxLines,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
