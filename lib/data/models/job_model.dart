class JobModel {
  final String id;
  final String title;
  final String company;
  final String? companyLogoUrl;
  final String location;
  final bool isRemote;
  final String employmentType;
  final String experienceLevel;
  final String? category;
  final int? salaryMin;
  final int? salaryMax;
  final String salaryCurrency;
  final String description;
  final List<String> requirements;
  final List<String> tags;
  final DateTime postedAt;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogoUrl,
    required this.location,
    this.isRemote = false,
    this.employmentType = 'full_time',
    this.experienceLevel = 'mid',
    this.category,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'USD',
    this.description = '',
    this.requirements = const [],
    this.tags = const [],
    required this.postedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      companyLogoUrl: json['company_logo_url'] as String?,
      location: json['location'] as String? ?? 'Remote',
      isRemote: json['is_remote'] as bool? ?? false,
      employmentType: json['employment_type'] as String? ?? 'full_time',
      experienceLevel: json['experience_level'] as String? ?? 'mid',
      category: json['category'] as String?,
      salaryMin: json['salary_min'] as int?,
      salaryMax: json['salary_max'] as int?,
      salaryCurrency: json['salary_currency'] as String? ?? 'USD',
      description: json['description'] as String? ?? '',
      requirements:
          (json['requirements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      postedAt: DateTime.parse(json['posted_at'] as String),
    );
  }

  /// e.g. "Full-time", "Internship".
  String get employmentTypeLabel {
    switch (employmentType) {
      case 'part_time':
        return 'Part-time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      case 'full_time':
      default:
        return 'Full-time';
    }
  }

  String get experienceLabel {
    switch (experienceLevel) {
      case 'entry':
        return 'Entry level';
      case 'senior':
        return 'Senior';
      case 'lead':
        return 'Lead';
      case 'mid':
      default:
        return 'Mid level';
    }
  }

  /// e.g. "$140k – $185k" or "Salary not disclosed".
  String get salaryRange {
    String fmt(int v) =>
        v >= 1000 ? '\$${(v / 1000).round()}k' : '\$$v';
    if (salaryMin != null && salaryMax != null) {
      return '${fmt(salaryMin!)} – ${fmt(salaryMax!)}';
    }
    if (salaryMin != null) return 'From ${fmt(salaryMin!)}';
    if (salaryMax != null) return 'Up to ${fmt(salaryMax!)}';
    return 'Salary not disclosed';
  }

  String get postedLabel {
    final diff = DateTime.now().difference(postedAt);
    if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class JobApplicationModel {
  final String id;
  final String userId;
  final String jobId;
  final String status;
  final String? coverNote;
  final DateTime appliedAt;
  final JobModel? job;

  JobApplicationModel({
    required this.id,
    required this.userId,
    required this.jobId,
    this.status = 'applied',
    this.coverNote,
    required this.appliedAt,
    this.job,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      jobId: json['job_id'] as String,
      status: json['status'] as String? ?? 'applied',
      coverNote: json['cover_note'] as String?,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      job: json['jobs'] != null
          ? JobModel.fromJson(json['jobs'] as Map<String, dynamic>)
          : null,
    );
  }

  String get statusLabel {
    return status.isEmpty
        ? 'Applied'
        : status[0].toUpperCase() + status.substring(1);
  }
}
