class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final List<MedicineTime> times;
  final bool isActive;
  final DateTime createdAt;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.times,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'times': times.map((time) => time.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      instructions: json['instructions'],
      times:
          (json['times'] as List)
              .map((timeJson) => MedicineTime.fromJson(timeJson))
              .toList(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? instructions,
    List<MedicineTime>? times,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      times: times ?? this.times,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MedicineTime {
  final String id;
  final int hour;
  final int minute;
  final String label; // e.g., "Morning", "Afternoon", "Evening"
  final bool isEnabled;

  MedicineTime({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'isEnabled': isEnabled,
    };
  }

  factory MedicineTime.fromJson(Map<String, dynamic> json) {
    return MedicineTime(
      id: json['id'],
      hour: json['hour'],
      minute: json['minute'],
      label: json['label'],
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  String get timeString {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  DateTime get nextOccurrence {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }
}
