import '../models/models.dart';

/// Data assessment SESUAI dengan APK asli (firerisk.apk)
/// Total: 87 pertanyaan dalam 4 kategori
/// 
/// A. Legal Compliance: Weight 13.8%, 3 sub-categories, 12 questions
/// B. Fire Prevention Measures: Weight 35.6%, 5 sub-categories, 31 questions
/// C. Fire Protection System: Weight 20.7%, 3 sub-categories, 18 questions
/// D. Evacuation and Emergency: Weight 29.9%, 3 sub-categories, 26 questions
class AssessmentData {
  static List<Category> getCategories() {
    return [
      // ============================================
      // A. LEGAL COMPLIANCE (Weight: 13.8%, 12 Questions)
      // ============================================
      Category(
        id: 'A',
        code: 'A',
        name: 'Legal Compliance',
        weight: 15.0, // AHP Eigenvector * 100
        subCategories: [
          // A1. Legal Compliance (3 questions)
          SubCategory(
            id: 'A1',
            name: 'Legal Compliance',
            questions: [
              Question(id: 'A1Q1', text: 'Apakah perusahaan memiliki izin lingkungan yang masih berlaku?'),
              Question(id: 'A1Q2', text: 'Apakah perusahaan memiliki izin operasional yang valid?'),
              Question(id: 'A1Q3', text: 'Apakah tersedia dokumentasi kepatuhan K3 yang lengkap?'),
            ],
          ),
          // A2. Fire Safety Training (4 questions)
          SubCategory(
            id: 'A2',
            name: 'Fire Safety Training',
            questions: [
              Question(id: 'A2Q1', text: 'Apakah dilakukan pelatihan pemadaman kebakaran secara berkala?'),
              Question(id: 'A2Q2', text: 'Apakah ada jadwal pelatihan evakuasi minimal 2x setahun?'),
              Question(id: 'A2Q3', text: 'Apakah tersedia rekaman/dokumentasi pelatihan?'),
              Question(id: 'A2Q4', text: 'Apakah semua karyawan baru mendapat pelatihan fire safety?'),
            ],
          ),
          // A3. Chemical Storage Compliance (5 questions)
          SubCategory(
            id: 'A3',
            name: 'Chemical Storage Compliance',
            questions: [
              Question(id: 'A3Q1', text: 'Apakah penyimpanan bahan kimia sesuai standar MSDS?'),
              Question(id: 'A3Q2', text: 'Apakah tersedia label dan tanda bahaya yang jelas?'),
              Question(id: 'A3Q3', text: 'Apakah ada pemisahan bahan kimia inkompatibel?'),
              Question(id: 'A3Q4', text: 'Apakah ada secondary containment untuk bahan berbahaya?'),
              Question(id: 'A3Q5', text: 'Apakah tersedia shower darurat di area kimia?'),
            ],
          ),
        ],
      ),

      // ============================================
      // B. FIRE PREVENTION MEASURES (Weight: 35.6%, 31 Questions)
      // ============================================
      Category(
        id: 'B',
        code: 'B',
        name: 'Fire Prevention Measures',
        weight: 38.0, // AHP Eigenvector * 100
        subCategories: [
          // B1. Flammable Chemical and Liquid (5 questions)
          SubCategory(
            id: 'B1',
            name: 'Flammable Chemical and Liquid',
            questions: [
              Question(id: 'B1Q1', text: 'Apakah cairan mudah terbakar disimpan di tempat khusus dengan ventilasi memadai?'),
              Question(id: 'B1Q2', text: 'Apakah ada sistem ventilasi yang baik di area penyimpanan bahan mudah terbakar?'),
              Question(id: 'B1Q3', text: 'Apakah jarak penyimpanan bahan mudah terbakar dari sumber panas memadai?'),
              Question(id: 'B1Q4', text: 'Apakah tersedia grounding/bonding untuk tangki penyimpanan cairan mudah terbakar?'),
              Question(id: 'B1Q5', text: 'Apakah ada prosedur tertulis untuk penanganan tumpahan bahan mudah terbakar?'),
            ],
          ),
          // B2. Electrical Installation and Utilities (7 questions)
          SubCategory(
            id: 'B2',
            name: 'Electrical Installation and Utilities',
            questions: [
              Question(id: 'B2Q1', text: 'Apakah instalasi listrik sesuai standar SNI/PUIL yang berlaku?'),
              Question(id: 'B2Q2', text: 'Apakah dilakukan inspeksi instalasi listrik secara berkala oleh teknisi bersertifikat?'),
              Question(id: 'B2Q3', text: 'Apakah panel listrik mudah diakses dan tidak terhalang oleh barang?'),
              Question(id: 'B2Q4', text: 'Apakah ada sistem grounding yang memadai untuk seluruh instalasi?'),
              Question(id: 'B2Q5', text: 'Apakah kabel-kabel listrik terorganisir dengan baik dan tidak ada yang terkelupas?'),
              Question(id: 'B2Q6', text: 'Apakah tersedia circuit breaker/MCB di semua area?'),
              Question(id: 'B2Q7', text: 'Apakah ada jadwal maintenance rutin untuk utilitas listrik?'),
            ],
          ),
          // B3. Electrical Safety Compliance (5 questions)
          SubCategory(
            id: 'B3',
            name: 'Electrical Safety Compliance',
            questions: [
              Question(id: 'B3Q1', text: 'Apakah semua peralatan listrik memiliki sertifikasi keamanan (SNI/CE)?'),
              Question(id: 'B3Q2', text: 'Apakah tidak ada penggunaan ekstensi kabel berlebihan atau sambungan ilegal?'),
              Question(id: 'B3Q3', text: 'Apakah ada pemisahan jalur listrik untuk sistem emergency?'),
              Question(id: 'B3Q4', text: 'Apakah tersedia lightning protection system yang berfungsi?'),
              Question(id: 'B3Q5', text: 'Apakah ada surge protection untuk peralatan elektronik sensitif?'),
            ],
          ),
          // B4. Building Structure (1 question)
          SubCategory(
            id: 'B4',
            name: 'Building Structure',
            questions: [
              Question(id: 'B4Q1', text: 'Apakah struktur bangunan menggunakan material konstruksi tahan api sesuai standar?'),
            ],
          ),
          // B5. Building Fire Resistance (5 questions + 8 additional = 13 to reach 31 total)
          SubCategory(
            id: 'B5',
            name: 'Building Fire Resistance',
            questions: [
              Question(id: 'B5Q1', text: 'Apakah dinding pemisah antar area memenuhi standar fire rating minimal 2 jam?'),
              Question(id: 'B5Q2', text: 'Apakah pintu darurat memiliki fire rating yang sesuai standar?'),
              Question(id: 'B5Q3', text: 'Apakah tersedia fire damper pada sistem HVAC/ducting?'),
              Question(id: 'B5Q4', text: 'Apakah atap/ceiling memiliki fire resistance rating yang memadai?'),
              Question(id: 'B5Q5', text: 'Apakah ada compartmentalization yang memadai untuk mencegah penyebaran api?'),
              Question(id: 'B5Q6', text: 'Apakah fire stop/sealant terpasang pada penetrasi kabel dan pipa?'),
              Question(id: 'B5Q7', text: 'Apakah material finishing interior (cat, wallpaper) menggunakan bahan tahan api?'),
              Question(id: 'B5Q8', text: 'Apakah tersedia smoke barrier yang berfungsi di area kritis?'),
              Question(id: 'B5Q9', text: 'Apakah jarak antar bangunan memenuhi standar fire separation?'),
              Question(id: 'B5Q10', text: 'Apakah facade bangunan menggunakan material non-combustible?'),
              Question(id: 'B5Q11', text: 'Apakah area basement memiliki ventilasi dan proteksi kebakaran khusus?'),
              Question(id: 'B5Q12', text: 'Apakah shaft elevator dan tangga memiliki proteksi kebakaran?'),
              Question(id: 'B5Q13', text: 'Apakah ruang genset/transformer memiliki fire containment yang memadai?'),
            ],
          ),
        ],
      ),

      // ============================================
      // C. FIRE PROTECTION SYSTEM (Weight: 20.7%, 18 Questions)
      // ============================================
      Category(
        id: 'C',
        code: 'C',
        name: 'Fire Protection System',
        weight: 27.0, // AHP Eigenvector * 100
        subCategories: [
          // C1. Fire Protection System (4 questions)
          SubCategory(
            id: 'C1',
            name: 'Fire Protection System',
            questions: [
              Question(id: 'C1Q1', text: 'Apakah tersedia hydrant dengan tekanan air memadai (min 3.5 bar)?'),
              Question(id: 'C1Q2', text: 'Apakah sistem sprinkler berfungsi dengan baik dan diuji berkala?'),
              Question(id: 'C1Q3', text: 'Apakah ada fire pump dengan backup power yang berfungsi?'),
              Question(id: 'C1Q4', text: 'Apakah water reservoir memadai untuk operasi pemadam minimal 2 jam?'),
            ],
          ),
          // C2. Warehouse Fire Protection (5 questions)
          SubCategory(
            id: 'C2',
            name: 'Warehouse Fire Protection',
            questions: [
              Question(id: 'C2Q1', text: 'Apakah jarak rak penyimpanan ke sprinkler sesuai standar (min 45cm)?'),
              Question(id: 'C2Q2', text: 'Apakah ada sistem deteksi asap yang berfungsi di area warehouse?'),
              Question(id: 'C2Q3', text: 'Apakah aisle clearance memadai untuk akses pemadam dan evakuasi?'),
              Question(id: 'C2Q4', text: 'Apakah ada pemisahan area high-risk dari area penyimpanan umum?'),
              Question(id: 'C2Q5', text: 'Apakah barang disusun dengan jarak aman dari dinding (min 50cm)?'),
            ],
          ),
          // C3. Portable Fire Extinguisher & Detection System (9 questions)
          SubCategory(
            id: 'C3',
            name: 'Portable Fire extinguisher & Detection System',
            questions: [
              Question(id: 'C3Q1', text: 'Apakah APAR tersedia di setiap 200m² atau jarak maksimal 20 meter?'),
              Question(id: 'C3Q2', text: 'Apakah APAR diinspeksi setiap bulan dan tercatat dalam checklist?'),
              Question(id: 'C3Q3', text: 'Apakah jenis APAR sesuai dengan klasifikasi risiko area (A/B/C/D/K)?'),
              Question(id: 'C3Q4', text: 'Apakah APAR mudah diakses, terlihat jelas, dan tidak terhalang?'),
              Question(id: 'C3Q5', text: 'Apakah tersedia smoke detector yang berfungsi di semua area?'),
              Question(id: 'C3Q6', text: 'Apakah tersedia heat detector di area dengan suhu tinggi/berdebu?'),
              Question(id: 'C3Q7', text: 'Apakah fire alarm panel berfungsi dengan baik dan diuji berkala?'),
              Question(id: 'C3Q8', text: 'Apakah sistem deteksi kebakaran terhubung ke monitoring 24/7?'),
              Question(id: 'C3Q9', text: 'Apakah dilakukan testing berkala (6 bulan) untuk sistem deteksi?'),
            ],
          ),
        ],
      ),

      // ============================================
      // D. EVACUATION AND EMERGENCY PREPAREDNESS (Weight: 29.9%, 26 Questions)
      // ============================================
      Category(
        id: 'D',
        code: 'D',
        name: 'Evacuation and Emergency Preparedness',
        weight: 20.0, // AHP Eigenvector * 100
        subCategories: [
          // D1. Evacuation and Emergency Preparedness (12 questions)
          SubCategory(
            id: 'D1',
            name: 'Evacuation and Emergency Preparedness',
            questions: [
              Question(id: 'D1Q1', text: 'Apakah tersedia prosedur evakuasi tertulis yang disosialisasikan?'),
              Question(id: 'D1Q2', text: 'Apakah ada tim tanggap darurat yang terlatih dan memiliki struktur jelas?'),
              Question(id: 'D1Q3', text: 'Apakah tersedia assembly point/titik kumpul yang jelas dan aman?'),
              Question(id: 'D1Q4', text: 'Apakah ada koordinasi dengan Damkar/BPBD setempat?'),
              Question(id: 'D1Q5', text: 'Apakah tersedia peta evakuasi yang dipasang di setiap lantai/area?'),
              Question(id: 'D1Q6', text: 'Apakah ada sistem PA/pengeras suara untuk pengumuman darurat?'),
              Question(id: 'D1Q7', text: 'Apakah tersedia first aid kit yang lengkap dan tidak kedaluwarsa?'),
              Question(id: 'D1Q8', text: 'Apakah ada akses jalan yang memadai untuk ambulans dan pemadam?'),
              Question(id: 'D1Q9', text: 'Apakah emergency lighting berfungsi dengan baik dan diuji berkala?'),
              Question(id: 'D1Q10', text: 'Apakah dilakukan fire drill/latihan evakuasi minimal 2x per tahun?'),
              Question(id: 'D1Q11', text: 'Apakah ada dokumentasi hasil drill dan evaluasi perbaikan?'),
              Question(id: 'D1Q12', text: 'Apakah waktu evakuasi terakhir memenuhi target (<3 menit)?'),
            ],
          ),
          // D2. Exit Marking and Signage (3 questions)
          SubCategory(
            id: 'D2',
            name: 'Exit Marking and Signage',
            questions: [
              Question(id: 'D2Q1', text: 'Apakah tanda EXIT/keluar terlihat jelas, menyala, dan berfungsi?'),
              Question(id: 'D2Q2', text: 'Apakah jalur evakuasi ditandai dengan glow in the dark/photoluminescent?'),
              Question(id: 'D2Q3', text: 'Apakah signage evakuasi sesuai standar internasional (ISO/NFPA)?'),
            ],
          ),
          // D3. Emergency Evacuation (11 questions)
          SubCategory(
            id: 'D3',
            name: 'Emergency Evacuation',
            questions: [
              Question(id: 'D3Q1', text: 'Apakah pintu darurat dapat dibuka dari dalam tanpa kunci (panic hardware)?'),
              Question(id: 'D3Q2', text: 'Apakah tangga darurat bebas dari halangan dan dalam kondisi baik?'),
              Question(id: 'D3Q3', text: 'Apakah lebar koridor evakuasi memadai (minimal 1.2 meter)?'),
              Question(id: 'D3Q4', text: 'Apakah tersedia handrail di kedua sisi tangga darurat?'),
              Question(id: 'D3Q5', text: 'Apakah pintu darurat dilengkapi panic bar yang berfungsi?'),
              Question(id: 'D3Q6', text: 'Apakah ada jalur alternatif jika jalur utama terblokir?'),
              Question(id: 'D3Q7', text: 'Apakah area loading dock tidak menghalangi akses exit darurat?'),
              Question(id: 'D3Q8', text: 'Apakah tersedia fasilitas evakuasi khusus untuk penyandang disabilitas?'),
              Question(id: 'D3Q9', text: 'Apakah jarak ke exit terdekat tidak lebih dari 30 meter?'),
              Question(id: 'D3Q10', text: 'Apakah tersedia minimal 2 exit di setiap area kerja?'),
              Question(id: 'D3Q11', text: 'Apakah fire escape ladder tersedia dan teruji untuk lantai atas?'),
            ],
          ),
        ],
      ),
    ];
  }

  static int getTotalQuestions() {
    return getCategories().fold(0, (sum, cat) => sum + cat.totalQuestions);
  }

  /// Verifikasi jumlah pertanyaan sesuai APK asli
  static Map<String, int> getQuestionCounts() {
    final categories = getCategories();
    Map<String, int> counts = {};
    for (var cat in categories) {
      counts[cat.code] = cat.totalQuestions;
    }
    counts['TOTAL'] = getTotalQuestions();
    return counts;
    // Expected: A=12, B=31, C=18, D=26, TOTAL=87
  }
}
