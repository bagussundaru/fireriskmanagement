import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_widgets.dart';
import '../services/language_service.dart';
import '../models/models.dart';
import 'factory_info_screen.dart';
import 'grms_assessment_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _pulseAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _startStandardAssessment() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const FactoryInfoScreen(),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  void _startGrmsAssessment() {
    // Show a quick factory info bottom sheet before GRMS
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _GrmsQuickInfoSheet(
        onStart: (info) {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  GrmsAssessmentScreen(factoryInfo: info),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lang,
      builder: (_, __) => Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Stack(
          children: [
            ..._buildBackgroundOrbs(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Top Bar (language toggle) ──────────────────────
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 40),
                              Text(
                                lang.isEn ? 'FIRE RISK AI' : 'AI K3 KEBAKARAN',
                                style: const TextStyle(
                                    color: AppTheme.goldPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 2),
                              ),
                              // Language toggle
                              GestureDetector(
                                onTap: lang.toggle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldPrimary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppTheme.goldPrimary.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.language_rounded,
                                          color: AppTheme.goldPrimary, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        lang.isEn ? '🇮🇩 ID' : '🇬🇧 EN',
                                        style: const TextStyle(
                                            color: AppTheme.goldPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── AI Brain Visualization ─────────────────────────
                        Center(
                          child: AnimatedBuilder(
                            animation: _floatAnim,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(0, _floatAnim.value * 0.5),
                              child: child,
                            ),
                            child: const AIBrainWidget(size: 200),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Title ──────────────────────────────────────────
                        Text(
                          lang.isEn ? 'FIRE RISK' : 'RISIKO KEBAKARAN',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.fireGradient.createShader(bounds),
                          child: Text(
                            lang.isEn ? 'ASSESSMENT' : 'ASESMEN AI',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lang.isEn
                              ? 'Hybrid AHP-Fuzzy Logic Engine'
                              : 'Mesin Hybrid AHP-Fuzzy Logic',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1),
                        ),
                        const SizedBox(height: 24),

                        // ── Assessment Type Cards ──────────────────────────
                        Text(
                          lang.t('choose_assessment'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),

                        // Standard AHP-Fuzzy
                        _AssessmentTypeCard(
                          icon: Icons.psychology_rounded,
                          badge: 'AHP-FUZZY',
                          title: lang.t('assessment_standard'),
                          description: lang.t('assessment_standard_desc'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF3B5C), Color(0xFFFF6B35)],
                          ),
                          onTap: _startStandardAssessment,
                        ),
                        const SizedBox(height: 10),

                        // GRMS 2167.01a
                        _AssessmentTypeCard(
                          icon: Icons.assignment_rounded,
                          badge: 'GRMS 2167.01a',
                          title: lang.t('assessment_grms'),
                          description: lang.t('assessment_grms_desc'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A4080), Color(0xFF2A6BB0)],
                          ),
                          onTap: _startGrmsAssessment,
                        ),
                        const Spacer(),

                        // ── Footer ─────────────────────────────────────────
                        Text(
                          lang.isEn
                              ? 'v2.0 • GRMS 2167.01a • Hybrid AHP-Fuzzy'
                              : 'v2.0 • GRMS 2167.01a • Hybrid AHP-Fuzzy',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundOrbs() {
    return [
      Positioned(
        top: -60,
        right: -60,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Opacity(
            opacity: 0.07 + (_pulseController.value * 0.04),
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldPrimary,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 100,
        left: -80,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.riskHigh.withValues(alpha: 0.05),
          ),
        ),
      ),
    ];
  }
}

// ── Assessment Type Card ─────────────────────────────────────────────────────
class _AssessmentTypeCard extends StatefulWidget {
  final IconData icon;
  final String badge;
  final String title;
  final String description;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _AssessmentTypeCard({
    required this.icon,
    required this.badge,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_AssessmentTypeCard> createState() => _AssessmentTypeCardState();
}

class _AssessmentTypeCardState extends State<_AssessmentTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient.colors
                  .map((c) => c.withValues(alpha: 0.15))
                  .toList(),
              begin: widget.gradient.begin,
              end: widget.gradient.end,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: (widget.gradient.colors.first).withValues(alpha: 0.4),
                width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: widget.gradient.colors.first.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: widget.gradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(widget.badge,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(widget.title,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.description,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textSecondary, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Factory Info Sheet for GRMS ────────────────────────────────────────
class _GrmsQuickInfoSheet extends StatefulWidget {
  final Function(FactoryInfo) onStart;
  const _GrmsQuickInfoSheet({required this.onStart});

  @override
  State<_GrmsQuickInfoSheet> createState() => _GrmsQuickInfoSheetState();
}

class _GrmsQuickInfoSheetState extends State<_GrmsQuickInfoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _assessorCtrl = TextEditingController();
  final _gmCtrl = TextEditingController();
  IndustryType _industry = IndustryType.commercial;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _assessorCtrl.dispose();
    _gmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lang,
      builder: (_, __) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang.isEn
                    ? 'GRMS 2167.01a — Facility Details'
                    : 'GRMS 2167.01a — Data Fasilitas',
                style: const TextStyle(
                    color: AppTheme.goldPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                lang.isEn
                    ? 'Basic information for the assessment report header'
                    : 'Informasi dasar untuk header laporan asesmen',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 16),
              _field(_nameCtrl,
                  label: lang.isEn ? 'Premises / Facility Name *' : 'Nama Gedung / Fasilitas *',
                  icon: Icons.business_rounded),
              _field(_typeCtrl,
                  label: lang.isEn ? 'Use of Premises *' : 'Penggunaan Gedung *',
                  icon: Icons.category_rounded),
              _field(_assessorCtrl,
                  label: lang.isEn ? 'Assessor Name *' : 'Nama Assessor *',
                  icon: Icons.person_rounded),
              _field(_gmCtrl,
                  label: lang.isEn ? 'Employer / Person in Control' : 'Pemberi Kerja / Penanggung Jawab',
                  icon: Icons.admin_panel_settings_rounded,
                  required: false),
              // Industry type quick selector
              DropdownButtonFormField<IndustryType>(
                value: _industry,
                dropdownColor: AppTheme.surfaceDark,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  labelText: lang.isEn ? 'Occupancy Type' : 'Tipe Hunian',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  prefixIcon: const Icon(Icons.apartment_rounded, color: AppTheme.goldPrimary),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: IndustryType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _industry = v ?? _industry),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onStart(FactoryInfo(
                      factoryName: _nameCtrl.text,
                      factoryType: _typeCtrl.text,
                      industryType: _industry,
                      workerCount: '100-500 workers',
                      assessorName: _assessorCtrl.text,
                      gmDirector: _gmCtrl.text.isEmpty ? '—' : _gmCtrl.text,
                    ));
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1A4080), Color(0xFF2A6BB0)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        lang.isEn ? 'Start GRMS Assessment' : 'Mulai Asesmen GRMS',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl,
      {required String label,
      required IconData icon,
      bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          prefixIcon: Icon(icon, color: AppTheme.goldPrimary),
          filled: true,
          fillColor: AppTheme.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppTheme.goldPrimary, width: 1.5),
          ),
        ),
        validator: required
            ? (v) => (v == null || v.isEmpty)
                ? (lang.isEn ? 'Required' : 'Wajib diisi')
                : null
            : null,
      ),
    );
  }
}
