// lib/behavior/behavior_collector.dart
import '../risk/risk_engine.dart';

class BehaviorCollector {
  final RiskEngine _riskEngine = RiskEngine();
  // --- Internal state (this is "state vs events") ---
  int _keyPressCount = 0;
  int _tapCount = 0;
  int _totalTapDurationMs = 0;
  int _eventCount = 0;
  DateTime _windowStart = DateTime.now();
  // --- Called when user types ---
  void recordKeyPress({required int timeBetweenKeysMs}) {
    _keyPressCount++;
    _eventCount++;
  }

  // --- Called when user taps ---
  void recordTap({required int tapDurationMs}) {
    _tapCount++;
    _totalTapDurationMs += tapDurationMs;
    _eventCount++;
  }

  // --- Called on screen change ---
  RiskResult evaluateIfNeeded({required String currentScreen}) {
    final now = DateTime.now();
    final windowDuration = now.difference(_windowStart).inSeconds;
    // Evaluate every 10 seconds
    if (windowDuration < 10) {
      return RiskResult(level: RiskLevel.low, score: 0, reasons: const []);
    }
    final avgTapDuration = _tapCount == 0 ? 0 : _totalTapDurationMs / _tapCount;
    final features = BehaviorFeatures(
      avgTypingSpeed: _keyPressCount == 0
          ? 0
          : windowDuration * 1000 / _keyPressCount,
      typingVariance: 1.0, // fake for v1
      avgTapDuration: avgTapDuration.toDouble(),
      eventsPerWindow: _eventCount,
      firstScreenAfterLogin: currentScreen,
    );
    // Reset window
    _resetWindow();
    return _riskEngine.evaluate(features);
  }

  void _resetWindow() {
    _keyPressCount = 0;
    _tapCount = 0;
    _totalTapDurationMs = 0;
    _eventCount = 0;
    _windowStart = DateTime.now();
  }
}
