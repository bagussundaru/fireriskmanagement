import 'dart:math';

/// A class representing the mathematical evaluation of Fire Risk using
/// Hybrid AHP (Analytic Hierarchy Process) and Fuzzy Comprehensive Evaluation.
class FuzzyLogicService {
  
  // AHP EigenVector Weights (Pre-calculated from Pairwise Comparison Matrix Consistency Ratio < 0.1)
  // Simulated Expert Consensus:
  // W_A (Legal): 0.150
  // W_B (Prevention): 0.380
  // W_C (Protection): 0.270
  // W_D (Evacuation): 0.200
  static const double weightA = 0.150;
  static const double weightB = 0.380;
  static const double weightC = 0.270;
  static const double weightD = 0.200;

  /// Defines the 3 Fuzzy Linguistics Sets for Risk
  enum FuzzyLinguistic { DANGER, WARNING, SAFE }

  /// Fuzzification logic using Trapezoidal/Triangular Membership Functions
  /// Converts a crisp score (0-100) into a vector of 3 fractional membership degrees
  static Map<FuzzyLinguistic, double> fuzzify(double crispScore) {
    double muDanger = 0.0;
    double muWarning = 0.0;
    double muSafe = 0.0;

    // Danger Membership (Trapezoid: [0, 0, 50, 70])
    if (crispScore <= 50) {
      muDanger = 1.0;
    } else if (crispScore > 50 && crispScore <= 70) {
      muDanger = (70 - crispScore) / 20;
    } else {
      muDanger = 0.0;
    }

    // Warning Membership (Triangle: [50, 70, 90])
    if (crispScore <= 50 || crispScore > 90) {
      muWarning = 0.0;
    } else if (crispScore > 50 && crispScore <= 70) {
      muWarning = (crispScore - 50) / 20;
    } else if (crispScore > 70 && crispScore <= 90) {
      muWarning = (90 - crispScore) / 20;
    }

    // Safe Membership (Trapezoid: [70, 90, 100, 100])
    if (crispScore <= 70) {
      muSafe = 0.0;
    } else if (crispScore > 70 && crispScore <= 90) {
      muSafe = (crispScore - 70) / 20;
    } else {
      muSafe = 1.0;
    }

    return {
      FuzzyLinguistic.DANGER: muDanger,
      FuzzyLinguistic.WARNING: muWarning,
      FuzzyLinguistic.SAFE: muSafe,
    };
  }

  /// Performs Fuzzy Synthetic Evaluation Matrix (R) multiplication by Weight Vector (W)
  /// Returns a Fuzzy Comprehensive Evaluation Result object
  static FuzzyEvaluationResult evaluate(
    double scoreA,
    double scoreB,
    double scoreC,
    double scoreD,
  ) {
    // 1. Get Fuzzy vectors for each factor (R Matrix)
    final rA = fuzzify(scoreA);
    final rB = fuzzify(scoreB);
    final rC = fuzzify(scoreC);
    final rD = fuzzify(scoreD);

    // 2. Perform Matrix Multiplication (B = W * R)
    double bDanger = (weightA * rA[FuzzyLinguistic.DANGER]!) +
                     (weightB * rB[FuzzyLinguistic.DANGER]!) +
                     (weightC * rC[FuzzyLinguistic.DANGER]!) +
                     (weightD * rD[FuzzyLinguistic.DANGER]!);

    double bWarning = (weightA * rA[FuzzyLinguistic.WARNING]!) +
                      (weightB * rB[FuzzyLinguistic.WARNING]!) +
                      (weightC * rC[FuzzyLinguistic.WARNING]!) +
                      (weightD * rD[FuzzyLinguistic.WARNING]!);

    double bSafe = (weightA * rA[FuzzyLinguistic.SAFE]!) +
                   (weightB * rB[FuzzyLinguistic.SAFE]!) +
                   (weightC * rC[FuzzyLinguistic.SAFE]!) +
                   (weightD * rD[FuzzyLinguistic.SAFE]!);

    // 3. Normalize Vector B to ensure sum = 1
    double sum = bDanger + bWarning + bSafe;
    if (sum > 0) {
      bDanger /= sum;
      bWarning /= sum;
      bSafe /= sum;
    }

    // 4. Defuzzification (Sugeno-style Weighted Average approximation)
    // Assigned typical crisp centroids per linguistic property:
    // DANGER = 50, WARNING = 75, SAFE = 95
    double defuzzifiedScore = (bDanger * 50) + (bWarning * 75) + (bSafe * 95);

    // 5. Determine dominant linguistic term (Maximum Membership Principle)
    String riskLevelLabel;
    double maxMembership = max(bDanger, max(bWarning, bSafe));
    if (maxMembership == bDanger) {
      riskLevelLabel = 'HIGH'; // High Risk natively mapped to Danger
    } else if (maxMembership == bWarning) {
      riskLevelLabel = 'MEDIUM'; // Medium Risk natively mapped to Warning
    } else {
      riskLevelLabel = 'LOW'; // Low Risk natively mapped to Safe
    }

    return FuzzyEvaluationResult(
      fuzzyScore: defuzzifiedScore,
      riskLevel: riskLevelLabel,
      confidence: maxMembership * 100.0,
      matrixR: {
        'A': rA,
        'B': rB,
        'C': rC,
        'D': rD,
      },
      vectorB: {
        FuzzyLinguistic.DANGER: bDanger,
        FuzzyLinguistic.WARNING: bWarning,
        FuzzyLinguistic.SAFE: bSafe,
      },
    );
  }
}

class FuzzyEvaluationResult {
  final double fuzzyScore;
  final String riskLevel;
  final double confidence;
  
  // Diagnostic Data for PDF / Advanced Metrics display
  final Map<String, Map<FuzzyLogicService.FuzzyLinguistic, double>> matrixR;
  final Map<FuzzyLogicService.FuzzyLinguistic, double> vectorB;

  FuzzyEvaluationResult({
    required this.fuzzyScore,
    required this.riskLevel,
    required this.confidence,
    required this.matrixR,
    required this.vectorB,
  });
}
