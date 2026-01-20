enum RiskLevel { low, medium, high }

class UserBaseline {
  final double avgTypingSpeed;
  final double avgTapDuration;
  final String commonFirstScreen;

  const UserBaseline({
    required this.avgTypingSpeed,
    required this.avgTapDuration,
    required this.commonFirstScreen,
  });
}

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

  const RiskResult({
    required this.level,
    required this.score,
    required this.reasons,
  });
}

class RiskEngine {
  RiskResult evaluate({
    required BehaviorFeatures current,
    required UserBaseline baseline,
  }) {
    int score = 0;
    final reasons = <String>[];

    // Typing speed deviation
    final typingRatio =
        current.avgTypingSpeed / baseline.avgTypingSpeed;

    if (typingRatio > 1.6 || typingRatio < 0.6) {
      score += 2;
      reasons.add("Significant typing speed deviation");
    }

    // Typing consistency
    if (current.typingVariance > 2.5) {
      score += 1;
      reasons.add("High typing variance");
    }

    // Tap behavior
    final tapRatio =
        current.avgTapDuration / baseline.avgTapDuration;

    if (tapRatio > 1.8 || tapRatio < 0.5) {
      score += 1;
      reasons.add("Abnormal tap duration pattern");
    }

    // Interaction rhythm (soft signal)
    if (current.eventsPerWindow < 3) {
      score += 1;
      reasons.add("Unusually low interaction frequency");
    }

    // Navigation anomaly (strong signal)
    if (current.firstScreenAfterLogin != baseline.commonFirstScreen) {
      score += 2;
      reasons.add("Unexpected navigation flow after login");
    }

    final RiskLevel level =
        score >= 4 ? RiskLevel.high :
        score >= 2 ? RiskLevel.medium :
        RiskLevel.low;

    return RiskResult(
      level: level,
      score: score,
      reasons: reasons,
    );
  }
}
