enum RiskLevel { low, medium, high }

class RiskResult {
  final RiskLevel level;
  final List<String> reasons;
  RiskResult({required this.level, this.reasons = const []});
}
