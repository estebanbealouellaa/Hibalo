import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USER STATS NOTIFIER (State Management)
// ─────────────────────────────────────────────────────────────────────────────
class UserStats extends ChangeNotifier {
  int _xp = 240;
  int _streak = 0;
  int _wordsLearned = 47;
  int _quizzesCompleted = 5;
  int _lessonsCompleted = 12;

  // Getters
  int get xp => _xp;
  int get streak => _streak;
  int get wordsLearned => _wordsLearned;
  int get quizzesCompleted => _quizzesCompleted;
  int get lessonsCompleted => _lessonsCompleted;

  // Update methods - called when lesson is completed
  void addXp(int xpEarned) {
    _xp += xpEarned;
    notifyListeners();
  }

  void addWordsLearned(int count) {
    _wordsLearned += count;
    notifyListeners();
  }

  void completeLesson() {
    _lessonsCompleted++;
    _quizzesCompleted++;
    notifyListeners();
  }

  void updateStreak(int newStreak) {
    _streak = newStreak;
    notifyListeners();
  }

  // Reset methods for testing
  void reset() {
    _xp = 0;
    _streak = 0;
    _wordsLearned = 0;
    _quizzesCompleted = 0;
    _lessonsCompleted = 0;
    notifyListeners();
  }

  // Initialize from Firestore data
  void initializeFromFirestore({
    required int xp,
    required int streak,
    required int wordsLearned,
    required int quizzesCompleted,
    required int lessonsCompleted,
  }) {
    _xp = xp;
    _streak = streak;
    _wordsLearned = wordsLearned;
    _quizzesCompleted = quizzesCompleted;
    _lessonsCompleted = lessonsCompleted;
    notifyListeners();
  }
}
