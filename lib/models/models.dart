// ─── Question Types ────────────────────────────────────────────────────────
enum QuestionType { binary, likert, multiChoice }

// ─── Industry Types ────────────────────────────────────────────────────────
enum IndustryType {
  manufacturing('Manufacturing / Industri', 'Pabrik/Industri dengan proses produksi'),
  residential('Residential / Hunian', 'Gedung hunian, apartemen, perumahan'),
  commercial('Commercial / Komersial', 'Perkantoran, mal, hotel'),
  mixed('Mixed Use', 'Campuran hunian dan komersial');

  final String label;
  final String description;
  const IndustryType(this.label, this.description);
}

class FactoryInfo {
  final String factoryName;
  final String factoryType;
  final IndustryType industryType;
  final String workerCount;
  final String assessorName;
  final String gmDirector;
  final DateTime assessmentDate;

  FactoryInfo({
    required this.factoryName,
    required this.factoryType,
    required this.industryType,
    required this.workerCount,
    required this.assessorName,
    required this.gmDirector,
    DateTime? assessmentDate,
  }) : assessmentDate = assessmentDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'factoryName': factoryName,
    'factoryType': factoryType,
    'industryType': industryType.name,
    'workerCount': workerCount,
    'assessorName': assessorName,
    'gmDirector': gmDirector,
    'assessmentDate': assessmentDate.toIso8601String(),
  };

  factory FactoryInfo.fromJson(Map<String, dynamic> json) => FactoryInfo(
    factoryName: json['factoryName'] ?? '',
    factoryType: json['factoryType'] ?? '',
    industryType: IndustryType.values.firstWhere(
      (e) => e.name == (json['industryType'] ?? 'manufacturing'),
      orElse: () => IndustryType.manufacturing,
    ),
    workerCount: json['workerCount'] ?? '',
    assessorName: json['assessorName'] ?? '',
    gmDirector: json['gmDirector'] ?? '',
    assessmentDate: json['assessmentDate'] != null
        ? DateTime.parse(json['assessmentDate'])
        : DateTime.now(),
  );
}

class Category {
  final String id;
  final String code;
  final String name;
  final double weight;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.code,
    required this.name,
    required this.weight,
    required this.subCategories,
  });

  int get totalQuestions => subCategories.fold(0, (sum, sub) => sum + sub.questions.length);
}

class SubCategory {
  final String id;
  final String name;
  final List<Question> questions;

  SubCategory({
    required this.id,
    required this.name,
    required this.questions,
  });
}

class Question {
  final String id;
  final String text;
  final double weight;
  final QuestionType type;
  final List<String>? options;
  final String? likertLow;
  final String? likertHigh;

  Question({
    required this.id,
    required this.text,
    this.weight = 1.0,
    this.type = QuestionType.binary,
    this.options,
    this.likertLow,
    this.likertHigh,
  });
}

class Answer {
  final String questionId;
  final bool isCompliant;
  final int? likertValue;
  final String? notes;

  Answer({
    required this.questionId,
    required this.isCompliant,
    this.likertValue,
    this.notes,
  });

  double scoreFor(Question question) {
    switch (question.type) {
      case QuestionType.binary:
        return isCompliant ? 1.0 : 0.0;
      case QuestionType.likert:
        return (likertValue ?? 0) / 4.0;
      case QuestionType.multiChoice:
        final opts = question.options;
        if (opts == null || opts.isEmpty) return isCompliant ? 1.0 : 0.0;
        return (likertValue ?? 0) / (opts.length - 1).toDouble();
    }
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'isCompliant': isCompliant,
    'likertValue': likertValue,
    'notes': notes,
  };

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
    questionId: json['questionId'],
    isCompliant: json['isCompliant'] ?? false,
    likertValue: json['likertValue'],
    notes: json['notes'],
  );
}

class Assessment {
  final String id;
  final FactoryInfo factoryInfo;
  final Map<String, Answer> answers;
  final double totalScore;
  final String riskLevel;
  final Map<String, double> categoryScores;
  final DateTime createdAt;
  final bool isCompleted;

  Assessment({
    required this.id,
    required this.factoryInfo,
    required this.answers,
    required this.totalScore,
    required this.riskLevel,
    required this.categoryScores,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static String getRiskLevel(double score) {
    if (score >= 80) return 'LOW';
    if (score >= 60) return 'MEDIUM';
    return 'HIGH';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'factoryInfo': factoryInfo.toJson(),
    'answers': answers.map((k, v) => MapEntry(k, v.toJson())),
    'totalScore': totalScore,
    'riskLevel': riskLevel,
    'categoryScores': categoryScores,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
    id: json['id'],
    factoryInfo: FactoryInfo.fromJson(json['factoryInfo']),
    answers: (json['answers'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, Answer.fromJson(v)),
    ),
    totalScore: (json['totalScore'] ?? 0).toDouble(),
    riskLevel: json['riskLevel'] ?? 'HIGH',
    categoryScores: (json['categoryScores'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ??
        {},
    isCompleted: json['isCompleted'] ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}
