import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/grms_assessment_data.dart';
import '../services/language_service.dart';
import 'factory_info_screen.dart';

class GrmsResultScreen extends StatefulWidget {
  final GrmsAssessment assessment;
  const GrmsResultScreen({super.key, required this.assessment});

  @override
  State<GrmsResultScreen> createState() => _GrmsResultScreenState();
}

class _GrmsResultScreenState extends State<GrmsResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  String get _l => lang.lang;

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

  String _riskLabel(String level) {
    final en = {
      'trivial': 'TRIVIAL',
      'tolerable': 'TOLERABLE',
      'moderate': 'MODERATE',
      'substantial': 'SUBSTANTIAL',
      'intolerable': 'INTOLERABLE',
    };
    final id = {
      'trivial': 'SEPELE',
      'tolerable': 'DAPAT DITOLERANSI',
      'moderate': 'SEDANG',
      'substantial': 'SUBSTANSIAL',
      'intolerable': 'TIDAK DAPAT DITOLERANSI',
    };
    return (_l == 'id' ? id : en)[level] ?? level.toUpperCase();
  }

  String _likelihoodLabel(String v) {
    const en = {'low': 'Low', 'medium': 'Medium', 'high': 'High'};
    const id = {'low': 'Rendah', 'medium': 'Sedang', 'high': 'Tinggi'};
    return (_l == 'id' ? id : en)[v] ?? v;
  }

  String _consequenceLabel(String v) {
    const en = {'slight': 'Slight Harm', 'moderate': 'Moderate Harm', 'extreme': 'Extreme Harm'};
    const id = {'slight': 'Ringan', 'moderate': 'Sedang', 'extreme': 'Ekstrem'};
    return (_l == 'id' ? id : en)[v] ?? v;
  }

  Map<String, _PartSummary> _buildPartSummaries() {
    final sections = GrmsAssessmentData.getAllSections();
    final Map<String, _PartSummary> result = {};
    for (final sec in sections) {
      final part = sec.part;
      result.putIfAbsent(part, () => _PartSummary(part: part));
      for (final q in sec.questions) {
        final a = widget.assessment.answers[q.id];
        result[part]!.total++;
        result[part]!.score += (a?.score ?? 0);
        if (a?.isAnswered == true) result[part]!.answered++;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assessment;
    final color = _riskColor(a.riskLevel);
    final compliance = a.complianceScore;
    final partSummaries = _buildPartSummaries();

    return AnimatedBuilder(
      animation: lang,
      builder: (_, __) => Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            _l == 'id' ? 'Hasil Asesmen GRMS 2167.01a' : 'GRMS 2167.01a Assessment Result',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          actions: [
            GestureDetector(
              onTap: lang.toggle,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language_rounded,
                        color: AppTheme.goldPrimary, size: 14),
                    const SizedBox(width: 4),
                    Text(lang.isEn ? 'ID' : 'EN',
                        style: const TextStyle(
                            color: AppTheme.goldPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fade,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // ─── Risk Level Banner ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gpp_maybe_rounded, color: color, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          _l == 'id' ? 'LEVEL RISIKO KEBAKARAN' : 'FIRE RISK LEVEL',
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _riskLabel(a.riskLevel),
                      style: TextStyle(
                        color: color,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Chip(
                          label: (_l == 'id' ? 'Kemungkinan: ' : 'Likelihood: ') +
                              _likelihoodLabel(a.hazardLikelihood),
                          color: color,
                        ),
                        _Chip(
                          label: (_l == 'id' ? 'Dampak: ' : 'Consequence: ') +
                              _consequenceLabel(a.consequenceSeverity),
                          color: color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Overall Compliance Score ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _l == 'id'
                          ? 'Skor Kepatuhan Keseluruhan'
                          : 'Overall Compliance Score',
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: compliance / 100,
                              minHeight: 12,
                              backgroundColor: AppTheme.surfaceLight,
                              valueColor: AlwaysStoppedAnimation(
                                compliance >= 70
                                    ? AppTheme.riskLow
                                    : compliance >= 50
                                        ? AppTheme.riskMedium
                                        : AppTheme.riskHigh,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${compliance.toStringAsFixed(1)}%',
                          style: TextStyle(
                              color: compliance >= 70
                                  ? AppTheme.riskLow
                                  : compliance >= 50
                                      ? AppTheme.riskMedium
                                      : AppTheme.riskHigh,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _l == 'id'
                          ? 'Berdasarkan ${_getAnsweredCount()} pertanyaan yang dijawab'
                          : 'Based on ${_getAnsweredCount()} answered questions',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Per-Part Summary ────────────────────────────────────────
              Text(
                _l == 'id' ? 'Ringkasan per Bagian' : 'Part Summary',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...partSummaries.entries.map((e) {
                final ps = e.value;
                final pct = ps.total > 0
                    ? (ps.score / ps.total) * 100
                    : 0.0;
                final partName = {
                  'C': _l == 'id' ? 'Bagian C: Bahaya Kebakaran' : 'Part C: Fire Hazards',
                  'D': _l == 'id' ? 'Bagian D: Proteksi Kebakaran' : 'Part D: Fire Protection',
                  'E': _l == 'id' ? 'Bagian E: Manajemen K3' : 'Part E: Safety Management',
                }[e.key] ?? 'Part ${e.key}';
                final barColor = pct >= 70
                    ? AppTheme.riskLow
                    : pct >= 50
                        ? AppTheme.riskMedium
                        : AppTheme.riskHigh;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(partName,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          Text('${pct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                  color: barColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 8,
                          backgroundColor: AppTheme.surfaceLight,
                          valueColor: AlwaysStoppedAnimation(barColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ps.answered}/${ps.total} ${_l == 'id' ? 'dijawab' : 'answered'}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // ─── Facility Info ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _l == 'id' ? 'Informasi Fasilitas' : 'Facility Information',
                      style: const TextStyle(
                          color: AppTheme.goldPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: _l == 'id' ? 'Nama' : 'Name',
                      value: a.factoryInfo.factoryName,
                    ),
                    _InfoRow(
                      label: _l == 'id' ? 'Tanggal' : 'Date',
                      value: '${a.factoryInfo.assessmentDate.day}/${a.factoryInfo.assessmentDate.month}/${a.factoryInfo.assessmentDate.year}',
                    ),
                    _InfoRow(
                      label: _l == 'id' ? 'Assessor' : 'Assessor',
                      value: a.factoryInfo.assessorName,
                    ),
                    _InfoRow(
                      label: _l == 'id' ? 'Dokumen' : 'Reference',
                      value: 'GRMS 2167.01a Rev.00',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Action Buttons ──────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const FactoryInfoScreen()),
                  (route) => route.isFirst,
                ),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3B5C), Color(0xFFFF6B35)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _l == 'id' ? 'Asesmen Baru' : 'New Assessment',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  int _getAnsweredCount() =>
      widget.assessment.answers.values.where((a) => a.isAnswered).length;
}

class _PartSummary {
  final String part;
  int total = 0;
  int answered = 0;
  double score = 0;
  _PartSummary({required this.part});
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
