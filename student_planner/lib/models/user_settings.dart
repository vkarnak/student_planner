class UserSettings {
  final bool dailyPlan;
  final bool deadlines;
  final bool aiSuggestions;

  const UserSettings({
    this.dailyPlan = true,
    this.deadlines = true,
    this.aiSuggestions = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserSettings();

    return UserSettings(
      dailyPlan: json['dailyPlan'] ?? true,
      deadlines: json['deadlines'] ?? true,
      aiSuggestions: json['aiSuggestions'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyPlan': dailyPlan,
      'deadlines': deadlines,
      'aiSuggestions': aiSuggestions,
    };
  }

  UserSettings copyWith({
    bool? dailyPlan,
    bool? deadlines,
    bool? aiSuggestions,
  }) {
    return UserSettings(
      dailyPlan: dailyPlan ?? this.dailyPlan,
      deadlines: deadlines ?? this.deadlines,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
    );
  }

  static const defaults = UserSettings();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserSettings &&
            other.dailyPlan == dailyPlan &&
            other.deadlines == deadlines &&
            other.aiSuggestions == aiSuggestions;
  }

  @override
  int get hashCode =>
      dailyPlan.hashCode ^ deadlines.hashCode ^ aiSuggestions.hashCode;
}
