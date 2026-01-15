//lib/risk/risk_engine.dart
enum RiskLevel { low, medium, high }

class BehaviorFeatures {
  final double avgTypingSpeed;
  final double typingVariance;
  final double avgTapDuration;
  final int eventsPerWindow;
  final String firstScreenAfterLogin;
  BehaviorFeatures({
    required this.avgTypingSpeed,
    required this.typingVariance,
    required this.avgTapDuration,
    required this.eventsPerWindow,
    required this.firstScreenAfterLogin,
  });
}

class RiskResult {
  final RiskLevel level;
  final int score;
  final List<String> reasons;
  RiskResult({required this.level, required this.score, required this.reasons});
}

class RiskEngine {
  static const double baselineTypingSpeed = 180;
  static const double baselineTapDuration = 120;
  static const String baselineFirstScreen = "home";
  RiskResult evaluate(BehaviorFeatures features) {
    int riskScore = 0;
    final List<String> reasons = [];
    if (features.avgTypingSpeed > baselineTypingSpeed * 1.6 ||
        features.avgTypingSpeed < baselineTypingSpeed * 0.6) {
      riskScore += 2;
      reasons.add("Typing speed deviates from baseline");
    }
    if (features.typingVariance > 2.5) {
      riskScore += 1;
      reasons.add("High typing inconsistency");
    }
    if (features.avgTapDuration > baselineTapDuration * 1.8 ||
        features.avgTapDuration < baselineTapDuration * 0.5) {
      riskScore += 1;
      reasons.add("Abnormal tap duration");
    }
    if (features.eventsPerWindow > 40 || features.eventsPerWindow < 5) {
      riskScore += 1;
      reasons.add("Unusual interaction rhythm");
    }
    if (features.firstScreenAfterLogin != baselineFirstScreen) {
      riskScore += 2;
      reasons.add("Unexpected first screen after login");
    }
    RiskLevel level;
    if (riskScore >= 4) {
      level = RiskLevel.high;
    } else if (riskScore >= 2) {
      level = RiskLevel.medium;
    } else {
      level = RiskLevel.low;
    }
    return RiskResult(level: level, score: riskScore, reasons: reasons);
  }
}
