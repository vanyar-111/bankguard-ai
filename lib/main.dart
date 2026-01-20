import 'package:flutter/material.dart';

import 'behavior/behavior_collector.dart';
import 'risk/risk_engine.dart';

final BehaviorCollector behaviorCollector = BehaviorCollector();
final RiskEngine riskEngine = RiskEngine();

// Demo-only baseline (hardcoded for prototype clarity)
final UserBaseline demoBaseline = UserBaseline(
  avgTypingSpeed: 4.0, // keys per second
  avgTapDuration: 120,
  commonFirstScreen: 'home',
);

void main() {
  runApp(const SessionLockApp());
}

class SessionLockApp extends StatelessWidget {
  const SessionLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SessionLock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const BehaviorDemoScreen(),
    );
  }
}

class BehaviorDemoScreen extends StatefulWidget {
  const BehaviorDemoScreen({super.key});

  @override
  State<BehaviorDemoScreen> createState() => _BehaviorDemoScreenState();
}

class _BehaviorDemoScreenState extends State<BehaviorDemoScreen> {
  DateTime? _tapStart;

  void _evaluateIfWindowReady(BuildContext context) {
    final window = behaviorCollector.collectWindowIfReady();
    if (window == null) return;

    final features = BehaviorFeatures(
      avgTypingSpeed: window.typingSpeedKps,
      typingVariance: window.typingVariance,
      avgTapDuration: window.avgTapDurationMs,
      eventsPerWindow: window.eventCount,
      firstScreenAfterLogin: 'home', // fixed for demo
    );

    final result = riskEngine.evaluate(
      current: features,
      baseline: demoBaseline,
    );

    if (result.level == RiskLevel.medium) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Additional Verification Required'),
          content: Text(
            result.reasons.isEmpty
                ? 'Suspicious behavior detected.'
                : result.reasons.join('\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    if (result.level == RiskLevel.high) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('High risk detected. Session terminated.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _tapStart = DateTime.now();
      },
      onTapUp: (_) {
        if (_tapStart != null) {
          final durationMs =
              DateTime.now().difference(_tapStart!).inMilliseconds;

          behaviorCollector.recordTap(tapDurationMs: durationMs);
          _evaluateIfWindowReady(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SessionLock — Behavior Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Type below to generate behavioral signals',
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (_) {
                  behaviorCollector.recordKeyPress(
                    timeBetweenKeysMs: 200, // demo value
                  );
                  _evaluateIfWindowReady(context);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Start typing...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
