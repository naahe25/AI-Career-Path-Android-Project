import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import 'supabase_service.dart';
import '../../core/utils/logger.dart';

class GeneratedPath {
  final String title;
  final String description;
  final String targetRole;
  final int estimatedDurationMonths;
  final String difficultyLevel;
  final List<Map<String, dynamic>> milestones;

  GeneratedPath({
    required this.title,
    required this.description,
    required this.targetRole,
    required this.estimatedDurationMonths,
    required this.difficultyLevel,
    required this.milestones,
  });

  factory GeneratedPath.fromJson(Map<String, dynamic> json) {
    final milestonesList =
        (json['milestones'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];
    return GeneratedPath(
      title: json['title'] as String? ?? 'Career Path',
      description: json['description'] as String? ?? '',
      targetRole: json['target_role'] as String? ?? 'Professional',
      estimatedDurationMonths: json['estimated_duration_months'] as int? ?? 12,
      difficultyLevel: json['difficulty_level'] as String? ?? 'intermediate',
      milestones: milestonesList,
    );
  }
}

class AiService {
  Future<List<GeneratedPath>> generateCareerPaths(ProfileModel profile) async {
    // Make the app usable even when Edge/AI service is temporarily unavailable.
    // The UI will still work using fallback demo paths.
    try {

      final response = await SupabaseService.client.functions.invoke(
        'generate-career-path',
        body: {
          'full_name': profile.fullName ?? 'User',
          'current_skills': profile.currentSkills,
          'education_level': profile.educationLevel ?? '',
          'years_of_experience': profile.yearsOfExperience,
          'current_role': profile.currentRole ?? '',
          'desired_field': profile.desiredField ?? '',
        },
      );

      if (response.status != 200) {
        throw Exception('AI service returned status ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown AI error');
      }

      final pathsList = data['data'] as List<dynamic>;
      final paths = pathsList
          .map((p) => GeneratedPath.fromJson(p as Map<String, dynamic>))
          .toList();

      appLogger.i('Generated ${paths.length} career paths');
      return paths;
    } on FunctionException catch (e) {
      appLogger.e('Edge function error: ${e.details}');
      return _fallbackCareerPaths(profile);
    } on Exception catch (e) {
      appLogger.e('AI service error: $e');
      // If user is not authenticated, also return fallback so the app keeps working.
      return _fallbackCareerPaths(profile);
    } catch (e) {
      appLogger.e('AI service error: $e');
      return _fallbackCareerPaths(profile);
    }
  }

  List<GeneratedPath> _fallbackCareerPaths(ProfileModel profile) {
    final targetField = (profile.desiredField ?? '').trim();
    final field = targetField.isNotEmpty ? targetField : 'Software Engineering';
    // A short, stable suffix so the two generated paths never collide by title
    // (the dashboard prevents adding the same titled path twice).
    final stamp = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    Map<String, dynamic> resource(String title, String url, String type) =>
        {'title': title, 'url': url, 'type': type};

    return [
      GeneratedPath(
        title: '$field — Foundations to First Role',
        description:
            'A beginner-friendly roadmap that takes you from fundamentals to a '
            'portfolio strong enough to land your first $field role.',
        targetRole: '$field Associate',
        estimatedDurationMonths: 9,
        difficultyLevel: 'beginner',
        milestones: [
          {
            'title': 'Master the Fundamentals',
            'description':
                'Build a rock-solid base in the core concepts of $field. Take '
                'structured notes and complete every exercise.',
            'estimated_weeks': 5,
            'skills_gained': ['Core concepts', 'Problem solving', 'Tooling'],
            'resources': [
              resource('freeCodeCamp', 'https://www.freecodecamp.org', 'course'),
              resource('Khan Academy', 'https://www.khanacademy.org', 'course'),
            ],
          },
          {
            'title': 'Build Your First Project',
            'description':
                'Apply what you learned by shipping a small but complete '
                'project end-to-end. Put it on GitHub with a clear README.',
            'estimated_weeks': 4,
            'skills_gained': ['Project setup', 'Version control', 'Debugging'],
            'resources': [
              resource('GitHub Get Started', 'https://docs.github.com/get-started', 'documentation'),
              resource('The Odin Project', 'https://www.theodinproject.com', 'project'),
            ],
          },
          {
            'title': 'Go Deeper on One Specialty',
            'description':
                'Pick the part of $field you enjoy most and study it deeply. '
                'Rebuild a real-world feature from scratch.',
            'estimated_weeks': 5,
            'skills_gained': ['Specialization', 'Best practices', 'Testing'],
            'resources': [
              resource('MDN Web Docs', 'https://developer.mozilla.org', 'documentation'),
              resource('Coursera', 'https://www.coursera.org', 'course'),
            ],
          },
          {
            'title': 'Build a Portfolio',
            'description':
                'Polish 3 projects that show range. Write a short case study '
                'for each explaining the problem, approach, and result.',
            'estimated_weeks': 4,
            'skills_gained': ['Portfolio', 'Technical writing', 'UX polish'],
            'resources': [
              resource('GitHub Pages', 'https://pages.github.com', 'documentation'),
              resource('Portfolio examples', 'https://github.com', 'project'),
            ],
          },
          {
            'title': 'Interview Preparation',
            'description':
                'Practice common questions, refine your resume, and run mock '
                'interviews until you feel calm and confident.',
            'estimated_weeks': 4,
            'skills_gained': ['Interviewing', 'Resume', 'Communication'],
            'resources': [
              resource('LeetCode', 'https://leetcode.com', 'project'),
              resource('Tech Interview Handbook', 'https://www.techinterviewhandbook.org', 'documentation'),
            ],
          },
        ],
      ),
      GeneratedPath(
        title: '$field — Job-Ready to Senior (#$stamp)',
        description:
            'An intermediate track for people already familiar with the basics '
            'who want to reach a senior $field level with real impact.',
        targetRole: 'Senior $field Specialist',
        estimatedDurationMonths: 14,
        difficultyLevel: 'intermediate',
        milestones: [
          {
            'title': 'Deepen Core Expertise',
            'description':
                'Close knowledge gaps and learn the advanced patterns that '
                'separate juniors from seniors in $field.',
            'estimated_weeks': 6,
            'skills_gained': ['Advanced patterns', 'Architecture', 'Performance'],
            'resources': [
              resource('Frontend Masters', 'https://frontendmasters.com', 'course'),
              resource('Official docs', 'https://devdocs.io', 'documentation'),
            ],
          },
          {
            'title': 'Ship a Production-Grade Project',
            'description':
                'Build something real users could use: auth, a database, tests '
                'and a deployment pipeline. Treat it like a real product.',
            'estimated_weeks': 8,
            'skills_gained': ['System design', 'CI/CD', 'Testing'],
            'resources': [
              resource('Supabase Docs', 'https://supabase.com/docs', 'documentation'),
              resource('Deploy with Vercel', 'https://vercel.com/docs', 'documentation'),
            ],
          },
          {
            'title': 'Contribute to Open Source',
            'description':
                'Make meaningful contributions to a real project. Learn to read '
                'large codebases and collaborate through pull requests.',
            'estimated_weeks': 6,
            'skills_gained': ['Collaboration', 'Code review', 'Git workflow'],
            'resources': [
              resource('Good First Issues', 'https://goodfirstissue.dev', 'project'),
              resource('First Contributions', 'https://github.com/firstcontributions/first-contributions', 'project'),
            ],
          },
          {
            'title': 'Develop Leadership & Impact',
            'description':
                'Mentor others, lead a small feature end-to-end, and learn to '
                'communicate trade-offs and measure impact with metrics.',
            'estimated_weeks': 6,
            'skills_gained': ['Mentorship', 'Communication', 'Ownership'],
            'resources': [
              resource('The Manager\'s Path', 'https://www.oreilly.com', 'book'),
              resource('Staff Engineer', 'https://staffeng.com', 'documentation'),
            ],
          },
          {
            'title': 'Land a Senior Role',
            'description':
                'Target senior-level interviews. Prepare system-design stories '
                'and quantify your achievements on your resume and profile.',
            'estimated_weeks': 6,
            'skills_gained': ['System design', 'Negotiation', 'Personal brand'],
            'resources': [
              resource('System Design Primer', 'https://github.com/donnemartin/system-design-primer', 'documentation'),
              resource('LinkedIn Optimization', 'https://www.linkedin.com', 'article'),
            ],
          },
        ],
      ),
    ];
  }
}
