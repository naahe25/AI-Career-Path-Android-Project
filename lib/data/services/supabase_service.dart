import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;

  static bool get isAuthenticated =>
      Supabase.instance.client.auth.currentUser != null;

  static String? get currentUserId =>
      Supabase.instance.client.auth.currentUser?.id;
}
