import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/grms_assessment_data.dart';
import '../services/language_service.dart';
import 'grms_result_screen.dart';

class GrmsAssessmentScreen extends StatefulWidget {
  final FactoryInfo factoryInfo;
  const GrmsAssessmentScreen({super.key, required this.factoryInfo});

  @override
  State<GrmsAssessmentScreen> createState() => _GrmsAssessmentScreenState();
}

class _GrmsAssessmentScreenState extends State<GrmsAssessmentScreen>
    with TickerProviderStateMixin {

  // Data
  final Map<String, GrmsAnswer> _answers = {};
  final Map<String, String> _partAData = {};
  final Map<String, String> _partBData = {};

  final List<GrmsSection> _sections = GrmsAssessmentData.getAllSections();

  // Navigation: 0 = Part A form, 1 = Part B form, 2+ = sections
  int _step = 0;
  // total steps = 2 (A+B forms) + sections + Part F
  int get _totalSteps => 2 + _sections.length + 1;

  // Part F risk matrix
  String _hazardLikelihood = 'medium';
  String _consequenceSeverity = 'moderate';

  late AnimationController _pageAnim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _pageAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fade = CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _pageAnim, curve: Curves.easeOutCubic));
    _pageAnim.forward();
  }

  @override
  void dispose() {
    _pageAnim.dispose();
    super.dispose();
  }

  String get _l => lang.lang;

  double get _progress => (_step + 1) / _totalSteps;

  void _goNext() {
    if (_step < _totalSteps - 1) {
      _pageAnim.forward(from: 0);
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _goPrev() {
    if (_step > 0) {
      _pageAnim.forward(from: 0);
      setState(() => _step--);
    }
  }

  void _setAnswer(String qId, int? value) {
    setState(() {
      _answers[qId] = GrmsAnswer(questionId: qId, value: value);
    });
  }

  void _submit() {
    final riskLevel = GrmsAssessment.computeRiskLevel(
        _hazardLikelihood, _consequenceSeverity);
    final assessment = GrmsAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      factoryInfo: widget.factoryInfo,
      answers: _answers,
      partAData: _partAData,
      partBData: _partBData,
      hazardLikelihood: _hazardLikelihood,
      consequenceSeverity: _consequenceSeverity,
      riskLevel: riskLevel,
      isCompleted: true,
    );
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GrmsResultScreen(assessment: assessment),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lang,
      builder: (_, __) => Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GRMS 2167.01a',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_stepTitle(),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          actions: [
            _LangToggle(),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.goldPrimary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Step ${_step + 1} / $_totalSteps',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                      Text('${(_progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: AppTheme.goldPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: _buildStepContent(),
                ),
              ),
            ),

            // Nav
            _NavBar(
              onPrev: _step > 0 ? _goPrev : null,
              onNext: _goNext,
              isLast: _step == _totalSteps - 1,
              lang: _l,
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle() {
    if (_step == 0) return _l == 'id' ? 'Bagian A: Detail Asesmen' : 'Part A: Assessment Details';
    if (_step == 1) return _l == 'id' ? 'Bagian B: Informasi Umum' : 'Part B: General Information';
    if (_step == _totalSteps - 1) return _l == 'id' ? 'Bagian F: Penilaian Risiko' : 'Part F: Risk Assessment';
    final sec = _sections[_step - 2];
    return 'Part ${sec.part} §${sec.sectionNumber}: ${sec.title(_l)}';
  }

  Widget _buildStepContent() {
    if (_step == 0) return _buildPartAForm();
    if (_step == 1) return _buildPartBForm();
    if (_step == _totalSteps - 1) return _buildPartFRiskMatrix();
    return _buildSectionQuestions(_sections[_step - 2]);
  }

  // ── Part A Form ─────────────────────────────────────────────────────────
  Widget _buildPartAForm() {
    final fields = _l == 'id'
        ? GrmsAssessmentData.partAFieldsId
        : GrmsAssessmentData.partAFields;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PartHeader(
          part: 'A',
          title: lang.t('grms_part_a'),
          color: const Color(0xFF1A4080),
        ),
        const SizedBox(height: 12),
        ...fields.asMap().entries.map((e) {
          final key = 'A_${e.key}';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              initialValue: _partAData[key] ?? '',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: e.value,
                labelStyle: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppTheme.goldPrimary, width: 1.5),
                ),
              ),
              onChanged: (v) => _partAData[key] = v,
            ),
          );
        }),
      ],
    );
  }

  // ── Part B Form ─────────────────────────────────────────────────────────
  Widget _buildPartBForm() {
    final sec1 = GrmsAssessmentData.partBSection1Fields;
    final sec2 = GrmsAssessmentData.partBSection2Fields;
    final sec3 = GrmsAssessmentData.partBSection3Fields;

    Widget fieldsBlock(String sectionTitle, List<String> fields, String prefix) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(sectionTitle,
                style: const TextStyle(
                    color: AppTheme.goldLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          ...fields.asMap().entries.map((e) {
            final key = '${prefix}_${e.key}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                initialValue: _partBData[key] ?? '',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                maxLines: e.value.contains('construction') || e.value.contains('konstruksi') ? 3 : 1,
                decoration: InputDecoration(
                  labelText: e.value,
                  labelStyle: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppTheme.goldPrimary, width: 1.5),
                  ),
                ),
                onChanged: (v) => _partBData[key] = v,
              ),
            );
          }),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PartHeader(
          part: 'B',
          title: lang.t('grms_part_b'),
          color: const Color(0xFF204020),
        ),
        const SizedBox(height: 8),
        fieldsBlock(
          _l == 'id' ? 'Seksi 1: Gedung' : 'Section 1: The Premises',
          sec1, 'B1',
        ),
        fieldsBlock(
          _l == 'id' ? 'Seksi 2: Penghuni' : 'Section 2: The Occupants',
          sec2, 'B2',
        ),
        fieldsBlock(
          _l == 'id' ? 'Seksi 3: Kelompok Berisiko' : 'Section 3: At-Risk Occupants',
          sec3, 'B3',
        ),
      ],
    );
  }

  // ── Section Questions (Parts C, D, E) ───────────────────────────────────
  Widget _buildSectionQuestions(GrmsSection section) {
    final partColors = {
      'C': const Color(0xFF6B1A00),
      'D': const Color(0xFF004070),
      'E': const Color(0xFF204062),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PartHeader(
          part: section.part,
          title: '${_partLabel(section.part, _l)} §${section.sectionNumber}: ${section.title(_l)}',
          color: partColors[section.part] ?? AppTheme.surfaceDark,
        ),
        const SizedBox(height: 12),
        ...section.questions.asMap().entries.map((e) {
          final q = e.value;
          final answer = _answers[q.id];
          return _GrmsQuestionCard(
            key: ValueKey(q.id),
            question: q,
            answer: answer,
            index: e.key,
            langCode: _l,
            onAnswer: (val) => _setAnswer(q.id, val),
          );
        }),
        const SizedBox(height: 8),
        // Comments field
        TextFormField(
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: lang.t('grms_comments'),
            hintStyle: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
            filled: true,
            fillColor: AppTheme.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppTheme.goldPrimary, width: 1),
            ),
            prefixIcon: const Icon(Icons.notes_rounded,
                color: AppTheme.textSecondary, size: 18),
          ),
          onChanged: (v) {
            _answers['${section.id}_comments'] =
                GrmsAnswer(questionId: '${section.id}_comments', comment: v);
          },
        ),
      ],
    );
  }

  // ── Part F: Risk Matrix ──────────────────────────────────────────────────
  Widget _buildPartFRiskMatrix() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PartHeader(
          part: 'F',
          title: lang.t('grms_part_f'),
          color: const Color(0xFF3A1A00),
        ),
        const SizedBox(height: 16),

        // ------- RISK MATRIX TABLE -------
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceLight),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A2340),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.grid_view_rounded,
                        color: AppTheme.goldPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _l == 'id'
                          ? 'Matriks Estimasi Level Risiko Kebakaran'
                          : 'Fire Risk Level Estimator Matrix',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              _buildRiskMatrixTable(),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ---- Hazard Likelihood ----
        _RiskSelector(
          title: _l == 'id'
              ? 'Seksi 1: Kemungkinan Bahaya Kebakaran'
              : 'Section 1: Hazard from Fire (Likelihood)',
          subtitle: _l == 'id'
              ? 'Dengan mempertimbangkan tindakan pencegahan yang diamati:'
              : 'Taking into account fire prevention measures observed:',
          selected: _hazardLikelihood,
          options: const ['low', 'medium', 'high'],
          labels: _l == 'id'
              ? const ['Rendah', 'Sedang', 'Tinggi']
              : const ['Low', 'Medium', 'High'],
          descriptions: _l == 'id'
              ? const [
                  'Kemungkinan kebakaran sangat rendah akibat sumber penyalaan yang dapat diabaikan.',
                  'Bahaya normal untuk tipe hunian ini, dengan kontrol yang umumnya memadai.',
                  'Kurangnya kontrol pada satu atau lebih bahaya signifikan, meningkatkan risiko kebakaran.',
                ]
              : const [
                  'Unusually low likelihood of fire as a result of negligible potential sources of ignition.',
                  'Normal fire hazards for this type of occupancy, with hazards generally subject to appropriate controls.',
                  'Lack of adequate controls applied to one or more significant fire hazards, resulting in increased likelihood.',
                ],
          colors: const [AppTheme.riskLow, AppTheme.riskMedium, AppTheme.riskHigh],
          onChanged: (v) => setState(() => _hazardLikelihood = v),
        ),
        const SizedBox(height: 16),

        // ---- Consequence Severity ----
        _RiskSelector(
          title: _l == 'id'
              ? 'Seksi 2: Konsekuensi bagi Keselamatan Jiwa'
              : 'Section 2: Consequences for Life Safety',
          subtitle: _l == 'id'
              ? 'Dengan mempertimbangkan sifat gedung dan penghuninya:'
              : 'Taking into account the nature of the premises and occupants:',
          selected: _consequenceSeverity,
          options: const ['slight', 'moderate', 'extreme'],
          labels: _l == 'id'
              ? const ['Ringan', 'Sedang', 'Ekstrem']
              : const ['Slight Harm', 'Moderate Harm', 'Extreme Harm'],
          descriptions: _l == 'id'
              ? const [
                  'Kebakaran kemungkinan kecil menyebabkan cedera serius atau kematian.',
                  'Kebakaran dapat menyebabkan cedera satu atau lebih penghuni, kecil kemungkinan banyak korban jiwa.',
                  'Potensi signifikan cedera serius atau kematian satu atau lebih penghuni.',
                ]
              : const [
                  'Outbreak unlikely to result in serious injury or death of any occupant.',
                  'Outbreak could foreseeably result in injury of one or more occupants, unlikely to involve multiple fatalities.',
                  'Significant potential for serious injury or death of one or more occupants.',
                ],
          colors: const [AppTheme.riskLow, AppTheme.riskMedium, AppTheme.riskHigh],
          onChanged: (v) => setState(() => _consequenceSeverity = v),
        ),
        const SizedBox(height: 20),

        // ---- Resulting Risk Level ----
        Builder(builder: (context) {
          final level = GrmsAssessment.computeRiskLevel(
              _hazardLikelihood, _consequenceSeverity);
          final color = _riskColor(level);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text(
                  _l == 'id'
                      ? 'Seksi 3: Level Risiko Kebakaran'
                      : 'Section 3: Risk to Life from Fire',
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  _riskLevelLabel(level),
                  style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  _riskActionText(level, _l),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRiskMatrixTable() {
    const levels = ['slight', 'moderate', 'extreme'];
    const likelihoods = ['low', 'medium', 'high'];
    final colLabels = _l == 'id'
        ? ['↕ Kemungkinan', 'Ringan', 'Sedang', 'Ekstrem']
        : ['↕ Likelihood', 'Slight', 'Moderate', 'Extreme'];
    final rowLabels = _l == 'id'
        ? ['Rendah', 'Sedang', 'Tinggi']
        : ['Low', 'Medium', 'High'];

    return Table(
      border: TableBorder.all(color: AppTheme.surfaceLight),
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF222840)),
          children: colLabels
              .map((h) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(h,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppTheme.goldPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                  ))
              .toList(),
        ),
        // Data rows
        ...likelihoods.asMap().entries.map((lr) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(rowLabels[lr.key],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10)),
              ),
              ...levels.map((c) {
                final rl = GrmsAssessment.computeRiskLevel(lr.value, c);
                final color = _riskColor(rl);
                final isSelected = _hazardLikelihood == lr.value &&
                    _consequenceSeverity == c;
                return Container(
                  color: isSelected
                      ? color.withValues(alpha: 0.4)
                      : color.withValues(alpha: 0.12),
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    _riskLevelLabel(rl),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isSelected ? color : color.withValues(alpha: 0.7),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 9),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  String _partLabel(String part, String l) {
    if (l == 'id') {
      const m = {'C': 'BAGIAN C', 'D': 'BAGIAN D', 'E': 'BAGIAN E'};
      return m[part] ?? part;
    }
    return 'PART $part';
  }

  Color _riskColor(String level) {
    switch (level) {
      case 'trivial': return const Color(0xFF00AA60);
      case 'tolerable': return const Color(0xFF80CC30);
      case 'moderate': return AppTheme.riskMedium;
      case 'substantial': return AppTheme.riskHigh;
      case 'intolerable': return const Color(0xFFAA0030);
      default: return AppTheme.textSecondary;
    }
  }

  String _riskLevelLabel(String level) {
    final map = _l == 'id'
        ? {
            'trivial': 'SEPELE',
            'tolerable': 'DAPAT DITOLERANSI',
            'moderate': 'SEDANG',
            'substantial': 'SUBSTANSIAL',
            'intolerable': 'TIDAK DAPAT DITOLERANSI',
          }
        : {
            'trivial': 'TRIVIAL',
            'tolerable': 'TOLERABLE',
            'moderate': 'MODERATE',
            'substantial': 'SUBSTANTIAL',
            'intolerable': 'INTOLERABLE',
          };
    return map[level] ?? level.toUpperCase();
  }

  String _riskActionText(String level, String l) {
    final en = {
      'trivial': 'No action required. No detailed records need be kept.',
      'tolerable':
          'No major additional fire precautions required. Minor improvements may be needed.',
      'moderate':
          'Efforts must be made to reduce the risk within a defined time period.',
      'substantial':
          'Considerable resources must be allocated. If occupied, urgent action should be taken.',
      'intolerable':
          'Premises should not be occupied until risk is reduced.',
    };
    final id = {
      'trivial': 'Tidak perlu tindakan. Tidak perlu catatan rinci.',
      'tolerable':
          'Tidak diperlukan tindakan pencegahan besar tambahan. Perbaikan kecil mungkin diperlukan.',
      'moderate':
          'Harus dilakukan upaya pengurangan risiko dalam periode waktu tertentu.',
      'substantial':
          'Sumber daya besar harus dialokasikan. Jika gedung berpenghuni, tindakan segera diperlukan.',
      'intolerable':
          'Gedung tidak boleh berpenghuni sampai risiko dikurangi.',
    };
    return (l == 'id' ? id : en)[level] ?? '';
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _PartHeader extends StatelessWidget {
  final String part;
  final String title;
  final Color color;
  const _PartHeader({required this.part, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(part,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _GrmsQuestionCard extends StatefulWidget {
  final GrmsQuestion question;
  final GrmsAnswer? answer;
  final int index;
  final String langCode;
  final Function(int?) onAnswer;

  const _GrmsQuestionCard({
    super.key,
    required this.question,
    this.answer,
    required this.index,
    required this.langCode,
    required this.onAnswer,
  });

  @override
  State<_GrmsQuestionCard> createState() => _GrmsQuestionCardState();
}

class _GrmsQuestionCardState extends State<_GrmsQuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 55),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final val = widget.answer?.value;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: val == 1
                  ? AppTheme.riskLow.withValues(alpha: 0.5)
                  : val == 2
                      ? AppTheme.riskHigh.withValues(alpha: 0.5)
                      : AppTheme.surfaceLight.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.question.text(widget.langCode),
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13, height: 1.5)),
              const SizedBox(height: 12),
              // N/A | Yes | No buttons
              Row(
                children: [
                  _TriBtn(
                    label: widget.langCode == 'id' ? 'T/B' : 'N/A',
                    value: 0,
                    selected: val,
                    color: AppTheme.textSecondary,
                    onTap: () => widget.onAnswer(val == 0 ? null : 0),
                  ),
                  const SizedBox(width: 8),
                  _TriBtn(
                    label: widget.langCode == 'id' ? 'Ya' : 'Yes',
                    value: 1,
                    selected: val,
                    color: AppTheme.riskLow,
                    onTap: () => widget.onAnswer(val == 1 ? null : 1),
                  ),
                  const SizedBox(width: 8),
                  _TriBtn(
                    label: widget.langCode == 'id' ? 'Tidak' : 'No',
                    value: 2,
                    selected: val,
                    color: AppTheme.riskHigh,
                    onTap: () => widget.onAnswer(val == 2 ? null : 2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriBtn extends StatelessWidget {
  final String label;
  final int value;
  final int? selected;
  final Color color;
  final VoidCallback onTap;
  const _TriBtn({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppTheme.surfaceLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppTheme.surfaceLight,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? color : AppTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13)),
          ),
        ),
      ),
    );
  }
}

class _RiskSelector extends StatelessWidget {
  final String title;
  final String subtitle;
  final String selected;
  final List<String> options;
  final List<String> labels;
  final List<String> descriptions;
  final List<Color> colors;
  final Function(String) onChanged;

  const _RiskSelector({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.options,
    required this.labels,
    required this.descriptions,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppTheme.goldLight,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 10),
        ...options.asMap().entries.map((e) {
          final isSelected = selected == e.value;
          final color = colors[e.key];
          return GestureDetector(
            onTap: () => onChanged(e.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppTheme.surfaceLight,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected ? color : AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labels[e.key],
                            style: TextStyle(
                                color: isSelected
                                    ? color
                                    : AppTheme.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13)),
                        Text(descriptions[e.key],
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _NavBar extends StatelessWidget {
  final VoidCallback? onPrev;
  final VoidCallback onNext;
  final bool isLast;
  final String lang;

  const _NavBar({
    this.onPrev,
    required this.onNext,
    required this.isLast,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
            top: BorderSide(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (onPrev != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(lang == 'id' ? 'Sebelumnya' : 'Previous'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLast
                          ? [const Color(0xFF009970), const Color(0xFF00C897)]
                          : [AppTheme.goldDark, AppTheme.goldPrimary],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLast
                            ? Icons.check_circle_rounded
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isLast
                            ? (lang == 'id' ? 'Selesaikan Asesmen' : 'Complete Assessment')
                            : (lang == 'id' ? 'Berikutnya' : 'Next'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lang,
      builder: (_, __) => GestureDetector(
        onTap: lang.toggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withValues(alpha: 0.15),
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
                lang.isEn ? 'ID' : 'EN',
                style: const TextStyle(
                    color: AppTheme.goldPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
