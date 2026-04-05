import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../data/assessment_data.dart';
import 'scoring_service.dart';

/// Service untuk generate dan export PDF report
class PdfService {
  static Future<Uint8List> generateReport(Assessment assessment) async {
    final pdf = pw.Document();
    final categories = AssessmentData.getCategories();

    // Header colors
    final headerColor = PdfColor.fromHex('#FFD700'); // Gold
    final darkColor = PdfColor.fromHex('#1A1A1A');
    final riskColor = _getRiskPdfColor(assessment.riskLevel);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(assessment),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Title
          pw.Center(
            child: pw.Text(
              'FIRE RISK ASSESSMENT REPORT',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: headerColor,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'Powered by Fuzzy AHP Comprehensive Evaluation Model',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.SizedBox(height: 16),

          // Factory Information
          _buildSection('Factory Information', [
            _buildInfoRow('Assessment Date', DateFormat('dd MMMM yyyy').format(assessment.factoryInfo.assessmentDate)),
            _buildInfoRow('Factory Name', assessment.factoryInfo.factoryName),
            _buildInfoRow('Factory Type', assessment.factoryInfo.factoryType),
            _buildInfoRow('Worker Count', assessment.factoryInfo.workerCount),
            _buildInfoRow('Assessor Name', assessment.factoryInfo.assessorName),
            _buildInfoRow('GM/Director', assessment.factoryInfo.gmDirector),
          ]),
          pw.SizedBox(height: 20),

          // Overall Score
          _buildSection('Overall Assessment', [
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: riskColor, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        '${assessment.totalScore.toStringAsFixed(1)}%',
                        style: pw.TextStyle(
                          fontSize: 36,
                          fontWeight: pw.FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                      pw.Text('Total Score'),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: riskColor,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      '${assessment.riskLevel} RISK',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          pw.SizedBox(height: 20),

          // Category Breakdown
          ...categories.map((category) {
            final score = assessment.categoryScores[category.id] ?? 0;
            final answeredCount = ScoringService.getCategoryAnsweredCount(category, assessment.answers);
            
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildCategoryHeader(category, score, answeredCount),
                pw.SizedBox(height: 8),
                ...category.subCategories.map((sub) {
                  final subScore = ScoringService.calculateSubCategoryScore(sub, assessment.answers);
                  final subAnswered = sub.questions.where((q) => assessment.answers.containsKey(q.id)).length;
                  return _buildProgressRow(
                    sub.name, 
                    subScore, 
                    '$subAnswered/${sub.questions.length}',
                  );
                }),
                pw.SizedBox(height: 16),
              ],
            );
          }),

          // Recommendations
          pw.SizedBox(height: 10),
          _buildSection('Recommendations', [
            pw.Text(
              ScoringService.getRecommendation(assessment.totalScore, assessment.categoryScores),
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Follow-up Schedule:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Bullet(
              text: assessment.riskLevel == 'HIGH'
                  ? 'Immediate action required for critical issues'
                  : 'Review and address issues within 30 days',
            ),
            pw.Bullet(
              text: assessment.riskLevel == 'HIGH'
                  ? 'Follow-up assessment within 2 months'
                  : 'Next assessment within 6 months',
            ),
            pw.Bullet(text: 'Implement critical corrections immediately'),
          ]),

          // Signature Section
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSignatureBox('Assessor', assessment.factoryInfo.assessorName),
              _buildSignatureBox('GM/Director', assessment.factoryInfo.gmDirector),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(Assessment assessment) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Fire Risk Assessment',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            assessment.factoryInfo.factoryName,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            color: PdfColors.grey200,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text('$label:', style: const pw.TextStyle(fontSize: 10)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCategoryHeader(Category category, double score, int answeredCount) {
    final riskLevel = score >= 80 ? 'LOW' : score >= 60 ? 'MEDIUM' : 'HIGH';
    final riskColor = _getRiskPdfColor(riskLevel);
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: riskColor),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${category.code}. ${category.name}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                ),
                pw.Text(
                  'Weight: ${category.weight}% | Answered: $answeredCount/${category.totalQuestions}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: riskColor,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              '${score.toStringAsFixed(1)}%',
              style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProgressRow(String label, double score, String count) {
    final color = _getRiskPdfColor(score >= 80 ? 'LOW' : score >= 60 ? 'MEDIUM' : 'HIGH');
    
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
              pw.Text(count, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.SizedBox(width: 10),
              pw.Text('${score.toStringAsFixed(1)}%', style: pw.TextStyle(fontSize: 9, color: color, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Container(
            height: 6,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: (score * 10).toInt(),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: (1000 - (score * 10)).toInt(),
                  child: pw.SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureBox(String role, String name) {
    return pw.Container(
      width: 200,
      child: pw.Column(
        children: [
          pw.Container(
            height: 50,
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide()),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text(role, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static PdfColor _getRiskPdfColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return PdfColor.fromHex('#00AA55');
      case 'MEDIUM':
        return PdfColor.fromHex('#FFB800');
      case 'HIGH':
        return PdfColor.fromHex('#DD3333');
      default:
        return PdfColors.grey;
    }
  }

  /// Print or share PDF
  static Future<void> printReport(Assessment assessment) async {
    final pdfData = await generateReport(assessment);
    await Printing.layoutPdf(onLayout: (format) => pdfData);
  }

  /// Share PDF
  static Future<void> shareReport(Assessment assessment) async {
    final pdfData = await generateReport(assessment);
    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'Fire_Risk_Assessment_${assessment.factoryInfo.factoryName.replaceAll(' ', '_')}.pdf',
    );
  }
}
