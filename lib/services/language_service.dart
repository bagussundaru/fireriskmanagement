import 'package:flutter/foundation.dart';

/// Simple bilingual service. Singleton pattern via factory constructor.
class LangService extends ChangeNotifier {
  static final LangService _instance = LangService._internal();
  factory LangService() => _instance;
  LangService._internal();

  String _lang = 'en'; // 'en' or 'id'
  String get lang => _lang;
  bool get isEn => _lang == 'en';

  void toggle() {
    _lang = _lang == 'en' ? 'id' : 'en';
    notifyListeners();
  }

  void setLang(String lang) {
    if (lang != _lang) {
      _lang = lang;
      notifyListeners();
    }
  }

  /// Translate with key lookup; fallback to key itself
  String t(String key) => _strings[_lang]?[key] ?? _strings['en']?[key] ?? key;

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      // App
      'app_title': 'Fire Risk Management',
      'app_subtitle': 'AI-Powered Decision Support System',
      'lang_toggle': 'Bahasa Indonesia',
      // Home
      'start_assessment': 'Start Assessment',
      'grms_assessment': 'GRMS 2167.01a Assessment',
      'view_history': 'View History',
      'ai_powered': 'Powered by Hybrid AHP-Fuzzy Logic',
      'choose_assessment': 'Choose Assessment Type',
      'assessment_standard': 'Standard AHP-Fuzzy',
      'assessment_grms': 'GRMS 2167.01a (International)',
      'assessment_standard_desc': 'Hybrid AHP-Fuzzy Logic with Likert & multichoice questions',
      'assessment_grms_desc': 'GRMS international framework with N/A / Yes / No scoring',
      // Factory Info
      'facility_info': 'Facility Information',
      'industry_type': 'Industry / Facility Type *',
      'facility_name': 'Facility Name *',
      'sub_type': 'Sub-type *',
      'worker_count': 'Number of Workers *',
      'assessor_name': 'Assessor Name *',
      'gm_director': 'GM / Director Name *',
      'start_btn': 'START ASSESSMENT',
      'field_required': 'This field is required',
      'chemical_manufacturing_note': 'Chemical B3/industrial questions will use Likert scale & multiple choice',
      'chemical_residential_note': 'Chemical questions will be simple household safety (Yes/No)',
      // Industry Types
      'industry_manufacturing': 'Manufacturing / Industry',
      'industry_manufacturing_desc': 'Factory/Industry with production processes',
      'industry_residential': 'Residential / Housing',
      'industry_residential_desc': 'Residential building, apartment, housing',
      'industry_commercial': 'Commercial',
      'industry_commercial_desc': 'Office, mall, hotel',
      'industry_mixed': 'Mixed Use',
      'industry_mixed_desc': 'Mixed residential and commercial',
      // Assessment
      'section_of': 'Section %s of %s',
      'answered': '%s / %s answered',
      'pct_done': '%s%% completed',
      'prev': 'Previous',
      'next': 'Next',
      'submit': 'Submit Assessment',
      'compliant': '✓  Compliant',
      'not_compliant': '✕  Non-Compliant',
      // GRMS Parts
      'grms_title': 'GRMS 2167.01a Fire Risk Assessment',
      'grms_part_a': 'PART A: Risk Assessment Details',
      'grms_part_b': 'PART B: General Information',
      'grms_part_c': 'PART C: Fire Hazards',
      'grms_part_d': 'PART D: Fire Protection Measures',
      'grms_part_e': 'PART E: Management of Fire Safety',
      'grms_part_f': 'PART F: Fire Risk Assessment',
      'grms_part_g': 'PART G: Action Plan',
      'grms_na': 'N/A',
      'grms_yes': 'Yes',
      'grms_no': 'No',
      'grms_comments': 'Comments & hazards observed:',
      'grms_submit': 'Complete Assessment',
      // Risk
      'risk_low': 'LOW RISK',
      'risk_medium': 'MEDIUM RISK',
      'risk_high': 'HIGH RISK',
      'risk_trivial': 'Trivial',
      'risk_tolerable': 'Tolerable',
      'risk_moderate': 'Moderate',
      'risk_substantial': 'Substantial',
      'risk_intolerable': 'Intolerable',
      // Result
      'total_score': 'Total Score',
      'category_scores': 'Category Scores',
      'recommendation': 'Recommendation',
      'download_pdf': 'Download PDF',
      'new_assessment': 'New Assessment',
    },
    'id': {
      // App
      'app_title': 'Manajemen Risiko Kebakaran',
      'app_subtitle': 'Sistem Pendukung Keputusan Berbasis AI',
      'lang_toggle': 'English',
      // Home
      'start_assessment': 'Mulai Asesmen',
      'grms_assessment': 'Asesmen GRMS 2167.01a',
      'view_history': 'Lihat Riwayat',
      'ai_powered': 'Didukung Hybrid AHP-Fuzzy Logic',
      'choose_assessment': 'Pilih Tipe Asesmen',
      'assessment_standard': 'Standar AHP-Fuzzy',
      'assessment_grms': 'GRMS 2167.01a (Internasional)',
      'assessment_standard_desc': 'Hybrid AHP-Fuzzy Logic dengan Likert & pilihan ganda',
      'assessment_grms_desc': 'Kerangka internasional GRMS dengan penilaian N/A / Ya / Tidak',
      // Factory Info
      'facility_info': 'Informasi Fasilitas',
      'industry_type': 'Jenis Industri / Fasilitas *',
      'facility_name': 'Nama Fasilitas *',
      'sub_type': 'Sub-tipe *',
      'worker_count': 'Jumlah Pekerja *',
      'assessor_name': 'Nama Assessor *',
      'gm_director': 'Nama GM / Direktur *',
      'start_btn': 'MULAI ASESSMEN',
      'field_required': 'Field ini wajib diisi',
      'chemical_manufacturing_note': 'Pertanyaan kimia B3 akan menggunakan skala Likert & pilihan ganda',
      'chemical_residential_note': 'Pertanyaan kimia berupa keamanan bahan rumah tangga (Ya/Tidak)',
      // Industry Types
      'industry_manufacturing': 'Manufacturing / Industri',
      'industry_manufacturing_desc': 'Pabrik/Industri dengan proses produksi',
      'industry_residential': 'Residential / Hunian',
      'industry_residential_desc': 'Gedung hunian, apartemen, perumahan',
      'industry_commercial': 'Commercial / Komersial',
      'industry_commercial_desc': 'Perkantoran, mal, hotel',
      'industry_mixed': 'Mixed Use',
      'industry_mixed_desc': 'Campuran hunian dan komersial',
      // Assessment
      'section_of': 'Seksi %s dari %s',
      'answered': '%s / %s dijawab',
      'pct_done': '%s%% selesai',
      'prev': 'Sebelumnya',
      'next': 'Berikutnya',
      'submit': 'Submit Asesmen',
      'compliant': '✓  Sesuai',
      'not_compliant': '✕  Tidak Sesuai',
      // GRMS Parts
      'grms_title': 'Asesmen Risiko Kebakaran GRMS 2167.01a',
      'grms_part_a': 'BAGIAN A: Detail Asesmen Risiko',
      'grms_part_b': 'BAGIAN B: Informasi Umum',
      'grms_part_c': 'BAGIAN C: Bahaya Kebakaran',
      'grms_part_d': 'BAGIAN D: Tindakan Proteksi Kebakaran',
      'grms_part_e': 'BAGIAN E: Manajemen Keselamatan Kebakaran',
      'grms_part_f': 'BAGIAN F: Penilaian Risiko Kebakaran',
      'grms_part_g': 'BAGIAN G: Rencana Tindakan',
      'grms_na': 'T/B',
      'grms_yes': 'Ya',
      'grms_no': 'Tidak',
      'grms_comments': 'Komentar & bahaya yang diamati:',
      'grms_submit': 'Selesaikan Asesmen',
      // Risk
      'risk_low': 'RISIKO RENDAH',
      'risk_medium': 'RISIKO SEDANG',
      'risk_high': 'RISIKO TINGGI',
      'risk_trivial': 'Sepele',
      'risk_tolerable': 'Dapat Ditoleransi',
      'risk_moderate': 'Sedang',
      'risk_substantial': 'Substansial',
      'risk_intolerable': 'Tidak Dapat Ditoleransi',
      // Result
      'total_score': 'Skor Total',
      'category_scores': 'Skor Per Kategori',
      'recommendation': 'Rekomendasi',
      'download_pdf': 'Unduh PDF',
      'new_assessment': 'Asesmen Baru',
    },
  };
}

/// Global language service instance
final lang = LangService();
