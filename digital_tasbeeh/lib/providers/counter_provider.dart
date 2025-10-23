import 'package:flutter/foundation.dart';
import '../models/tasbeeh.dart';
import '../models/count_history.dart';
import '../services/tasbeeh_repository.dart';
import '../services/count_history_repository.dart';

class CounterProvider extends ChangeNotifier {
  final TasbeehRepository _tasbeehRepository = TasbeehRepository();
  final CountHistoryRepository _countHistoryRepository = CountHistoryRepository();

  // Current state
  Tasbeeh? _currentTasbeeh;
  bool _isLoading = false;
  String? _error;

  // Getters
  Tasbeeh? get currentTasbeeh => _currentTasbeeh;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Counter-specific getters
  int get currentCount => _currentTasbeeh?.currentCount ?? 0;
  int get roundNumber => _currentTasbeeh?.roundNumber ?? 1;
  int? get targetCount => _currentTasbeeh?.targetCount;
  bool get isUnlimited => _currentTasbeeh?.isUnlimited ?? true;
  bool get isTargetReached => _currentTasbeeh?.isTargetReached ?? false;
  
  // Progress calculation for visual progress ring
  double get progressPercentage {
    if (_currentTasbeeh == null || _currentTasbeeh!.isUnlimited) {
      return 0.0;
    }
    return _currentTasbeeh!.progressPercentage;
  }

  // Get progress in terms of completed segments (for progress dots)
  int get completedSegments {
    if (_currentTasbeeh == null || _currentTasbeeh!.isUnlimited) {
      return 0;
    }
    
    const totalSegments = 33; // As specified in the design
    return (progressPercentage * totalSegments).floor();
  }

  // Check if a round was just completed
  bool get isRoundCompleted => isTargetReached && currentCount == targetCount;

  // Initialize the provider with default Tasbeeh
  Future<void> initialize() async {
    await _loadDefaultTasbeeh();
  }

  // Load the default Tasbeeh on app start
  Future<void> _loadDefaultTasbeeh() async {
    _setLoading(true);
    _clearError();

    try {
      final defaultTasbeeh = await _tasbeehRepository.getDefaultTasbeeh();
      if (defaultTasbeeh != null) {
        _currentTasbeeh = defaultTasbeeh;
        await _updateLastUsed();
      } else {
        _setError('No default Tasbeeh found');
      }
    } catch (e) {
      _setError('Failed to load default Tasbeeh: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Switch to a different Tasbeeh
  Future<void> switchTasbeeh(String tasbeehId) async {
    if (_currentTasbeeh?.id == tasbeehId) return;

    _setLoading(true);
    _clearError();

    try {
      final tasbeeh = await _tasbeehRepository.getTasbeehById(tasbeehId);
      if (tasbeeh != null) {
        _currentTasbeeh = tasbeeh;
        await _updateLastUsed();
      } else {
        _setError('Tasbeeh not found');
      }
    } catch (e) {
      _setError('Failed to switch Tasbeeh: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Increment counter with validation and round completion logic
  Future<bool> increment() async {
    if (_currentTasbeeh == null) {
      _setError('No active Tasbeeh');
      return false;
    }

    _clearError();

    try {
      int newCount = _currentTasbeeh!.currentCount + 1;
      int newRound = _currentTasbeeh!.roundNumber;
      bool roundCompleted = false;

      // Check for round completion
      if (!_currentTasbeeh!.isUnlimited && 
          _currentTasbeeh!.targetCount != null && 
          newCount >= _currentTasbeeh!.targetCount!) {
        // Round completed - reset count and increment round
        newCount = 0;
        newRound = _currentTasbeeh!.roundNumber + 1;
        roundCompleted = true;
      }

      // Update the Tasbeeh in database
      await _tasbeehRepository.updateTasbeehCount(
        _currentTasbeeh!.id,
        newCount,
        newRound,
      );

      // Record count history (record the actual increment, not the reset)
      final countToRecord = roundCompleted ? _currentTasbeeh!.targetCount! : 1;
      await _recordCountHistory(countToRecord, newRound);

      // Update local state
      _currentTasbeeh = _currentTasbeeh!.copyWith(
        currentCount: newCount,
        roundNumber: newRound,
        lastUsedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to increment counter: $e');
      return false;
    }
  }

  // Decrement counter with validation (undo functionality)
  Future<bool> decrement() async {
    if (_currentTasbeeh == null) {
      _setError('No active Tasbeeh');
      return false;
    }

    if (_currentTasbeeh!.currentCount <= 0) {
      // Cannot decrement below zero
      return false;
    }

    _clearError();

    try {
      int newCount = _currentTasbeeh!.currentCount - 1;
      int newRound = _currentTasbeeh!.roundNumber;

      // Update the Tasbeeh in database
      await _tasbeehRepository.updateTasbeehCount(
        _currentTasbeeh!.id,
        newCount,
        newRound,
      );

      // Update local state
      _currentTasbeeh = _currentTasbeeh!.copyWith(
        currentCount: newCount,
        lastUsedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to decrement counter: $e');
      return false;
    }
  }

  // Reset counter to zero
  Future<bool> reset() async {
    if (_currentTasbeeh == null) {
      _setError('No active Tasbeeh');
      return false;
    }

    _clearError();

    try {
      // Reset count and round number
      await _tasbeehRepository.resetTasbeehCount(_currentTasbeeh!.id);

      // Update local state
      _currentTasbeeh = _currentTasbeeh!.copyWith(
        currentCount: 0,
        roundNumber: 1,
        lastUsedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to reset counter: $e');
      return false;
    }
  }

  // Refresh current Tasbeeh data from database
  Future<void> refresh() async {
    if (_currentTasbeeh == null) return;

    _setLoading(true);
    _clearError();

    try {
      final updatedTasbeeh = await _tasbeehRepository.getTasbeehById(_currentTasbeeh!.id);
      if (updatedTasbeeh != null) {
        _currentTasbeeh = updatedTasbeeh;
      }
    } catch (e) {
      _setError('Failed to refresh Tasbeeh data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get progress for unlimited Tasbeehs (continuous rotation)
  double get unlimitedProgress {
    if (_currentTasbeeh == null || !_currentTasbeeh!.isUnlimited) {
      return 0.0;
    }
    
    // For unlimited Tasbeehs, create a continuous rotation effect
    // Each 100 counts = one full rotation
    const countsPerRotation = 100;
    return (currentCount % countsPerRotation) / countsPerRotation;
  }

  // Get display text for target count
  String get targetDisplayText {
    if (_currentTasbeeh == null || _currentTasbeeh!.isUnlimited) {
      return '';
    }
    return '/ ${_currentTasbeeh!.targetCount}';
  }

  // Get display text for round number
  String get roundDisplayText {
    if (_currentTasbeeh == null) return '';
    
    if (_currentTasbeeh!.isUnlimited) {
      // For unlimited Tasbeehs, show rounds based on every 100 counts
      final roundsCompleted = (currentCount / 100).floor();
      return roundsCompleted > 0 ? 'Round ${roundsCompleted + 1}' : '';
    } else {
      // For limited Tasbeehs, show actual round number
      return roundNumber > 1 ? 'Round $roundNumber' : '';
    }
  }

  // Validate counter state
  bool validateCounterState() {
    if (_currentTasbeeh == null) return false;
    
    // Validate count is not negative
    if (_currentTasbeeh!.currentCount < 0) return false;
    
    // Validate round number is positive
    if (_currentTasbeeh!.roundNumber < 1) return false;
    
    // For limited Tasbeehs, validate count doesn't exceed target
    if (!_currentTasbeeh!.isUnlimited && 
        _currentTasbeeh!.targetCount != null &&
        _currentTasbeeh!.currentCount >= _currentTasbeeh!.targetCount!) {
      return false;
    }
    
    return true;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _updateLastUsed() async {
    if (_currentTasbeeh != null) {
      await _tasbeehRepository.updateLastUsed(_currentTasbeeh!.id);
    }
  }

  Future<void> _recordCountHistory(int count, int round) async {
    if (_currentTasbeeh == null) return;

    final countHistory = CountHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tasbeehId: _currentTasbeeh!.id,
      count: count,
      timestamp: DateTime.now(),
      roundNumber: round,
    );

    await _countHistoryRepository.insertCountHistory(countHistory);
  }


}