import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/job_model.dart';
import '../models/profile_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';
import 'supabase_service.dart';

class JobService {
  final _client = SupabaseService.client;

  Future<List<JobModel>> getJobs({
    String? search,
    String? employmentType,
    String? experienceLevel,
    bool remoteOnly = false,
  }) async {
    try {
      var query = _client.from('jobs').select();

      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim();
        query = query.or('title.ilike.%$q%,company.ilike.%$q%,category.ilike.%$q%');
      }
      if (employmentType != null) {
        query = query.eq('employment_type', employmentType);
      }
      if (experienceLevel != null) {
        query = query.eq('experience_level', experienceLevel);
      }
      if (remoteOnly) {
        query = query.eq('is_remote', true);
      }

      final data = await query.order('posted_at', ascending: false);
      return (data as List).map((x) => JobModel.fromJson(x)).toList();
    } catch (e) {
      appLogger.e('Get jobs error: $e');
      throw ServerException(message: 'Failed to load jobs', originalException: e);
    }
  }

  Future<JobModel?> getJobById(String jobId) async {
    try {
      final data =
          await _client.from('jobs').select().eq('id', jobId).maybeSingle();
      return data != null ? JobModel.fromJson(data) : null;
    } catch (e) {
      appLogger.e('Get job error: $e');
      return null;
    }
  }

  /// Creates a hiring listing posted by the current user (LinkedIn-style).
  Future<JobModel> createJob({
    required String userId,
    required String title,
    required String company,
    required String location,
    bool isRemote = false,
    String employmentType = 'full_time',
    String experienceLevel = 'mid',
    String? category,
    int? salaryMin,
    int? salaryMax,
    required String description,
    List<String> requirements = const [],
    List<String> tags = const [],
  }) async {
    try {
      final row = {
        'title': title,
        'company': company,
        'location': location,
        'is_remote': isRemote,
        'employment_type': employmentType,
        'experience_level': experienceLevel,
        'category': category,
        'salary_min': salaryMin,
        'salary_max': salaryMax,
        'description': description,
        'requirements': requirements,
        'tags': tags,
        'posted_by': userId,
        'posted_at': DateTime.now().toIso8601String(),
      };
      final data = await _client.from('jobs').insert(row).select().single();
      return JobModel.fromJson(data);
    } catch (e) {
      appLogger.e('Create job error: $e');
      throw ServerException(
          message: 'Failed to post job', originalException: e);
    }
  }

  /// Hiring listings posted by [userId] (for the profile "My job posts" view).
  Future<List<JobModel>> getJobsPostedBy(String userId) async {
    try {
      final data = await _client
          .from('jobs')
          .select()
          .eq('posted_by', userId)
          .order('posted_at', ascending: false);
      return (data as List).map((x) => JobModel.fromJson(x)).toList();
    } catch (e) {
      appLogger.e('Get posted jobs error: $e');
      throw ServerException(
          message: 'Failed to load your job posts', originalException: e);
    }
  }

  /// Everyone who applied to [jobId]. RLS only returns rows when the current
  /// user is the job's poster.
  Future<List<JobApplicationModel>> getApplicantsForJob(String jobId) async {
    try {
      final data = await _client
          .from('job_applications')
          .select()
          .eq('job_id', jobId)
          .order('applied_at', ascending: false);
      return (data as List)
          .map((x) => JobApplicationModel.fromJson(x))
          .toList();
    } catch (e) {
      appLogger.e('Get applicants error: $e');
      throw ServerException(
          message: 'Failed to load applicants', originalException: e);
    }
  }

  // --- Saved jobs ---------------------------------------------------------
  Future<Set<String>> getSavedJobIds(String userId) async {
    try {
      final data =
          await _client.from('saved_jobs').select('job_id').eq('user_id', userId);
      return (data as List).map((x) => x['job_id'] as String).toSet();
    } catch (e) {
      appLogger.e('Get saved job ids error: $e');
      return {};
    }
  }

  Future<List<JobModel>> getSavedJobs(String userId) async {
    try {
      final data = await _client
          .from('saved_jobs')
          .select('jobs(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (data as List)
          .where((x) => x['jobs'] != null)
          .map((x) => JobModel.fromJson(x['jobs'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      appLogger.e('Get saved jobs error: $e');
      throw ServerException(message: 'Failed to load saved jobs', originalException: e);
    }
  }

  Future<void> toggleSaveJob(String userId, String jobId, bool save) async {
    try {
      if (save) {
        await _client.from('saved_jobs').upsert({
          'user_id': userId,
          'job_id': jobId,
        }, onConflict: 'user_id,job_id');
      } else {
        await _client
            .from('saved_jobs')
            .delete()
            .eq('user_id', userId)
            .eq('job_id', jobId);
      }
    } catch (e) {
      appLogger.e('Toggle save job error: $e');
      throw ServerException(message: 'Failed to update saved job', originalException: e);
    }
  }

  // --- Applications -------------------------------------------------------
  Future<Set<String>> getAppliedJobIds(String userId) async {
    try {
      final data = await _client
          .from('job_applications')
          .select('job_id')
          .eq('user_id', userId);
      return (data as List).map((x) => x['job_id'] as String).toSet();
    } catch (e) {
      appLogger.e('Get applied job ids error: $e');
      return {};
    }
  }

  Future<List<JobApplicationModel>> getApplications(String userId) async {
    try {
      final data = await _client
          .from('job_applications')
          .select('*, jobs(*)')
          .eq('user_id', userId)
          .order('applied_at', ascending: false);
      return (data as List)
          .map((x) => JobApplicationModel.fromJson(x))
          .toList();
    } catch (e) {
      appLogger.e('Get applications error: $e');
      throw ServerException(message: 'Failed to load applications', originalException: e);
    }
  }

  /// Uploads an applicant's CV (PDF/Word) to the public `cvs` bucket and
  /// returns its public URL.
  Future<String> uploadCv(
    String userId,
    Uint8List bytes,
    String fileName, {
    String extension = 'pdf',
  }) async {
    try {
      final ext = extension.toLowerCase();
      final path = '$userId/${const Uuid().v4()}.$ext';
      await _client.storage.from('cvs').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: _cvContentType(ext),
              upsert: true,
            ),
          );
      return _client.storage.from('cvs').getPublicUrl(path);
    } catch (e) {
      appLogger.e('Upload CV error: $e');
      throw ServerException(
          message: 'Failed to upload CV', originalException: e);
    }
  }

  String _cvContentType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> applyToJob(
    String userId,
    String jobId, {
    String? coverNote,
    required String cvUrl,
    required String cvName,
    ProfileModel? applicant,
  }) async {
    try {
      await _client.from('job_applications').upsert({
        'user_id': userId,
        'job_id': jobId,
        'status': 'applied',
        'cover_note': coverNote,
        'cv_url': cvUrl,
        'cv_name': cvName,
        'applicant_name': applicant?.fullName,
        'applicant_avatar_url': applicant?.avatarUrl,
        'applicant_headline':
            applicant?.currentRole ?? applicant?.desiredField,
        'applied_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,job_id');
    } catch (e) {
      appLogger.e('Apply to job error: $e');
      throw ServerException(message: 'Failed to submit application', originalException: e);
    }
  }
}
