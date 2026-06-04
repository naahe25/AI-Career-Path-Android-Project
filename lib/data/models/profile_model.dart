class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final List<String> currentSkills;
  final String? educationLevel;
  final int yearsOfExperience;
  final String? currentRole;
  final String? desiredField;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.currentSkills = const [],
    this.educationLevel,
    this.yearsOfExperience = 0,
    this.currentRole,
    this.desiredField,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      currentSkills:
          (json['current_skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      educationLevel: json['education_level'] as String?,
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      currentRole: json['user_current_role'] as String?,
      desiredField: json['desired_field'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'current_skills': currentSkills,
      'education_level': educationLevel,
      'years_of_experience': yearsOfExperience,
      'user_current_role': currentRole,
      'desired_field': desiredField,
    };
  }

  ProfileModel copyWith({
    String? fullName,
    String? avatarUrl,
    List<String>? currentSkills,
    String? educationLevel,
    int? yearsOfExperience,
    String? currentRole,
    String? desiredField,
  }) {
    return ProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentSkills: currentSkills ?? this.currentSkills,
      educationLevel: educationLevel ?? this.educationLevel,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      currentRole: currentRole ?? this.currentRole,
      desiredField: desiredField ?? this.desiredField,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  bool get isOnboardingComplete =>
      desiredField != null && desiredField!.isNotEmpty;
}
