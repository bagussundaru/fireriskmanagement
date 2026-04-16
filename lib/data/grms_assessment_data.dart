import '../models/models.dart';

/// GRMS 2167.01a Fire Risk Assessment Tool
/// Assessment framework with N/A / Yes / No (triState) answers
/// Parts A-G based on GRMS 2167.01a document
class GrmsAssessmentData {

  // ══════════════════════════════════════════════════════════════════════════
  // PART A: Risk Assessment Details — form fields (not scored questions)
  // ══════════════════════════════════════════════════════════════════════════
  static const List<String> partAFields = [
    'Employer / Person having control of premises',
    'Address of premises',
    'Person(s) consulted',
    'Assessor',
    'Date of fire risk assessment',
    'Date of previous fire risk assessment',
    'Suggested date for review',
  ];

  static const List<String> partAFieldsId = [
    'Pemberi kerja / Penanggung jawab gedung',
    'Alamat fasilitas',
    'Orang yang dikonsultasikan',
    'Assessor',
    'Tanggal asesmen risiko kebakaran',
    'Tanggal asesmen sebelumnya',
    'Tanggal review yang disarankan',
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // PART B: General Information — form fields
  // ══════════════════════════════════════════════════════════════════════════
  static const List<String> partBSection1Fields = [
    '1.1 Number of Floors',
    '1.2 Approximate Floor Area (m²)',
    '1.3 Brief details of construction',
    '1.4 Use of Premises',
  ];

  static const List<String> partBSection2Fields = [
    '2.1 Approximate maximum number of occupants',
    '2.2 Approximate number of employees at any one time',
    '2.3 Maximum number of public at any one time',
    '2.4 Associated times/hours of occupation',
  ];

  static const List<String> partBSection3Fields = [
    '3.1 Sleeping occupants',
    '3.2 Disabled occupants',
    '3.3 Occupants in remote areas / lone workers',
    '3.4 Young workers',
    '3.5 Others',
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // All Q&A sections (Parts C, D, E) with triState questions
  // ══════════════════════════════════════════════════════════════════════════
  static List<GrmsSection> getAllSections() => [
    ..._partCSections(),
    ..._partDSections(),
    ..._partESections(),
  ];

  // ─── PART C: Fire Hazards ─────────────────────────────────────────────────
  static List<GrmsSection> _partCSections() => [
    GrmsSection(
      part: 'C',
      sectionNumber: '1',
      titleEn: 'Electrical Sources of Ignition',
      titleId: 'Sumber Penyalaan dari Listrik',
      questions: [
        GrmsQuestion(id: 'C1Q1',
          textEn: 'Have reasonable measures been taken to prevent electrical fires?',
          textId: 'Apakah tindakan wajar telah diambil untuk mencegah kebakaran listrik?'),
        GrmsQuestion(id: 'C1Q2',
          textEn: 'Fixed electrical installations periodically inspected and tested?',
          textId: 'Apakah instalasi listrik tetap diperiksa dan diuji secara berkala?'),
        GrmsQuestion(id: 'C1Q3',
          textEn: 'Portable appliance testing carried out?',
          textId: 'Apakah pengujian peralatan portabel dilakukan?'),
        GrmsQuestion(id: 'C1Q4',
          textEn: 'Suitable policy regarding the use of personal electrical appliances?',
          textId: 'Apakah ada kebijakan penggunaan peralatan listrik pribadi yang sesuai?'),
        GrmsQuestion(id: 'C1Q5',
          textEn: 'Suitable limitation of trailing leads and adapters?',
          textId: 'Apakah ada pembatasan kabel penyambung dan adaptor yang sesuai?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '2',
      titleEn: 'Smoking',
      titleId: 'Merokok',
      questions: [
        GrmsQuestion(id: 'C2Q1',
          textEn: 'Have reasonable measures been taken to prevent fires as a result of smoking?',
          textId: 'Apakah tindakan wajar telah diambil untuk mencegah kebakaran akibat merokok?'),
        GrmsQuestion(id: 'C2Q2',
          textEn: 'Smoking prohibited on the premises?',
          textId: 'Apakah merokok dilarang di dalam gedung?'),
        GrmsQuestion(id: 'C2Q3',
          textEn: 'Smoking allowed only in designated areas (e.g. smoking shelters)?',
          textId: 'Apakah merokok hanya diizinkan di area khusus (mis. shelter merokok)?'),
        GrmsQuestion(id: 'C2Q4',
          textEn: 'Any evidence of breaches of smoking policy at time of inspection?',
          textId: 'Apakah ada bukti pelanggaran kebijakan merokok saat inspeksi?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '3',
      titleEn: 'Willful Fire Raising',
      titleId: 'Pembakaran yang Disengaja',
      questions: [
        GrmsQuestion(id: 'C3Q1',
          textEn: 'Is there provision of basic security against willful fire raising by outsiders?',
          textId: 'Apakah tersedia keamanan dasar terhadap pembakaran yang disengaja oleh pihak luar?'),
        GrmsQuestion(id: 'C3Q2',
          textEn: 'Is there an absence of unnecessary fire load in close proximity to the premises?',
          textId: 'Apakah tidak ada beban mudah terbakar yang tidak perlu di dekat gedung?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '4',
      titleEn: 'Portable Heaters and Heating Installations',
      titleId: 'Pemanas Portabel dan Instalasi Pemanas',
      questions: [
        GrmsQuestion(id: 'C4Q1',
          textEn: 'Is the use of portable heaters avoided as far as practicable?',
          textId: 'Apakah penggunaan pemanas portabel dihindari semaksimal mungkin?'),
        GrmsQuestion(id: 'C4Q2',
          textEn: 'Is the use of more hazardous heater types avoided (radiant bar fires, LPG appliances)?',
          textId: 'Apakah penggunaan tipe pemanas berbahaya (radiant bar, LPG) dihindari?'),
        GrmsQuestion(id: 'C4Q3',
          textEn: 'Are suitable measures taken to minimize ignition of combustible materials?',
          textId: 'Apakah tindakan sesuai diambil untuk meminimalkan penyalaan bahan mudah terbakar?'),
        GrmsQuestion(id: 'C4Q4',
          textEn: 'Are fixed heating installations subject to regular maintenance?',
          textId: 'Apakah instalasi pemanas tetap mendapat perawatan rutin?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '5',
      titleEn: 'Cooking',
      titleId: 'Memasak',
      questions: [
        GrmsQuestion(id: 'C5Q1',
          textEn: 'Have reasonable measures been taken to prevent fires as a result of cooking?',
          textId: 'Apakah tindakan wajar telah diambil untuk mencegah kebakaran akibat memasak?'),
        GrmsQuestion(id: 'C5Q2',
          textEn: 'Filters changed and ductwork cleaned regularly?',
          textId: 'Apakah filter diganti dan saluran udara dibersihkan secara berkala?'),
        GrmsQuestion(id: 'C5Q3',
          textEn: 'Suitable extinguishing appliances available in cooking area?',
          textId: 'Apakah alat pemadam tersedia di area memasak?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '6',
      titleEn: 'Lightning',
      titleId: 'Petir',
      questions: [
        GrmsQuestion(id: 'C6Q1',
          textEn: 'Does the premises have a lightning protection system?',
          textId: 'Apakah gedung memiliki sistem perlindungan petir?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '7',
      titleEn: 'Housekeeping',
      titleId: 'Kebersihan & Tata Kelola Gedung',
      questions: [
        GrmsQuestion(id: 'C7Q1',
          textEn: 'Is the standard of housekeeping adequate?',
          textId: 'Apakah standar kebersihan gedung memadai?'),
        GrmsQuestion(id: 'C7Q2',
          textEn: 'Combustible materials appear to be separated from ignition sources?',
          textId: 'Apakah bahan mudah terbakar terpisah dari sumber penyalaan?'),
        GrmsQuestion(id: 'C7Q3',
          textEn: 'Avoidance of unnecessary accumulation of combustible materials or waste?',
          textId: 'Apakah penumpukan bahan mudah terbakar atau limbah yang tidak perlu dihindari?'),
        GrmsQuestion(id: 'C7Q4',
          textEn: 'Appropriate storage of hazardous materials where applicable?',
          textId: 'Apakah penyimpanan bahan berbahaya sudah sesuai?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '8',
      titleEn: 'Hazards from Outside Contractors & Building Works',
      titleId: 'Bahaya dari Kontraktor Luar & Pekerjaan Bangunan',
      questions: [
        GrmsQuestion(id: 'C8Q1',
          textEn: 'Are fire safety conditions communicated to outside contractors?',
          textId: 'Apakah kondisi keselamatan kebakaran dikomunikasikan ke kontraktor luar?'),
        GrmsQuestion(id: 'C8Q2',
          textEn: 'Is there satisfactory control over works by outside contractors (incl. hot work permits)?',
          textId: 'Apakah ada kontrol memuaskan atas pekerjaan kontraktor luar (termasuk izin hot work)?'),
        GrmsQuestion(id: 'C8Q3',
          textEn: 'Are suitable precautions taken during "hot work" by in-house personnel?',
          textId: 'Apakah tindakan pencegahan sesuai diambil saat "hot work" oleh personel internal?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '9',
      titleEn: 'Dangerous Substances',
      titleId: 'Zat Berbahaya',
      questions: [
        GrmsQuestion(id: 'C9Q1',
          textEn: 'Are general fire precautions adequate to address hazards associated with dangerous substances?',
          textId: 'Apakah tindakan pencegahan kebakaran umum memadai untuk menangani bahaya zat berbahaya?'),
        GrmsQuestion(id: 'C9Q2',
          textEn: 'If applicable, has a specific risk assessment been carried out as required by DSEAR 2002?',
          textId: 'Jika berlaku, apakah asesmen risiko spesifik telah dilakukan sesuai regulasi B3?'),
      ],
    ),
    GrmsSection(
      part: 'C',
      sectionNumber: '10',
      titleEn: 'Other Significant Fire Hazards',
      titleId: 'Bahaya Kebakaran Signifikan Lainnya',
      questions: [
        GrmsQuestion(id: 'C10Q1',
          textEn: 'Are all other significant fire hazards and process hazards identified and controlled?',
          textId: 'Apakah semua bahaya kebakaran signifikan lainnya telah diidentifikasi dan dikendalikan?',
          hasCommentField: true),
      ],
    ),
  ];

  // ─── PART D: Fire Protection Measures ────────────────────────────────────
  static List<GrmsSection> _partDSections() => [
    GrmsSection(
      part: 'D',
      sectionNumber: '1',
      titleEn: 'Means of Escape from Fire',
      titleId: 'Sarana Evakuasi dari Kebakaran',
      questions: [
        GrmsQuestion(id: 'D1Q1',
          textEn: 'Is it considered that the premises are provided with reasonable means of escape?',
          textId: 'Apakah gedung menyediakan sarana evakuasi yang wajar?'),
        GrmsQuestion(id: 'D1Q2',
          textEn: 'Adequate design of escape routes?',
          textId: 'Apakah rancangan jalur evakuasi memadai?'),
        GrmsQuestion(id: 'D1Q3',
          textEn: 'Adequate provision of exits?',
          textId: 'Apakah ketersediaan pintu keluar memadai?'),
        GrmsQuestion(id: 'D1Q4',
          textEn: 'Exits easily and immediately openable where necessary?',
          textId: 'Apakah pintu keluar mudah dan langsung dapat dibuka bila perlu?'),
        GrmsQuestion(id: 'D1Q5',
          textEn: 'Fire exits open in direction of escape where necessary?',
          textId: 'Apakah pintu darurat terbuka ke arah evakuasi bila perlu?'),
        GrmsQuestion(id: 'D1Q6',
          textEn: 'Avoidance of sliding or revolving doors as fire exits?',
          textId: 'Apakah pintu geser atau putar dihindari sebagai pintu darurat kebakaran?'),
        GrmsQuestion(id: 'D1Q7',
          textEn: 'Satisfactory means for securing exits?',
          textId: 'Apakah pengamanan pintu keluar memuaskan?'),
        GrmsQuestion(id: 'D1Q8',
          textEn: 'Reasonable travel distances where there is a single direction of travel?',
          textId: 'Apakah jarak tempuh wajar saat hanya ada satu arah evakuasi?'),
        GrmsQuestion(id: 'D1Q9',
          textEn: 'Reasonable travel distances where there are alternative means of escape?',
          textId: 'Apakah jarak tempuh wajar saat ada jalur evakuasi alternatif?'),
        GrmsQuestion(id: 'D1Q10',
          textEn: 'Suitable protection of escape routes?',
          textId: 'Apakah perlindungan jalur evakuasi memadai?'),
        GrmsQuestion(id: 'D1Q11',
          textEn: 'Escape routes unobstructed?',
          textId: 'Apakah jalur evakuasi bebas halangan?'),
        GrmsQuestion(id: 'D1Q12',
          textEn: 'Reasonable arrangements for means of escape for disabled people?',
          textId: 'Apakah ada pengaturan evakuasi yang wajar untuk penyandang disabilitas?'),
      ],
    ),
    GrmsSection(
      part: 'D',
      sectionNumber: '2',
      titleEn: 'Measures to Limit Fire Spread and Development',
      titleId: 'Tindakan Membatasi Penyebaran Api',
      questions: [
        GrmsQuestion(id: 'D2Q1',
          textEn: 'Is there compartmentation of a reasonable standard?',
          textId: 'Apakah ada kompartemenisasi dengan standar yang wajar?'),
        GrmsQuestion(id: 'D2Q2',
          textEn: 'Is there a limitation of building materials that might promote fire spread?',
          textId: 'Apakah ada pembatasan material bangunan yang dapat mendorong penyebaran api?'),
        GrmsQuestion(id: 'D2Q3',
          textEn: 'Are fire dampers provided as necessary to protect critical means of escape?',
          textId: 'Apakah fire damper tersedia untuk melindungi jalur evakuasi kritis?'),
      ],
    ),
    GrmsSection(
      part: 'D',
      sectionNumber: '3',
      titleEn: 'Emergency Escape Lighting',
      titleId: 'Pencahayaan Darurat',
      questions: [
        GrmsQuestion(id: 'D3Q1',
          textEn: 'A reasonable standard of emergency escape lighting system is provided?',
          textId: 'Apakah sistem pencahayaan darurat berstandar wajar tersedia?'),
      ],
    ),
    GrmsSection(
      part: 'D',
      sectionNumber: '4',
      titleEn: 'Fire Safety Signs and Notices',
      titleId: 'Rambu dan Pemberitahuan Keselamatan Kebakaran',
      questions: [
        GrmsQuestion(id: 'D4Q1',
          textEn: 'A reasonable standard of fire safety signs and notices are in place?',
          textId: 'Apakah rambu dan pemberitahuan keselamatan kebakaran berstandar wajar terpasang?'),
      ],
    ),
    GrmsSection(
      part: 'D',
      sectionNumber: '5',
      titleEn: 'Means of Giving Warning in the Event of Fire',
      titleId: 'Sistem Peringatan Kebakaran',
      questions: [
        GrmsQuestion(id: 'D5Q1',
          textEn: 'A reasonable manually operated electrical fire alarm system is in place?',
          textId: 'Apakah sistem alarm kebakaran listrik manual yang wajar terpasang?'),
        GrmsQuestion(id: 'D5Q2',
          textEn: 'Automatic fire detection provided?',
          textId: 'Apakah deteksi kebakaran otomatis tersedia?'),
        GrmsQuestion(id: 'D5Q3',
          textEn: 'Extent of automatic fire detection generally appropriate for the occupancy and fire risk?',
          textId: 'Apakah cakupan deteksi otomatis sesuai dengan hunian dan risiko kebakaran?'),
        GrmsQuestion(id: 'D5Q4',
          textEn: 'Remote transmission of alarm signals?',
          textId: 'Apakah transmisi sinyal alarm jarak jauh tersedia?'),
      ],
    ),
    GrmsSection(
      part: 'D',
      sectionNumber: '6',
      titleEn: 'Manual Fire Extinguishing Appliances',
      titleId: 'Alat Pemadam Manual',
      questions: [
        GrmsQuestion(id: 'D6Q1',
          textEn: 'Reasonable provision of portable fire extinguishers?',
          textId: 'Apakah APAR tersedia dengan jumlah yang wajar?'),
        GrmsQuestion(id: 'D6Q2',
          textEn: 'Hose reels provided?',
          textId: 'Apakah selang kebakaran (hose reel) tersedia?'),
        GrmsQuestion(id: 'D6Q3',
          textEn: 'Are all fire extinguishing appliances readily accessible?',
          textId: 'Apakah semua alat pemadam mudah diakses?'),
      ],
    ),
    GrmsSection(
      part: 'D',
      sectionNumber: '7',
      titleEn: 'Automatic Fire Extinguishing Systems',
      titleId: 'Sistem Pemadam Otomatis',
      questions: [
        GrmsQuestion(id: 'D7Q1',
          textEn: 'Is an automatic fire extinguishing system installed and maintained?',
          textId: 'Apakah sistem pemadam otomatis terpasang dan terawat?'),
      ],
    ),
    GrmsSection(
      part: 'D',
      sectionNumber: '8',
      titleEn: 'Other Relevant Fixed Systems and Equipment',
      titleId: 'Sistem & Peralatan Tetap Relevan Lainnya',
      questions: [
        GrmsQuestion(id: 'D8Q1',
          textEn: 'Suitable provision of fire-fighters switches for high voltage luminous tube signs etc.?',
          textId: 'Apakah saklar pemadam untuk papan neon tegangan tinggi dll. tersedia?'),
      ],
    ),
  ];

  // ─── PART E: Management of Fire Safety ───────────────────────────────────
  static List<GrmsSection> _partESections() => [
    GrmsSection(
      part: 'E',
      sectionNumber: '1',
      titleEn: 'Procedures and Arrangements',
      titleId: 'Prosedur dan Pengaturan',
      questions: [
        GrmsQuestion(id: 'E1Q1',
          textEn: 'Is there a suitable record of the fire safety arrangements?',
          textId: 'Apakah ada catatan yang sesuai tentang pengaturan keselamatan kebakaran?'),
        GrmsQuestion(id: 'E1Q2',
          textEn: 'Appropriate fire procedures in place?',
          textId: 'Apakah prosedur kebakaran yang sesuai sudah ada?'),
        GrmsQuestion(id: 'E1Q3',
          textEn: 'Are procedures in the event of fire appropriate and properly documented?',
          textId: 'Apakah prosedur saat kebakaran sesuai dan terdokumentasi dengan baik?'),
        GrmsQuestion(id: 'E1Q4',
          textEn: 'Are there suitable arrangements for summoning the fire and rescue service?',
          textId: 'Apakah ada pengaturan untuk memanggil layanan pemadam kebakaran?'),
        GrmsQuestion(id: 'E1Q5',
          textEn: 'Are there suitable arrangements to meet the fire service on arrival with relevant info?',
          textId: 'Apakah ada pengaturan untuk menyambut pemadam saat tiba dengan informasi relevan?'),
        GrmsQuestion(id: 'E1Q6',
          textEn: 'Are there suitable arrangements for ensuring the premises have been evacuated?',
          textId: 'Apakah ada pengaturan untuk memastikan gedung telah dievakuasi?'),
        GrmsQuestion(id: 'E1Q7',
          textEn: 'Is there a suitable fire assembly point?',
          textId: 'Apakah ada titik kumpul kebakaran yang sesuai?'),
        GrmsQuestion(id: 'E1Q8',
          textEn: 'Are there adequate procedures for evacuation of disabled people?',
          textId: 'Apakah ada prosedur evakuasi yang memadai untuk penyandang disabilitas?'),
        GrmsQuestion(id: 'E1Q9',
          textEn: 'Persons nominated and trained to use fire extinguishing appliances?',
          textId: 'Apakah ada personel yang ditunjuk dan dilatih untuk menggunakan alat pemadam?'),
        GrmsQuestion(id: 'E1Q10',
          textEn: 'Persons nominated and trained to assist with evacuation?',
          textId: 'Apakah ada personel yang ditunjuk dan dilatih untuk membantu evakuasi?'),
        GrmsQuestion(id: 'E1Q11',
          textEn: 'Appropriate liaison with fire and rescue service?',
          textId: 'Apakah ada hubungan kerja yang sesuai dengan dinas pemadam?'),
        GrmsQuestion(id: 'E1Q12',
          textEn: 'Routine in-house inspections of fire precautions?',
          textId: 'Apakah ada inspeksi internal rutin terhadap tindakan pencegahan kebakaran?'),
      ],
    ),
    GrmsSection(
      part: 'E',
      sectionNumber: '2',
      titleEn: 'Training and Drills',
      titleId: 'Pelatihan dan Latihan',
      questions: [
        GrmsQuestion(id: 'E2Q1',
          textEn: 'Are all staff given adequate fire safety instruction and training on induction?',
          textId: 'Apakah semua staf mendapat pengarahan keselamatan kebakaran saat orientasi?'),
        GrmsQuestion(id: 'E2Q2',
          textEn: 'Are all staff given adequate periodic refresher training?',
          textId: 'Apakah semua staf mendapat pelatihan penyegaran berkala?'),
        GrmsQuestion(id: 'E2Q3',
          textEn: 'Training covers: Fire risks in the premises?',
          textId: 'Pelatihan mencakup: Risiko kebakaran di gedung?'),
        GrmsQuestion(id: 'E2Q4',
          textEn: 'Training covers: Fire safety measures on the premises?',
          textId: 'Pelatihan mencakup: Tindakan keselamatan kebakaran?'),
        GrmsQuestion(id: 'E2Q5',
          textEn: 'Training covers: Action in the event of fire?',
          textId: 'Pelatihan mencakup: Tindakan saat terjadi kebakaran?'),
        GrmsQuestion(id: 'E2Q6',
          textEn: 'Training covers: Location and use of fire extinguishers?',
          textId: 'Pelatihan mencakup: Lokasi dan penggunaan APAR?'),
        GrmsQuestion(id: 'E2Q7',
          textEn: 'Are staff with special responsibilities (fire wardens) given additional training?',
          textId: 'Apakah staf dengan tanggung jawab khusus (fire warden) mendapat pelatihan tambahan?'),
        GrmsQuestion(id: 'E2Q8',
          textEn: 'Are fire drills carried out at appropriate intervals?',
          textId: 'Apakah latihan kebakaran dilakukan pada interval yang sesuai?'),
        GrmsQuestion(id: 'E2Q9',
          textEn: 'Are employees of another employer given appropriate fire safety information?',
          textId: 'Apakah karyawan pemberi kerja lain mendapat informasi keselamatan kebakaran yang sesuai?'),
      ],
    ),
    GrmsSection(
      part: 'E',
      sectionNumber: '3',
      titleEn: 'Testing and Maintenance',
      titleId: 'Pengujian dan Perawatan',
      questions: [
        GrmsQuestion(id: 'E3Q1',
          textEn: 'Adequate maintenance of premises?',
          textId: 'Apakah perawatan gedung memadai?'),
        GrmsQuestion(id: 'E3Q2',
          textEn: 'Weekly testing and periodic servicing of fire detection and alarm system?',
          textId: 'Apakah uji mingguan dan servis berkala sistem deteksi dan alarm kebakaran dilakukan?'),
        GrmsQuestion(id: 'E3Q3',
          textEn: 'Monthly and annual testing routines for emergency escape lighting?',
          textId: 'Apakah rutinitas pengujian bulanan dan tahunan untuk pencahayaan darurat dilakukan?'),
        GrmsQuestion(id: 'E3Q4',
          textEn: 'Annual maintenance of fire extinguishing appliances?',
          textId: 'Apakah perawatan tahunan alat pemadam dilakukan?'),
        GrmsQuestion(id: 'E3Q5',
          textEn: 'Periodic inspection of external escape staircases and gangways?',
          textId: 'Apakah tangga evakuasi eksternal diperiksa secara berkala?'),
        GrmsQuestion(id: 'E3Q6',
          textEn: 'Six-monthly inspection and annual testing of rising mains?',
          textId: 'Apakah inspeksi 6 bulanan dan uji tahunan untuk rising mains dilakukan?'),
        GrmsQuestion(id: 'E3Q7',
          textEn: 'Weekly testing and periodic inspection of sprinkler installations?',
          textId: 'Apakah uji mingguan dan inspeksi berkala instalasi sprinkler dilakukan?'),
        GrmsQuestion(id: 'E3Q8',
          textEn: 'Routine checks of final exit doors and/or security fastenings?',
          textId: 'Apakah pemeriksaan rutin pintu keluar akhir dan/atau pengaman dilakukan?'),
        GrmsQuestion(id: 'E3Q9',
          textEn: 'Annual inspection and test of lightning protection system?',
          textId: 'Apakah inspeksi dan uji tahunan sistem perlindungan petir dilakukan?'),
        GrmsQuestion(id: 'E3Q10',
          textEn: 'Suitable systems in place for reporting and restoring safety measures that have fallen below standard?',
          textId: 'Apakah ada sistem untuk melaporkan dan memulihkan tindakan keselamatan di bawah standar?'),
      ],
    ),
    GrmsSection(
      part: 'E',
      sectionNumber: '4',
      titleEn: 'Records',
      titleId: 'Catatan',
      questions: [
        GrmsQuestion(id: 'E4Q1',
          textEn: 'Appropriate records of fire drills maintained?',
          textId: 'Apakah catatan latihan kebakaran dijaga dengan baik?'),
        GrmsQuestion(id: 'E4Q2',
          textEn: 'Appropriate records of fire training maintained?',
          textId: 'Apakah catatan pelatihan kebakaran dijaga?'),
        GrmsQuestion(id: 'E4Q3',
          textEn: 'Appropriate records of fire alarm tests maintained?',
          textId: 'Apakah catatan uji alarm kebakaran dijaga?'),
        GrmsQuestion(id: 'E4Q4',
          textEn: 'Appropriate records of emergency escape lighting tests maintained?',
          textId: 'Apakah catatan uji pencahayaan darurat dijaga?'),
        GrmsQuestion(id: 'E4Q5',
          textEn: 'Appropriate records of maintenance and testing of other fire protection systems?',
          textId: 'Apakah catatan perawatan dan uji sistem proteksi kebakaran lainnya dijaga?'),
      ],
    ),
  ];

  static int getTotalQuestions() =>
      getAllSections().fold(0, (s, sec) => s + sec.questions.length);
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class GrmsSection {
  final String part;
  final String sectionNumber;
  final String titleEn;
  final String titleId;
  final List<GrmsQuestion> questions;

  const GrmsSection({
    required this.part,
    required this.sectionNumber,
    required this.titleEn,
    required this.titleId,
    required this.questions,
  });

  String get id => '$part$sectionNumber';
  String title(String lang) => lang == 'id' ? titleId : titleEn;
}

class GrmsQuestion {
  final String id;
  final String textEn;
  final String textId;
  final bool hasCommentField;

  const GrmsQuestion({
    required this.id,
    required this.textEn,
    required this.textId,
    this.hasCommentField = false,
  });

  String text(String lang) => lang == 'id' ? textId : textEn;
}

/// TriState answer: null = unanswered, 0 = N/A, 1 = Yes, 2 = No
class GrmsAnswer {
  final String questionId;
  final int? value; // 0=N/A, 1=Yes, 2=No
  final String? comment;

  const GrmsAnswer({
    required this.questionId,
    this.value,
    this.comment,
  });

  bool get isAnswered => value != null;

  /// Score: Yes=1.0, N/A=0.5, No=0.0, unanswered=0.0
  double get score {
    switch (value) {
      case 1: return 1.0;  // Yes
      case 0: return 0.5;  // N/A (neutral)
      case 2: return 0.0;  // No
      default: return 0.0;
    }
  }

  String get label {
    switch (value) {
      case 0: return 'N/A';
      case 1: return 'Yes';
      case 2: return 'No';
      default: return '—';
    }
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'value': value,
    'comment': comment,
  };

  factory GrmsAnswer.fromJson(Map<String, dynamic> json) => GrmsAnswer(
    questionId: json['questionId'],
    value: json['value'],
    comment: json['comment'],
  );
}

/// Full GRMS Assessment result
class GrmsAssessment {
  final String id;
  final FactoryInfo factoryInfo;
  final Map<String, GrmsAnswer> answers;
  final Map<String, String> partAData;
  final Map<String, String> partBData;
  final String hazardLikelihood;   // 'low' | 'medium' | 'high'
  final String consequenceSeverity; // 'slight' | 'moderate' | 'extreme'
  final String riskLevel;          // trivial|tolerable|moderate|substantial|intolerable
  final DateTime createdAt;
  final bool isCompleted;

  GrmsAssessment({
    required this.id,
    required this.factoryInfo,
    required this.answers,
    required this.partAData,
    required this.partBData,
    this.hazardLikelihood = 'medium',
    this.consequenceSeverity = 'moderate',
    this.riskLevel = 'moderate',
    DateTime? createdAt,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  double get complianceScore {
    final all = GrmsAssessmentData.getAllSections()
        .expand((s) => s.questions)
        .toList();
    if (all.isEmpty) return 0;
    final total = all.fold<double>(0, (s, q) {
      final a = answers[q.id];
      return s + (a?.score ?? 0);
    });
    return (total / all.length) * 100;
  }

  static String computeRiskLevel(String likelihood, String consequence) {
    const matrix = {
      'low_slight': 'trivial',
      'low_moderate': 'tolerable',
      'low_extreme': 'moderate',
      'medium_slight': 'tolerable',
      'medium_moderate': 'moderate',
      'medium_extreme': 'substantial',
      'high_slight': 'moderate',
      'high_moderate': 'substantial',
      'high_extreme': 'intolerable',
    };
    return matrix['${likelihood}_$consequence'] ?? 'moderate';
  }
}
