import '../models/models.dart';

/// Assessment data dengan branching berdasarkan IndustryType
/// Manufacturing: pertanyaan kimia penuh + Likert bahan berbahaya
/// Residential/Commercial: pertanyaan kimia ringan/rumah tangga
class AssessmentData {
  static List<Category> getCategories({IndustryType industryType = IndustryType.manufacturing}) {
    return [
      _buildCategoryA(industryType),
      _buildCategoryB(industryType),
      _buildCategoryC(industryType),
      _buildCategoryD(industryType),
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // A. LEGAL COMPLIANCE (Weight: 15%)
  // ══════════════════════════════════════════════════════════════════════════
  static Category _buildCategoryA(IndustryType type) {
    final bool isManufacturing = type == IndustryType.manufacturing;

    return Category(
      id: 'A', code: 'A', name: 'Legal Compliance', weight: 15.0,
      subCategories: [
        SubCategory(id: 'A1', name: 'Perizinan & Legalitas', questions: [
          Question(id: 'A1Q1', text: 'Apakah perusahaan memiliki izin lingkungan (AMDAL/UKL-UPL) yang masih berlaku?'),
          Question(id: 'A1Q2', text: 'Apakah perusahaan memiliki izin operasional yang valid?'),
          Question(id: 'A1Q3', text: 'Apakah tersedia dokumentasi kepatuhan K3 yang lengkap?'),
          if (isManufacturing)
            Question(id: 'A1Q4', text: 'Apakah perusahaan memiliki izin penyimpanan/penggunaan Bahan Berbahaya & Beracun (B3)?'),
        ]),
        SubCategory(id: 'A2', name: 'Fire Safety Training', questions: [
          Question(id: 'A2Q1', text: 'Apakah dilakukan pelatihan pemadaman kebakaran secara berkala?'),
          Question(id: 'A2Q2', text: 'Apakah ada jadwal pelatihan evakuasi minimal 2x setahun?'),
          Question(id: 'A2Q3', text: 'Apakah tersedia rekaman/dokumentasi pelatihan?'),
          Question(id: 'A2Q4', text: 'Apakah semua karyawan baru mendapat pelatihan fire safety?'),
        ]),
        SubCategory(
          id: 'A3',
          name: isManufacturing ? 'Chemical & B3 Storage Compliance' : 'Household Chemical Safety',
          questions: isManufacturing ? _chemicalQuestionsManufacturing() : _chemicalQuestionsResidential(),
        ),
      ],
    );
  }

  static List<Question> _chemicalQuestionsManufacturing() => [
    Question(
      id: 'A3Q1', text: 'Seberapa baik penyimpanan bahan kimia sesuai standar MSDS/SDS?',
      type: QuestionType.likert,
      likertLow: 'Tidak sesuai sama sekali',
      likertHigh: 'Sepenuhnya sesuai & terdokumentasi',
    ),
    Question(
      id: 'A3Q2', text: 'Apakah tersedia label dan tanda bahaya (GHS) yang jelas pada semua wadah?',
      type: QuestionType.multiChoice,
      options: [
        'Tidak ada label sama sekali',
        'Beberapa wadah berlabel',
        'Sebagian besar berlabel, tidak sesuai GHS',
        'Semua berlabel sesuai GHS',
      ],
    ),
    Question(
      id: 'A3Q3', text: 'Tingkat pemisahan bahan kimia inkompatibel (asam-basa, oksidator-reduktor):',
      type: QuestionType.multiChoice,
      options: [
        'Disimpan bercampur tanpa pemisahan',
        'Dipisah sebagian, tanpa rambu',
        'Dipisah dengan rambu tapi tanpa secondary containment',
        'Dipisah penuh + secondary containment + rambu GHS',
      ],
    ),
    Question(
      id: 'A3Q4', text: 'Seberapa memadai secondary containment untuk bahan B3 cair?',
      type: QuestionType.likert,
      likertLow: 'Tidak ada secondary containment',
      likertHigh: 'Kapasitas ≥110% volume terbesar, berventilasi',
    ),
    Question(
      id: 'A3Q5', text: 'Apakah tersedia emergency shower & eyewash station di area kimia?',
      type: QuestionType.multiChoice,
      options: [
        'Tidak ada fasilitas darurat',
        'Ada eyewash saja, tidak berfungsi baik',
        'Ada shower & eyewash, diuji tidak berkala',
        'Ada shower & eyewash, diuji mingguan + terdokumentasi',
      ],
    ),
    Question(
      id: 'A3Q6', text: 'Apakah Material Safety Data Sheet (MSDS/SDS) tersedia dan mudah diakses operator?',
      type: QuestionType.likert,
      likertLow: 'Tidak ada MSDS',
      likertHigh: 'MSDS lengkap, digital + fisik, semua operator paham',
    ),
    Question(
      id: 'A3Q7', text: 'Bagaimana kondisi ventilasi di area penyimpanan dan penggunaan bahan kimia?',
      type: QuestionType.multiChoice,
      options: [
        'Tidak ada ventilasi, ruang tertutup',
        'Ventilasi alami saja (tidak memadai)',
        'Ventilasi mekanik ada, tidak rutin dikalibrasi',
        'Exhaust fan + monitoring gas, dikalibrasi berkala',
      ],
    ),
    Question(
      id: 'A3Q8', text: 'Apakah pekerja yang menangani B3 menggunakan APD yang sesuai (sarung tangan, kacamata, apron)?',
      type: QuestionType.likert,
      likertLow: 'Tidak ada APD sama sekali',
      likertHigh: 'APD lengkap sesuai MSDS, semua pekerja patuh',
    ),
  ];

  static List<Question> _chemicalQuestionsResidential() => [
    Question(id: 'A3Q1', text: 'Apakah bahan pembersih rumah tangga (bleach, solvent) disimpan terpisah dari makanan?'),
    Question(id: 'A3Q2', text: 'Apakah bahan mudah terbakar (thinner, bensin) disimpan di tempat berventilasi?'),
    Question(id: 'A3Q3', text: 'Apakah gas LPG/tabung gas disimpan di luar ruangan atau area berventilasi baik?'),
    Question(id: 'A3Q4', text: 'Apakah regulator dan selang gas LPG dalam kondisi baik dan tidak bocor?'),
    Question(id: 'A3Q5', text: 'Apakah ada detektor gas/CO di area dapur/ruang boiler?'),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // B. FIRE PREVENTION MEASURES (Weight: 38%)
  // ══════════════════════════════════════════════════════════════════════════
  static Category _buildCategoryB(IndustryType type) {
    final bool isManufacturing = type == IndustryType.manufacturing;
    return Category(
      id: 'B', code: 'B', name: 'Fire Prevention Measures', weight: 38.0,
      subCategories: [
        SubCategory(
          id: 'B1',
          name: 'Flammable Chemical & Liquid Management',
          questions: isManufacturing ? _flammableLiquidManufacturing() : _flammableLiquidResidential(),
        ),
        SubCategory(id: 'B2', name: 'Electrical Installation & Utilities', questions: [
          Question(id: 'B2Q1', text: 'Apakah instalasi listrik sesuai standar SNI/PUIL yang berlaku?'),
          Question(id: 'B2Q2', text: 'Apakah dilakukan inspeksi instalasi listrik secara berkala oleh teknisi bersertifikat?'),
          Question(id: 'B2Q3', text: 'Apakah panel listrik mudah diakses dan tidak terhalang oleh barang?'),
          Question(id: 'B2Q4', text: 'Apakah ada sistem grounding yang memadai untuk seluruh instalasi?'),
          Question(id: 'B2Q5', text: 'Apakah kabel-kabel listrik terorganisir dengan baik dan tidak ada yang terkelupas?'),
          Question(id: 'B2Q6', text: 'Apakah tersedia circuit breaker/MCB di semua area?'),
          Question(id: 'B2Q7', text: 'Apakah ada jadwal maintenance rutin untuk utilitas listrik?'),
        ]),
        SubCategory(id: 'B3', name: 'Electrical Safety Compliance', questions: [
          Question(id: 'B3Q1', text: 'Apakah semua peralatan listrik memiliki sertifikasi keamanan (SNI/CE)?'),
          Question(id: 'B3Q2', text: 'Apakah tidak ada penggunaan ekstensi kabel berlebihan atau sambungan ilegal?'),
          Question(id: 'B3Q3', text: 'Apakah ada pemisahan jalur listrik untuk sistem emergency?'),
          Question(id: 'B3Q4', text: 'Apakah tersedia lightning protection system yang berfungsi?'),
          Question(id: 'B3Q5', text: 'Apakah ada surge protection untuk peralatan elektronik sensitif?'),
        ]),
        SubCategory(id: 'B4', name: 'Building Structure', questions: [
          Question(id: 'B4Q1', text: 'Apakah struktur bangunan menggunakan material konstruksi tahan api sesuai standar?'),
          if (isManufacturing) ...[
            Question(id: 'B4Q2', text: 'Apakah area produksi memiliki fire-rated separation dari area penyimpanan B3?'),
            Question(id: 'B4Q3', text: 'Apakah loading dock terpisah dari area penyimpanan bahan berbahaya?'),
          ],
        ]),
        SubCategory(id: 'B5', name: 'Building Fire Resistance', questions: [
          Question(id: 'B5Q1', text: 'Apakah dinding pemisah antar area memenuhi standar fire rating minimal 2 jam?'),
          Question(id: 'B5Q2', text: 'Apakah pintu darurat memiliki fire rating yang sesuai standar?'),
          Question(id: 'B5Q3', text: 'Apakah tersedia fire damper pada sistem HVAC/ducting?'),
          Question(id: 'B5Q4', text: 'Apakah atap/ceiling memiliki fire resistance rating yang memadai?'),
          Question(id: 'B5Q5', text: 'Apakah ada compartmentalization yang memadai untuk mencegah penyebaran api?'),
          Question(id: 'B5Q6', text: 'Apakah fire stop/sealant terpasang pada penetrasi kabel dan pipa?'),
          Question(id: 'B5Q7', text: 'Apakah material finishing interior menggunakan bahan tahan api?'),
          Question(id: 'B5Q8', text: 'Apakah tersedia smoke barrier yang berfungsi di area kritis?'),
          Question(id: 'B5Q9', text: 'Apakah jarak antar bangunan memenuhi standar fire separation?'),
          Question(id: 'B5Q10', text: 'Apakah facade bangunan menggunakan material non-combustible?'),
          if (isManufacturing) ...[
            Question(id: 'B5Q11', text: 'Apakah area basement memiliki ventilasi dan proteksi kebakaran khusus?'),
            Question(id: 'B5Q12', text: 'Apakah shaft elevator dan tangga memiliki proteksi kebakaran?'),
            Question(id: 'B5Q13', text: 'Apakah ruang genset/transformer memiliki fire containment yang memadai?'),
          ],
        ]),
      ],
    );
  }

  static List<Question> _flammableLiquidManufacturing() => [
    Question(
      id: 'B1Q1', text: 'Seberapa sesuai kondisi penyimpanan cairan/gas mudah terbakar dengan standar NFPA 30?',
      type: QuestionType.likert,
      likertLow: 'Disimpan sembarangan, tidak ada ventilasi',
      likertHigh: 'Gudang khusus flammable, grounding, ventilasi mekanik',
    ),
    Question(
      id: 'B1Q2', text: 'Sistem ventilasi di area penyimpanan/penggunaan bahan mudah terbakar:',
      type: QuestionType.multiChoice,
      options: [
        'Tidak ada ventilasi',
        'Ventilasi alami (jendela) saja',
        'Exhaust fan manual, tidak selalu aktif',
        'Exhaust fan otomatis + sensor gas, 24/7',
      ],
    ),
    Question(id: 'B1Q3', text: 'Apakah jarak penyimpanan bahan mudah terbakar dari sumber panas/api terbuka ≥3 meter?'),
    Question(id: 'B1Q4', text: 'Apakah tersedia grounding/bonding untuk tangki dan drum penyimpanan cairan mudah terbakar?'),
    Question(id: 'B1Q5', text: 'Apakah ada prosedur tertulis untuk penanganan tumpahan bahan mudah terbakar (spill kit tersedia)?'),
    Question(
      id: 'B1Q6', text: 'Jumlah maksimum cairan mudah terbakar yang disimpan di area kerja (daily use area):',
      type: QuestionType.multiChoice,
      options: [
        'Melebihi batas peraturan, tanpa izin',
        'Melebihi batas tapi ada upaya pengendalian',
        'Sesuai batas, tanpa dokumentasi',
        'Sesuai batas + terdokumentasi + diinspeksi rutin',
      ],
    ),
  ];

  static List<Question> _flammableLiquidResidential() => [
    Question(id: 'B1Q1', text: 'Apakah cairan mudah terbakar (minyak tanah, thinner) disimpan jauh dari kompor/sumber api?'),
    Question(id: 'B1Q2', text: 'Apakah wadah bahan mudah terbakar tertutup rapat saat tidak digunakan?'),
    Question(id: 'B1Q3', text: 'Apakah tidak ada penyimpanan jeriken BBM di dalam ruangan hunian?'),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // C. FIRE PROTECTION SYSTEM (Weight: 27%)
  // ══════════════════════════════════════════════════════════════════════════
  static Category _buildCategoryC(IndustryType type) {
    final bool isManufacturing = type == IndustryType.manufacturing;
    return Category(
      id: 'C', code: 'C', name: 'Fire Protection System', weight: 27.0,
      subCategories: [
        SubCategory(id: 'C1', name: 'Fire Suppression System', questions: [
          Question(id: 'C1Q1', text: 'Apakah tersedia hydrant dengan tekanan air memadai (min 3.5 bar)?'),
          Question(id: 'C1Q2', text: 'Apakah sistem sprinkler berfungsi dengan baik dan diuji berkala?'),
          Question(id: 'C1Q3', text: 'Apakah ada fire pump dengan backup power yang berfungsi?'),
          Question(id: 'C1Q4', text: 'Apakah water reservoir memadai untuk operasi pemadam minimal 2 jam?'),
          if (isManufacturing)
            Question(
              id: 'C1Q5', text: 'Jenis sistem suppression khusus untuk area B3/flammable liquid:',
              type: QuestionType.multiChoice,
              options: [
                'Tidak ada sistem suppression khusus',
                'Hanya APAR (tidak memadai untuk skala besar)',
                'Foam system atau CO2 system (belum diuji)',
                'Foam/CO2/clean agent system, diuji tahunan + sertifikasi',
              ],
            ),
        ]),
        if (isManufacturing)
          SubCategory(id: 'C2', name: 'Warehouse & Storage Fire Protection', questions: [
            Question(id: 'C2Q1', text: 'Apakah jarak rak penyimpanan ke sprinkler sesuai standar (min 45cm)?'),
            Question(id: 'C2Q2', text: 'Apakah ada sistem deteksi asap yang berfungsi di area warehouse?'),
            Question(id: 'C2Q3', text: 'Apakah aisle clearance memadai untuk akses pemadam dan evakuasi?'),
            Question(id: 'C2Q4', text: 'Apakah ada pemisahan area high-risk dari area penyimpanan umum?'),
            Question(id: 'C2Q5', text: 'Apakah barang disusun dengan jarak aman dari dinding (min 50cm)?'),
          ]),
        SubCategory(id: 'C3', name: 'APAR & Detection System', questions: [
          Question(
            id: 'C3Q1', text: 'Ketersediaan dan penempatan APAR sesuai standar:',
            type: QuestionType.multiChoice,
            options: [
              'APAR tidak ada atau tidak memadai',
              'Ada APAR tapi penempatan tidak sesuai standar',
              'APAR sesuai jumlah, belum sesuai jenis area',
              'APAR sesuai jumlah, jenis, dan jarak (≤20m atau ≤200m²)',
            ],
          ),
          Question(id: 'C3Q2', text: 'Apakah APAR diinspeksi setiap bulan dan tercatat dalam checklist?'),
          Question(id: 'C3Q3', text: 'Apakah jenis APAR sesuai dengan klasifikasi risiko area (A/B/C/D/K)?'),
          Question(id: 'C3Q4', text: 'Apakah APAR mudah diakses, terlihat jelas, dan tidak terhalang?'),
          Question(id: 'C3Q5', text: 'Apakah tersedia smoke detector yang berfungsi di semua area?'),
          Question(id: 'C3Q6', text: 'Apakah tersedia heat detector di area dengan suhu tinggi/berdebu?'),
          Question(id: 'C3Q7', text: 'Apakah fire alarm panel berfungsi dengan baik dan diuji berkala?'),
          Question(id: 'C3Q8', text: 'Apakah sistem deteksi kebakaran terhubung ke monitoring 24/7?'),
          Question(id: 'C3Q9', text: 'Apakah dilakukan testing berkala (6 bulan) untuk sistem deteksi?'),
        ]),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // D. EVACUATION & EMERGENCY (Weight: 20%)
  // ══════════════════════════════════════════════════════════════════════════
  static Category _buildCategoryD(IndustryType type) {
    return Category(
      id: 'D', code: 'D', name: 'Evacuation and Emergency Preparedness', weight: 20.0,
      subCategories: [
        SubCategory(id: 'D1', name: 'Emergency Preparedness', questions: [
          Question(id: 'D1Q1', text: 'Apakah tersedia prosedur evakuasi tertulis yang disosialisasikan?'),
          Question(id: 'D1Q2', text: 'Apakah ada tim tanggap darurat yang terlatih dan memiliki struktur jelas?'),
          Question(id: 'D1Q3', text: 'Apakah tersedia assembly point/titik kumpul yang jelas dan aman?'),
          Question(id: 'D1Q4', text: 'Apakah ada koordinasi dengan Damkar/BPBD setempat?'),
          Question(id: 'D1Q5', text: 'Apakah tersedia peta evakuasi yang dipasang di setiap lantai/area?'),
          Question(id: 'D1Q6', text: 'Apakah ada sistem PA/pengeras suara untuk pengumuman darurat?'),
          Question(id: 'D1Q7', text: 'Apakah tersedia first aid kit yang lengkap dan tidak kedaluwarsa?'),
          Question(id: 'D1Q8', text: 'Apakah ada akses jalan yang memadai untuk ambulans dan pemadam?'),
          Question(id: 'D1Q9', text: 'Apakah emergency lighting berfungsi dengan baik dan diuji berkala?'),
          Question(
            id: 'D1Q10', text: 'Frekuensi fire drill/latihan evakuasi per tahun:',
            type: QuestionType.multiChoice,
            options: [
              'Belum pernah dilakukan',
              '1x per tahun',
              '2x per tahun',
              '≥3x per tahun + evaluasi tertulis',
            ],
          ),
          Question(id: 'D1Q11', text: 'Apakah ada dokumentasi hasil drill dan evaluasi perbaikan?'),
          Question(id: 'D1Q12', text: 'Apakah waktu evakuasi terakhir memenuhi target (<3 menit)?'),
        ]),
        SubCategory(id: 'D2', name: 'Exit Marking & Signage', questions: [
          Question(id: 'D2Q1', text: 'Apakah tanda EXIT/keluar terlihat jelas, menyala, dan berfungsi?'),
          Question(id: 'D2Q2', text: 'Apakah jalur evakuasi ditandai dengan glow-in-the-dark/photoluminescent?'),
          Question(id: 'D2Q3', text: 'Apakah signage evakuasi sesuai standar internasional (ISO/NFPA)?'),
        ]),
        SubCategory(id: 'D3', name: 'Emergency Evacuation Route', questions: [
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
        ]),
      ],
    );
  }

  static int getTotalQuestions({IndustryType industryType = IndustryType.manufacturing}) {
    return getCategories(industryType: industryType)
        .fold(0, (sum, cat) => sum + cat.totalQuestions);
  }

  static Map<String, int> getQuestionCounts({IndustryType industryType = IndustryType.manufacturing}) {
    final categories = getCategories(industryType: industryType);
    Map<String, int> counts = {};
    for (var cat in categories) {
      counts[cat.code] = cat.totalQuestions;
    }
    counts['TOTAL'] = getTotalQuestions(industryType: industryType);
    return counts;
  }
}
