import 'package:flutter/material.dart';

import 'behavior/behavior_collector.dart';
import 'risk/risk_engine.dart';

final BehaviorCollector behaviorCollector = BehaviorCollector();

void main() {
  runApp(const BankGuardApp());
}

class BankGuardApp extends StatelessWidget {
  const BankGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BankGuard AI',
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

  void _checkRisk(BuildContext context) {
    final result = behaviorCollector.evaluateIfNeeded(currentScreen: 'demo');

    if (result.level == RiskLevel.medium) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Verification Required'),
          content: Text(
            result.reasons.isEmpty
                ? 'Additional verification required.'
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
          final durationMs = DateTime.now()
              .difference(_tapStart!)
              .inMilliseconds;

          behaviorCollector.recordTap(tapDurationMs: durationMs);
          _checkRisk(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('BankGuard AI – Behavior Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Type below to generate behavior signals'),
              const SizedBox(height: 16),
              TextField(
                onChanged: (_) {
                  behaviorCollector.recordKeyPress(timeBetweenKeysMs: 200);
                  _checkRisk(context);
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
