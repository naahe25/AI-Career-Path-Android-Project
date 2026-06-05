import '../models/achievement_model.dart';
import '../models/analytics_model.dart';
import '../models/career_path_model.dart';
import '../models/milestone_model.dart';
import '../models/profile_model.dart';
import '../models/skill_model.dart';
import '../models/user_settings_model.dart';
import '../services/ai_service.dart';

class DemoData {
  DemoData._();

  static const String userId = 'demo-user';

  static DateTime get _now => DateTime.now();

  static ProfileModel profile() {
    final now = _now;
    return ProfileModel(
      id: userId,
      fullName: 'Career Explorer',
      currentSkills: const [
        'Flutter',
        'Dart',
        'UI Design',
        'Problem Solving',
        'Communication',
      ],
      educationLevel: 'Bachelor of Computer Science',
      yearsOfExperience: 2,
      currentRole: 'Junior Mobile Developer',
      desiredField: 'AI Product Engineer',
      createdAt: now.subtract(const Duration(days: 120)),
      updatedAt: now,
    );
  }

  static List<CareerPathModel> careerPaths() {
    final now = _now;
    return [
      CareerPathModel(
        id: 'demo-path-ai-product',
        userId: userId,
        title: 'AI Product Engineer Roadmap',
        description:
            'A focused path from Flutter developer to AI-powered product builder with portfolio-ready projects.',
        targetRole: 'AI Product Engineer',
        estimatedDurationMonths: 8,
        difficultyLevel: 'intermediate',
        milestones: [
          _milestone(
            id: 'demo-ai-1',
            pathId: 'demo-path-ai-product',
            order: 0,
            title: 'Strengthen product engineering fundamentals',
            description:
                'Sharpen Flutter architecture, state management, testing, accessibility, and polished Material 3 delivery.',
            skills: const ['Flutter Architecture', 'Riverpod', 'Testing'],
            weeks: 4,
            completed: true,
          ),
          _milestone(
            id: 'demo-ai-2',
            pathId: 'demo-path-ai-product',
            order: 1,
            title: 'Build practical AI app workflows',
            description:
                'Create chat, recommendation, resume review, and roadmap-generation workflows with graceful offline states.',
            skills: const ['Prompt Design', 'AI UX', 'API Integration'],
            weeks: 5,
            completed: true,
          ),
          _milestone(
            id: 'demo-ai-3',
            pathId: 'demo-path-ai-product',
            order: 2,
            title: 'Launch a career assistant portfolio project',
            description:
                'Package a production-style app with analytics, authentication, portfolio case study, and demo data.',
            skills: const ['Portfolio', 'Analytics', 'Deployment'],
            weeks: 6,
          ),
          _milestone(
            id: 'demo-ai-4',
            pathId: 'demo-path-ai-product',
            order: 3,
            title: 'Prepare for AI product interviews',
            description:
                'Practice product thinking, system design, communication, and mock interviews with scored feedback.',
            skills: const ['Interview Prep', 'System Design', 'Storytelling'],
            weeks: 4,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      CareerPathModel(
        id: 'demo-path-data',
        userId: userId,
        title: 'Data Analyst to ML Specialist',
        description:
            'A practical learning path for analytics, statistics, Python, machine learning, and salary growth planning.',
        targetRole: 'Machine Learning Specialist',
        estimatedDurationMonths: 10,
        difficultyLevel: 'advanced',
        milestones: [
          _milestone(
            id: 'demo-data-1',
            pathId: 'demo-path-data',
            order: 0,
            title: 'Master analytics foundations',
            description:
                'Build confidence in SQL, dashboards, metrics, and business storytelling.',
            skills: const ['SQL', 'Dashboards', 'Business Metrics'],
            weeks: 5,
            completed: true,
          ),
          _milestone(
            id: 'demo-data-2',
            pathId: 'demo-path-data',
            order: 1,
            title: 'Learn Python for machine learning',
            description:
                'Use Python, notebooks, model evaluation, and clean data pipelines.',
            skills: const ['Python', 'Pandas', 'Model Evaluation'],
            weeks: 7,
          ),
          _milestone(
            id: 'demo-data-3',
            pathId: 'demo-path-data',
            order: 2,
            title: 'Create an ML portfolio collection',
            description:
                'Publish three projects that show forecasting, classification, and recommendation systems.',
            skills: const ['ML Projects', 'GitHub', 'Presentation'],
            weeks: 8,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now,
      ),
    ];
  }

  static MilestoneModel _milestone({
    required String id,
    required String pathId,
    required int order,
    required String title,
    required String description,
    required List<String> skills,
    required int weeks,
    bool completed = false,
  }) {
    final now = _now;
    return MilestoneModel(
      id: id,
      careerPathId: pathId,
      title: title,
      description: description,
      orderIndex: order,
      isCompleted: completed,
      resources: [
        ResourceModel(
          title: 'Curated course plan',
          url: 'https://www.coursera.org',
          type: 'course',
        ),
        ResourceModel(
          title: 'Portfolio project brief',
          url: 'https://github.com',
          type: 'project',
        ),
      ],
      skillsGained: skills,
      estimatedWeeks: weeks,
      completedAt: completed ? now.subtract(const Duration(days: 5)) : null,
      createdAt: now.subtract(const Duration(days: 30)),
    );
  }

  static List<GeneratedPath> generatedPaths() {
    return [
      GeneratedPath(
        title: 'AI Career Coach Specialist',
        description:
            'A generated path focused on mentoring chat, interview coaching, resume scoring, and job matching.',
        targetRole: 'AI Career Coach Specialist',
        estimatedDurationMonths: 6,
        difficultyLevel: 'intermediate',
        milestones: const [
          {
            'title': 'Design AI mentor workflows',
            'description': 'Map chat, recommendation, and progress tracking flows.',
            'estimated_weeks': 3,
            'skills_gained': ['AI UX', 'Prompt Design'],
            'resources': [],
          },
          {
            'title': 'Build resume and interview tools',
            'description': 'Prototype scoring, feedback, voice practice, and readiness reports.',
            'estimated_weeks': 5,
            'skills_gained': ['Resume Analysis', 'Interview Coaching'],
            'resources': [],
          },
        ],
      ),
      GeneratedPath(
        title: 'Remote Full Stack Career Track',
        description:
            'A generated track for remote-ready full stack development, professional branding, and job applications.',
        targetRole: 'Remote Full Stack Developer',
        estimatedDurationMonths: 7,
        difficultyLevel: 'beginner',
        milestones: const [
          {
            'title': 'Refresh full stack basics',
            'description': 'Practice API, database, and responsive UI fundamentals.',
            'estimated_weeks': 4,
            'skills_gained': ['APIs', 'Databases', 'Responsive UI'],
            'resources': [],
          },
          {
            'title': 'Build an application tracker',
            'description': 'Create a job tracker with status boards and reminders.',
            'estimated_weeks': 4,
            'skills_gained': ['Job Search', 'Product Delivery'],
            'resources': [],
          },
        ],
      ),
    ];
  }

  static CareerPathModel careerPathFromGenerated(String userId, GeneratedPath path) {
    final now = _now;
    final pathId = 'demo-generated-${now.microsecondsSinceEpoch}';
    return CareerPathModel(
      id: pathId,
      userId: userId,
      title: path.title,
      description: path.description,
      targetRole: path.targetRole,
      estimatedDurationMonths: path.estimatedDurationMonths,
      difficultyLevel: path.difficultyLevel,
      milestones: path.milestones.asMap().entries.map((entry) {
        final item = entry.value;
        return MilestoneModel(
          id: '$pathId-${entry.key}',
          careerPathId: pathId,
          title: item['title'] as String? ?? 'Milestone',
          description: item['description'] as String?,
          orderIndex: entry.key,
          skillsGained: (item['skills_gained'] as List<dynamic>?)
                  ?.map((skill) => skill.toString())
                  .toList() ??
              const [],
          estimatedWeeks: item['estimated_weeks'] as int?,
          createdAt: now,
        );
      }).toList(),
      createdAt: now,
      updatedAt: now,
    );
  }

  static List<SkillModel> allSkills() {
    final now = _now;
    return [
      _skill(
        'skill-flutter',
        'Flutter Architecture',
        'Mobile',
        'intermediate',
        45,
        now,
      ),
      _skill('skill-ai-ux', 'AI Product UX', 'AI', 'intermediate', 32, now),
      _skill(
        'skill-resume',
        'ATS Resume Writing',
        'Career',
        'beginner',
        12,
        now,
      ),
      _skill('skill-sql', 'SQL Analytics', 'Data', 'beginner', 24, now),
      _skill('skill-ml', 'Machine Learning Basics', 'AI', 'advanced', 60, now),
      _skill('skill-interview', 'Interview Storytelling', 'Career', 'intermediate', 16, now),
      _skill('skill-linkedin', 'LinkedIn Optimization', 'Branding', 'beginner', 10, now),
    ];
  }

  static SkillModel _skill(
    String id,
    String name,
    String category,
    String difficulty,
    int hours,
    DateTime now,
  ) {
    return SkillModel(
      id: id,
      name: name,
      description: '$name learning module',
      category: category,
      difficulty: difficulty,
      estimatedHours: hours,
      createdAt: now.subtract(const Duration(days: 40)),
    );
  }

  static List<UserSkillModel> userSkills() {
    final now = _now;
    final skills = allSkills();
    return [
      UserSkillModel(
        id: 'user-skill-flutter',
        userId: userId,
        skillId: skills[0].id,
        proficiencyLevel: 78,
        hoursInvested: 38,
        startedAt: now.subtract(const Duration(days: 42)),
        completedAt: now.subtract(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 42)),
        skill: skills[0],
      ),
      UserSkillModel(
        id: 'user-skill-ai-ux',
        userId: userId,
        skillId: skills[1].id,
        proficiencyLevel: 54,
        hoursInvested: 18,
        startedAt: now.subtract(const Duration(days: 19)),
        createdAt: now.subtract(const Duration(days: 19)),
        skill: skills[1],
      ),
      UserSkillModel(
        id: 'user-skill-resume',
        userId: userId,
        skillId: skills[2].id,
        proficiencyLevel: 35,
        hoursInvested: 6,
        startedAt: now.subtract(const Duration(days: 8)),
        createdAt: now.subtract(const Duration(days: 8)),
        skill: skills[2],
      ),
    ];
  }

  static AnalyticsModel analytics() {
    final now = _now;
    return AnalyticsModel(
      id: 'demo-analytics',
      userId: userId,
      learningHours: 86,
      milestonesCompleted: 3,
      skillsAcquired: 7,
      currentStreak: 9,
      longestStreak: 21,
      lastActivityDate: now,
      weeklyProgress: const {'hours': 9, 'tasks': 14, 'goals': 4},
      monthlyProgress: const {'hours': 36, 'tasks': 52, 'goals': 11},
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    );
  }

  static List<DailyProgressModel> dailyProgress() {
    final now = _now;
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      return DailyProgressModel(
        id: 'daily-$index',
        userId: userId,
        date: date,
        milestonesWorked: index % 3 + 1,
        learningMinutes: 35 + (index * 8),
        skillsWorkedOn: index % 2 + 1,
        createdAt: date,
      );
    });
  }

  static List<AchievementModel> allAchievements() {
    final now = _now;
    return [
      _achievement(
        'first-path',
        'First Roadmap',
        'Generated your first AI career roadmap.',
        'roadmap',
        1,
        now,
      ),
      _achievement(
        'streak-7',
        'Seven Day Streak',
        'Kept learning for one full week.',
        'streak',
        7,
        now,
      ),
      _achievement(
        'resume-ready',
        'Resume Ready',
        'Completed an ATS resume review.',
        'resume',
        1,
        now,
      ),
      _achievement(
        'interview-ready',
        'Interview Ready',
        'Reached a strong mock interview score.',
        'interview',
        80,
        now,
      ),
      _achievement(
        'networker',
        'Network Builder',
        'Started professional community engagement.',
        'network',
        5,
        now,
      ),
      _achievement(
        'skill-master',
        'Skill Mastery',
        'Completed a core skill module.',
        'skill',
        1,
        now,
      ),
    ];
  }

  static AchievementModel _achievement(
    String id,
    String title,
    String description,
    String type,
    int threshold,
    DateTime now,
  ) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      threshold: threshold,
      type: type,
      createdAt: now.subtract(const Duration(days: 80)),
    );
  }

  static List<UserAchievementModel> userAchievements() {
    final now = _now;
    final achievements = allAchievements();
    return achievements.take(3).map((achievement) {
      return UserAchievementModel(
        id: 'earned-${achievement.id}',
        userId: userId,
        achievementId: achievement.id,
        earnedAt: now.subtract(const Duration(days: 3)),
        achievement: achievement,
      );
    }).toList();
  }

  static UserSettingsModel settings() {
    final now = _now;
    return UserSettingsModel(
      id: 'demo-settings',
      userId: userId,
      theme: 'dark',
      notificationsEnabled: true,
      emailNotifications: true,
      pushNotifications: true,
      newsletterSubscribed: true,
      language: 'en',
      privacyLevel: 'private',
      twoFactorEnabled: false,
      createdAt: now.subtract(const Duration(days: 120)),
      updatedAt: now,
    );
  }
}
