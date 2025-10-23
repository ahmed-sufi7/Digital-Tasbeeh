import 'package:flutter/foundation.dart';
import '../models/tasbeeh.dart';
import '../services/tasbeeh_repository.dart';

class TasbeehProvider extends ChangeNotifier {
  final TasbeehRepository _repository = TasbeehRepository();

  // State
  List<Tasbeeh> _tasbeehs = [];
  Tasbeeh? _selectedTasbeeh;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Tasbeeh> get tasbeehs => _tasbeehs;
  Tasbeeh? get selectedTasbeeh => _selectedTasbeeh;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get default Tasbeeh
  Tasbeeh? get defaultTasbeeh {
    try {
      return _tasbeehs.firstWhere((tasbeeh) => tasbeeh.isDefault);
    } catch (e) {
      return _tasbeehs.isNotEmpty ? _tasbeehs.first : null;
    }
  }

  // Initialize provider
  Future<void> initialize() async {
    await loadTasbeehs();
  }

  // Load all Tasbeehs
  Future<void> loadTasbeehs() async {
    _setLoading(true);
    _clearError();

    try {
      _tasbeehs = await _repository.getAllTasbeehs();

      // Set default selection if none selected
      if (_selectedTasbeeh == null && _tasbeehs.isNotEmpty) {
        _selectedTasbeeh = defaultTasbeeh ?? _tasbeehs.first;
      }
    } catch (e) {
      _setError('Failed to load Tasbeehs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Select a Tasbeeh
  void selectTasbeeh(Tasbeeh tasbeeh) {
    if (_selectedTasbeeh?.id != tasbeeh.id) {
      _selectedTasbeeh = tasbeeh;
      notifyListeners();
    }
  }

  // Create new Tasbeeh
  Future<bool> createTasbeeh({required String name, int? targetCount}) async {
    _clearError();

    try {
      // Validate name
      if (name.trim().isEmpty) {
        _setError('Tasbeeh name cannot be empty');
        return false;
      }

      // Check if name already exists
      final nameExists = await _repository.tasbeehNameExists(name.trim());
      if (nameExists) {
        _setError('A Tasbeeh with this name already exists');
        return false;
      }

      // Create new Tasbeeh
      final now = DateTime.now();
      final tasbeeh = Tasbeeh(
        id: 'tasbeeh_${now.millisecondsSinceEpoch}',
        name: name.trim(),
        targetCount: targetCount,
        currentCount: 0,
        roundNumber: 1,
        createdAt: now,
        lastUsedAt: now,
        isDefault: false,
      );

      await _repository.insertTasbeeh(tasbeeh);
      await loadTasbeehs(); // Refresh list

      return true;
    } catch (e) {
      _setError('Failed to create Tasbeeh: $e');
      return false;
    }
  }

  // Update existing Tasbeeh
  Future<bool> updateTasbeeh({
    required String id,
    required String name,
    int? targetCount,
  }) async {
    _clearError();

    try {
      // Validate name
      if (name.trim().isEmpty) {
        _setError('Tasbeeh name cannot be empty');
        return false;
      }

      // Check if name already exists (excluding current Tasbeeh)
      final nameExists = await _repository.tasbeehNameExists(
        name.trim(),
        excludeId: id,
      );
      if (nameExists) {
        _setError('A Tasbeeh with this name already exists');
        return false;
      }

      // Find existing Tasbeeh
      final existingTasbeeh = _tasbeehs.firstWhere(
        (tasbeeh) => tasbeeh.id == id,
      );

      // Update Tasbeeh
      final updatedTasbeeh = existingTasbeeh.copyWith(
        name: name.trim(),
        targetCount: targetCount,
        lastUsedAt: DateTime.now(),
      );

      await _repository.updateTasbeeh(updatedTasbeeh);
      await loadTasbeehs(); // Refresh list

      return true;
    } catch (e) {
      _setError('Failed to update Tasbeeh: $e');
      return false;
    }
  }

  // Delete Tasbeeh
  Future<bool> deleteTasbeeh(String id) async {
    _clearError();

    try {
      // Find the Tasbeeh to delete
      final tasbeeh = _tasbeehs.firstWhere((t) => t.id == id);

      // Prevent deletion of default Tasbeeh
      if (tasbeeh.isDefault) {
        _setError('Cannot delete the default Tasbeeh');
        return false;
      }

      await _repository.deleteTasbeeh(id);

      // If deleted Tasbeeh was selected, select default
      if (_selectedTasbeeh?.id == id) {
        _selectedTasbeeh = defaultTasbeeh;
      }

      await loadTasbeehs(); // Refresh list
      return true;
    } catch (e) {
      _setError('Failed to delete Tasbeeh: $e');
      return false;
    }
  }

  // Get Tasbeeh by ID
  Tasbeeh? getTasbeehById(String id) {
    try {
      return _tasbeehs.firstWhere((tasbeeh) => tasbeeh.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search Tasbeehs
  List<Tasbeeh> searchTasbeehs(String query) {
    if (query.trim().isEmpty) return _tasbeehs;

    final lowerQuery = query.toLowerCase();
    return _tasbeehs.where((tasbeeh) {
      return tasbeeh.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get Tasbeehs grouped by type
  Map<String, List<Tasbeeh>> get groupedTasbeehs {
    final Map<String, List<Tasbeeh>> grouped = {'Default': [], 'Custom': []};

    for (final tasbeeh in _tasbeehs) {
      if (tasbeeh.isDefault) {
        grouped['Default']!.add(tasbeeh);
      } else {
        grouped['Custom']!.add(tasbeeh);
      }
    }

    return grouped;
  }

  // Validate Tasbeeh data
  String? validateTasbeehName(String name, {String? excludeId}) {
    if (name.trim().isEmpty) {
      return 'Name cannot be empty';
    }

    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check for duplicate names
    final exists = _tasbeehs.any(
      (tasbeeh) =>
          tasbeeh.name.toLowerCase() == name.trim().toLowerCase() &&
          tasbeeh.id != excludeId,
    );

    if (exists) {
      return 'A Tasbeeh with this name already exists';
    }

    return null;
  }

  String? validateTargetCount(int? targetCount) {
    if (targetCount != null) {
      if (targetCount <= 0) {
        return 'Target count must be greater than 0';
      }
      if (targetCount > 10000) {
        return 'Target count must be less than 10,000';
      }
    }
    return null;
  }

  // Clear error
  void clearError() {
    _clearError();
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
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
