import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../services/language_service.dart';
import 'assessment_screen.dart';

class FactoryInfoScreen extends StatefulWidget {
  const FactoryInfoScreen({super.key});

  @override
  State<FactoryInfoScreen> createState() => _FactoryInfoScreenState();
}

class _FactoryInfoScreenState extends State<FactoryInfoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _factoryNameController = TextEditingController();
  final _factoryTypeController = TextEditingController();
  final _assessorController = TextEditingController();
  final _gmDirectorController = TextEditingController();

  String _workerCount = '< 100 workers';
  IndustryType _industryType = IndustryType.manufacturing;

  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _workerCountOptions = [
    '< 100 workers',
    '100–500 workers',
    '500–2000 workers',
    '> 2000 workers',
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _factoryNameController.dispose();
    _factoryTypeController.dispose();
    _assessorController.dispose();
    _gmDirectorController.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _startAssessment() {
    if (_formKey.currentState!.validate()) {
      final factoryInfo = FactoryInfo(
        factoryName: _factoryNameController.text,
        factoryType: _factoryTypeController.text,
        industryType: _industryType,
        workerCount: _workerCount,
        assessorName: _assessorController.text,
        gmDirector: _gmDirectorController.text,
      );
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              AssessmentScreen(factoryInfo: factoryInfo),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      );
    }
  }

  IconData _industryIcon(IndustryType type) {
    switch (type) {
      case IndustryType.manufacturing:
        return Icons.precision_manufacturing_rounded;
      case IndustryType.residential:
        return Icons.home_rounded;
      case IndustryType.commercial:
        return Icons.store_rounded;
      case IndustryType.mixed:
        return Icons.apartment_rounded;
    }
  }

  String _industryTypeHint(IndustryType type) {
    switch (type) {
      case IndustryType.manufacturing:
        return 'e.g., Farmasi, Kimia, Tekstil, Elektronik';
      case IndustryType.residential:
        return 'e.g., Apartemen, Perumahan, Kost';
      case IndustryType.commercial:
        return 'e.g., Perkantoran, Mall, Hotel';
      case IndustryType.mixed:
        return 'e.g., Ruko, Mixed-use Building';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(lang.t('facility_info')),
        actions: [
          GestureDetector(
            onTap: lang.toggle,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, color: AppTheme.goldPrimary, size: 14),
                  const SizedBox(width: 4),
                  Text(lang.isEn ? '🇮🇩 ID' : '🇬🇧 EN',
                      style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  GlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2A1500), Color(0xFF150A00)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.factory_rounded,
                              color: AppTheme.goldPrimary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data Fasilitas',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary)),
                              SizedBox(height: 4),
                              Text(
                                'Jenis industri menentukan set pertanyaan yang relevan',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Industry Type Card Selector ────────────────────────────
                  const Text('Jenis Industri / Fasilitas *',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ...IndustryType.values.map((type) {
                    final isSelected = _industryType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _industryType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(colors: [
                                  AppTheme.goldPrimary.withValues(alpha: 0.2),
                                  AppTheme.goldPrimary.withValues(alpha: 0.05),
                                ])
                              : null,
                          color: isSelected ? null : AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.goldPrimary
                                : AppTheme.surfaceLight,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(_industryIcon(type),
                                color: isSelected
                                    ? AppTheme.goldPrimary
                                    : AppTheme.textSecondary,
                                size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(type.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      )),
                                  const SizedBox(height: 2),
                                  Text(type.description,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.goldPrimary, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),

                  // ── Chemical indicator banner ──────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _industryType == IndustryType.manufacturing
                          ? AppTheme.riskHigh.withValues(alpha: 0.1)
                          : AppTheme.riskLow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _industryType == IndustryType.manufacturing
                            ? AppTheme.riskHigh.withValues(alpha: 0.3)
                            : AppTheme.riskLow.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _industryType == IndustryType.manufacturing
                              ? Icons.science_rounded
                              : Icons.home_rounded,
                          color: _industryType == IndustryType.manufacturing
                              ? AppTheme.riskHigh
                              : AppTheme.riskLow,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _industryType == IndustryType.manufacturing
                                ? 'Pertanyaan kimia B3/industri akan menggunakan skala Likert & pilihan ganda'
                                : 'Pertanyaan kimia berupa keamanan bahan rumah tangga (format Ya/Tidak)',
                            style: TextStyle(
                              fontSize: 11,
                              color: _industryType == IndustryType.manufacturing
                                  ? AppTheme.riskHigh
                                  : AppTheme.riskLow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Form fields ───────────────────────────────────────────
                  const Text('Nama Fasilitas *',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _factoryNameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'e.g., PT. Maju Bersama',
                      prefixIcon: Icon(Icons.business_rounded,
                          color: AppTheme.goldPrimary),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Nama fasilitas wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  Text('Sub-tipe ${_industryTypeHint(_industryType).split(",").first.split(".").last}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _factoryTypeController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: _industryTypeHint(_industryType),
                      prefixIcon: const Icon(Icons.category_rounded,
                          color: AppTheme.goldPrimary),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Sub-tipe wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text('Jumlah Pekerja *',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _workerCount,
                    dropdownColor: AppTheme.surfaceDark,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.people_rounded, color: AppTheme.goldPrimary),
                    ),
                    items: _workerCountOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _workerCount = v!),
                  ),
                  const SizedBox(height: 16),

                  const Text('Nama Assessor *',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _assessorController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.person_rounded, color: AppTheme.goldPrimary),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Nama assessor wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text('Nama GM/Direktur *',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _gmDirectorController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.admin_panel_settings_rounded,
                          color: AppTheme.goldPrimary),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Nama GM/Direktur wajib diisi' : null,
                  ),
                  const SizedBox(height: 32),

                  // ── Start Button ──────────────────────────────────────────
                  GestureDetector(
                    onTap: _startAssessment,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3B5C), Color(0xFFFF6B35)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldPrimary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_rounded,
                              color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text('MULAI ASESSMEN',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
