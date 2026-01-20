# SessionLock

**SessionLock**- Behavior-based Cntinuous Authentication (Architecture Prototype)

SessionLock is an **architecture focused prototype** for behavior-based continuous authentication in mbile applications. Instead of relying on static credentials (Passwords, OTPs, biometrics) it models user interaction behavior and evaluates risk continuously during a session.

This repository intentionally focuses on event collection, risk scoring and adaptive decision logic, not on building a production-ready mobile app.

## Problem Statement
Traditional authentication mechanisms have clear weaknesses: 
-Passwords and OTPs can be shared, phished or replayed.
-Biometrics are static and only verified at login.
-Authentication is usually binary (pass/fail), not continuous.

SessionLock explores the idea of continuous authentication.

## Core Idea
Every user interacts with an app in a unique way. SessionLock continuously observes interaction patterns and compares them against expected behavior to assign a real-time risk score.

### Examples of behavioral signals:
- Tap Duration
- Typing rhythm (time between key presses)
- Interaction frequency 
- Screen-level activity context
These signals are hard to replicate, even if credentials are compromised.

## Architecture Overview

User Interaction
      ↓
Behavior Collector (captures raw events)
      ↓
Risk Engine (evaluates deviation + thresholds)
      ↓
Risk Result:
     Low- Silent Continuation
     Medium- Verification Prompt
     High- Session Termination

This flow is event driven and intentionally decoupled:
-No UI logic inside risk evaluation 
-No platform-specific dependencies
-Deterministics, explainable decisions

## Repository Structure
lib/
├── behavior/
│ └── behavior_collector.dart // Collects interaction events
├── risk/
│ ├── risk_engine.dart // Core risk evaluation logic
│ └── risk_result.dart // Risk levels & explanations
└── main.dart // Minimal demo wiring behavior → risk

## Scope Disclaimer

This project is not:
- A full banking application
- A production-ready authentication system
- A UI-focused Flutter app

This project is:
- An architectural prototype
- A demonstration of behavioral security thinking
- A foundation for future ML-based or adaptive authentication systems

## What This Demonstrates Technically

- Event-driven system design
- Behavioral modeling without raw biometrics
- Risk scoring using explicit thresholds
- Separation of concerns (collection vs evaluation vs response)
- Security-oriented product thinking

## Future Extensions (Out of Scope for This Repo)

- ML-based anomaly detection
- On-device model training
- Backend-assisted session analytics
- Privacy-preserving behavioral baselines

These are deliberately excluded to keep the prototype focused and auditable.

