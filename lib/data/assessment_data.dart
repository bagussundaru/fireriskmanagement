import '../models/models.dart';

/// Data assessment yang dinamis berdasarkan jenis fasilitas (Manufaktur vs Residensial)
class AssessmentData {
  static List<Category> getCategories([String factoryType = 'Manufacturing']) {
    final bool isManufacturing = factoryType.toLowerCase() == 'manufacturing';

    return [
      // ============================================
      // A. LEGAL COMPLIANCE
      // ============================================
      Category(
        id: 'A',
        code: 'A',
        name: 'Legal Compliance',
        weight: 15.0, // AHP Eigenvector * 100
        subCategories: [
          SubCategory(
            id: 'A1',
            name: 'Legal Compliance',
            questions: [
              Question(id: 'A1Q1', text: 'Apakah fasilitas memiliki izin lingkungan yang masih berlaku?'),
              Question(id: 'A1Q2', text: 'Apakah fasilitas memiliki izin operasional yang valid?'),
              Question(id: 'A1Q3', text: 'Apakah tersedia dokumentasi kepatuhan K3/Fire Safety yang lengkap?'),
            ],
          ),
          SubCategory(
            id: 'A2',
            name: 'Fire Safety Training',
            questions: [
              Question(id: 'A2Q1', text: 'Apakah dilakukan simulasi pemadaman kebakaran secara berkala?'),
              Question(id: 'A2Q2', text: 'Apakah ada edukasi prosedur evakuasi minimal 2x setahun?'),
              Question(id: 'A2Q3', text: 'Apakah tersedia rekaman/dokumentasi simulasi tersebut?'),
            ],
          ),
          if (isManufacturing)
            SubCategory(
              id: 'A3',
              name: 'Chemical Storage Compliance',
              questions: [
                Question(id: 'A3Q1', text: 'Apakah penyimpanan bahan kimia sesuai standar MSDS?', type: QuestionType.likert),
                Question(id: 'A3Q2', text: 'Apakah tersedia label dan tanda bahaya yang jelas?', type: QuestionType.likert),
                Question(id: 'A3Q3', text: 'Apakah ada pemisahan bahan kimia inkompatibel?', type: QuestionType.likert),
                Question(id: 'A3Q4', text: 'Apakah ada secondary containment untuk bahan berbahaya?', type: QuestionType.likert),
                Question(id: 'A3Q5', text: 'Apakah tersedia shower darurat di area kimia?', type: QuestionType.likert),
              ],
            ),
        ],
      ),

      // ============================================
      // B. FIRE PREVENTION MEASURES
      // ============================================
      Category(
        id: 'B',
        code: 'B',
        name: 'Fire Prevention Measures',
        weight: 38.0, // AHP Eigenvector * 100
        subCategories: [
          if (isManufacturing)
            SubCategory(
              id: 'B1',
              name: 'Flammable Chemical and Liquid',
              questions: [
                Question(id: 'B1Q1', text: 'Kondisi penyimpanan cairan mudah terbakar (ventilasi memadai).', type: QuestionType.likert),
                Question(id: 'B1Q2', text: 'Sistem Exhaust/Ventilasi di area penyimpanan bahan mudah terbakar.', type: QuestionType.likert),
                Question(id: 'B1Q3', text: 'Jarak aman penyimpanan bahan mudah terbakar dari sumber panas.', type: QuestionType.likert),
                Question(id: 'B1Q4', text: 'Tersedianya grounding/bonding untuk tangki penyimpanan kimia.', type: QuestionType.likert),
                Question(id: 'B1Q5', text: 'Prosedur penanganan tumpahan bahan mudah terbakar.', type: QuestionType.likert),
              ],
            ),
          SubCategory(
            id: 'B2',
            name: 'Electrical Installation and Utilities',
            questions: [
              Question(id: 'B2Q1', text: 'Apakah instalasi listrik sesuai standar SNI/PUIL yang berlaku?'),
              Question(id: 'B2Q2', text: 'Apakah dilakukan inspeksi instalasi listrik secara berkala oleh teknisi/PLN?'),
              Question(id: 'B2Q3', text: 'Apakah panel listrik mudah diakses dan tertutup aman?'),
              Question(id: 'B2Q4', text: 'Apakah ada sistem grounding yang memadai untuk instalasi utama?'),
              Question(id: 'B2Q5', text: 'Apakah kabel-kabel tertata rapi dan tidak ada yang terkelupas?'),
              Question(id: 'B2Q6', text: 'Apakah tersedia MCB tersendiri per zona/area?'),
            ],
          ),
          SubCategory(
            id: 'B3',
            name: 'Electrical Safety Compliance',
            questions: [
              Question(id: 'B3Q1', text: 'Apakah semua peralatan utama listrik memiliki sertifikasi keamanan (SNI)?'),
              Question(id: 'B3Q2', text: 'Apakah menghindari penggunaan sambungan T berlebihan (Overload)?'),
              Question(id: 'B3Q3', text: 'Apakah tersedia MCB khusus pencegah kebocoran arus (ELCB/RCBO)?'),
            ],
          ),
          SubCategory(
            id: 'B4',
            name: 'Building Fire Resistance',
            questions: [
              Question(id: 'B4Q1', text: 'Apakah dinding utama pemisah terbangun dari bata/beton non-combustible?'),
              Question(id: 'B4Q2', text: 'Apakah material atap tidak menggunakan bahan yang cepat merambatkan api?'),
              Question(id: 'B4Q3', text: 'Apakah jalur kabel/pipa antar lantai memiliki sumbatan rapat (fire seal)?'),
              if (isManufacturing)
                Question(id: 'B4Q4', text: 'Apakah jarak antar bangunan/gudang memenuhi standar fire separation?'),
              Question(id: 'B4Q5', text: 'Apakah area dapur (kitchen) menggunakan material yang tidak mudah terbakar di kabinet sekitarnya?'),
            ],
          ),
        ],
      ),

      // ============================================
      // C. FIRE PROTECTION SYSTEM
      // ============================================
      Category(
        id: 'C',
        code: 'C',
        name: 'Fire Protection System',
        weight: 27.0, // AHP Eigenvector * 100
        subCategories: [
          SubCategory(
            id: 'C1',
            name: 'Water Based Protection',
            questions: [
              if (isManufacturing)
                Question(id: 'C1Q1', text: 'Apakah tersedia hydrant pilar/gedung dengan tekanan air memadai?'),
              if (isManufacturing)
                Question(id: 'C1Q2', text: 'Apakah ada fire pump (Jockey, Electric, Diesel) yang rutin diuji?'),
              Question(id: 'C1Q3', text: 'Apakah sistem sprinkler berfungsi dan diinspeksi secara rutin?'),
            ],
          ),
          SubCategory(
            id: 'C2',
            name: 'Portable Fire Extinguisher (APAR)',
            questions: [
              Question(id: 'C2Q1', text: 'Apakah APAR tersedia di setiap lantai atau jangkauan maksimal 15-20 meter?'),
              Question(id: 'C2Q2', text: 'Apakah APAR diinspeksi tekanan dan fisiknya secara rutin (min 6 bulan sekali)?'),
              Question(id: 'C2Q3', text: 'Apakah jenis APAR sesuai dengan risikonya (khusus dapur beda dengan area listrik)?'),
              Question(id: 'C2Q4', text: 'Apakah diletakkan mudah diakses, terlihat jelas, tidak dipindah sembarangan?'),
            ],
          ),
          SubCategory(
            id: 'C3',
            name: 'Detection System',
            questions: [
              Question(id: 'C3Q1', text: 'Apakah tersedia smoke detector di kamar tidur / ruang arsip / gudang tertutup?'),
              Question(id: 'C3Q2', text: 'Apakah tersedia heat detector di ruang memasak (Dapur) / mesin panas?'),
              Question(id: 'C3Q3', text: 'Apakah fire alarm merespon dengan bunyi sirene (lonceng/horn) yang keras?'),
            ],
          ),
        ],
      ),

      // ============================================
      // D. EVACUATION AND EMERGENCY PREPAREDNESS
      // ============================================
      Category(
        id: 'D',
        code: 'D',
        name: 'Evacuation and Emergency Preparedness',
        weight: 20.0, // AHP Eigenvector * 100
        subCategories: [
          SubCategory(
            id: 'D1',
            name: 'Emergency Planning',
            questions: [
              Question(id: 'D1Q1', text: 'Apakah titik kumpul (Assembly Point) ditentukan dan disosialisasikan?'),
              Question(id: 'D1Q2', text: 'Apakah tersedia denah/peta rute evakuasi di koridor bangunan?'),
              Question(id: 'D1Q3', text: 'Apakah nomor telepon pemadam kebakaran ditempel secara permanen di titik mudah terlihat?'),
              Question(id: 'D1Q4', text: 'Apakah kotak P3K (First Aid Kit) tersedia dengan isi memadai?'),
            ],
          ),
          SubCategory(
            id: 'D2',
            name: 'Exit Access and Signage',
            questions: [
              Question(id: 'D2Q1', text: 'Apakah tanda jalur evakuasi (EXIT) terlihat menyala dengan baik meskipun lampu padam (fosfor/listrik)?'),
              Question(id: 'D2Q2', text: 'Apakah koridor evakuasi / selasar tidak terhalang barang rongsok/furnitur?'),
              Question(id: 'D2Q3', text: 'Apakah pintu utama / pintu darurat dapat dibuka langsung dari dalam tanpa butuh kunci khusus saat panik?'),
              Question(id: 'D2Q4', text: 'Apakah tangga tidak licin dan dilengkapi ruji pegangan tangan (handrail)?'),
              Question(id: 'D2Q5', text: 'Apakah area luar gedung untuk akses unit truk pemadam bisa dilalui tanpa hambatan permanen?'),
            ],
          ),
        ],
      ),
    ];
  }

  static int getTotalQuestions([String factoryType = 'Manufacturing']) {
    return getCategories(factoryType).fold(0, (sum, cat) => sum + cat.totalQuestions);
  }
}
