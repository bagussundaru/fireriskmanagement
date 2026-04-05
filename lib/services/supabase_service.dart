import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Supabase Service untuk menyimpan dan mengambil data assessment
/// 
/// SETUP INSTRUCTIONS:
/// 1. Buat akun gratis di https://supabase.com
/// 2. Buat project baru
/// 3. Copy URL dan anon key dari Settings > API
/// 4. Jalankan SQL berikut di SQL Editor:
/// 
/// ```sql
/// CREATE TABLE assessments (
///   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   factory_name TEXT NOT NULL,
///   factory_type TEXT,
///   worker_count TEXT,
///   assessor_name TEXT,
///   gm_director TEXT,
///   assessment_date DATE DEFAULT CURRENT_DATE,
///   total_score DECIMAL,
///   risk_level TEXT,
///   category_scores JSONB,
///   answers JSONB,
///   created_at TIMESTAMPTZ DEFAULT NOW()
/// );
/// 
/// -- Enable Row Level Security (optional for staging)
/// ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
/// 
/// -- Allow all operations for anonymous users (staging only)
/// CREATE POLICY "Allow all" ON assessments FOR ALL USING (true);
/// ```
class SupabaseService {
  static SupabaseClient? _client;
  
  // TODO: Ganti dengan URL dan key dari project Supabase Anda
  static const String _supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static bool get isConfigured => 
    _supabaseUrl != 'YOUR_SUPABASE_URL' && 
    _supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';

  /// Initialize Supabase client
  static Future<void> initialize() async {
    if (!isConfigured) {
      print('⚠️ Supabase not configured. Using local storage only.');
      return;
    }
    
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  static SupabaseClient? get client => _client;

  /// Save assessment to Supabase
  static Future<bool> saveAssessment(Assessment assessment) async {
    if (_client == null) {
      print('⚠️ Supabase not initialized. Assessment not saved to cloud.');
      return false;
    }

    try {
      await _client!.from('assessments').insert({
        'id': assessment.id,
        'factory_name': assessment.factoryInfo.factoryName,
        'factory_type': assessment.factoryInfo.factoryType,
        'worker_count': assessment.factoryInfo.workerCount,
        'assessor_name': assessment.factoryInfo.assessorName,
        'gm_director': assessment.factoryInfo.gmDirector,
        'assessment_date': assessment.factoryInfo.assessmentDate.toIso8601String(),
        'total_score': assessment.totalScore,
        'risk_level': assessment.riskLevel,
        'category_scores': assessment.categoryScores,
        'answers': assessment.answers.map((k, v) => MapEntry(k, v.toJson())),
        'created_at': assessment.createdAt.toIso8601String(),
      });
      print('✅ Assessment saved to Supabase');
      return true;
    } catch (e) {
      print('❌ Error saving assessment: $e');
      return false;
    }
  }

  /// Get all assessments from Supabase
  static Future<List<Map<String, dynamic>>> getAssessments() async {
    if (_client == null) {
      return [];
    }

    try {
      final response = await _client!
          .from('assessments')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching assessments: $e');
      return [];
    }
  }

  /// Get single assessment by ID
  static Future<Map<String, dynamic>?> getAssessmentById(String id) async {
    if (_client == null) {
      return null;
    }

    try {
      final response = await _client!
          .from('assessments')
          .select()
          .eq('id', id)
          .single();
      
      return response;
    } catch (e) {
      print('❌ Error fetching assessment: $e');
      return null;
    }
  }

  /// Delete assessment
  static Future<bool> deleteAssessment(String id) async {
    if (_client == null) {
      return false;
    }

    try {
      await _client!.from('assessments').delete().eq('id', id);
      return true;
    } catch (e) {
      print('❌ Error deleting assessment: $e');
      return false;
    }
  }
}
