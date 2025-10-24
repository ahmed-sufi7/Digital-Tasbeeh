import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/tasbeeh.dart';
import '../providers/tasbeeh_provider.dart';

class TasbeehFormModal extends StatefulWidget {
  final Tasbeeh? tasbeeh; // null for create, non-null for edit

  const TasbeehFormModal({super.key, this.tasbeeh});

  bool get isEditing => tasbeeh != null;

  @override
  State<TasbeehFormModal> createState() => _TasbeehFormModalState();
}

class _TasbeehFormModalState extends State<TasbeehFormModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _customCountController;

  int _selectedCountOption = 0; // 0: Unlimited, 1: 33, 2: 99, 3: Custom
  bool _isLoading = false;
  String? _nameError;
  String? _countError;

  final List<String> _countOptions = ['Unlimited', '33', '99', 'Custom'];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.tasbeeh?.name ?? '');
    _customCountController = TextEditingController();

    // Initialize form with existing data if editing
    if (widget.isEditing) {
      final targetCount = widget.tasbeeh!.targetCount;
      if (targetCount == null) {
        _selectedCountOption = 0; // Unlimited
      } else if (targetCount == 33) {
        _selectedCountOption = 1;
      } else if (targetCount == 99) {
        _selectedCountOption = 2;
      } else {
        _selectedCountOption = 3; // Custom
        _customCountController.text = targetCount.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceColor(isDark).withValues(alpha: 0.9),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: _isLoading
                  ? AppColors.textSecondaryColor(isDark)
                  : AppColors.primary,
              fontSize: 17,
              fontFamily: AppTextStyles.fontFamily,
            ),
          ),
        ),
        middle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            widget.isEditing ? 'Edit Tasbeeh' : 'New Tasbeeh',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor(isDark),
              fontFamily: AppTextStyles.fontFamily,
              letterSpacing: -0.4,
            ),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _saveTasbeeh,
          child: _isLoading
              ? const CupertinoActivityIndicator(radius: 10)
              : Text(
                  'Save',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),

            // Tasbeeh Name Section
            _buildSectionHeader('Tasbeeh Name', isDark),
            const SizedBox(height: 8),
            _buildNameField(isDark),

            const SizedBox(height: 32),

            // Count Limit Section
            _buildSectionHeader('Count Limit', isDark),
            const SizedBox(height: 8),
            _buildCountLimitSelector(isDark),

            // Custom Count Field (shown when Custom is selected)
            if (_selectedCountOption == 3) ...[
              const SizedBox(height: 16),
              _buildCustomCountField(isDark),
            ],

            const SizedBox(height: 32),

            // Description
            _buildDescription(isDark),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryColor(isDark),
          fontFamily: AppTextStyles.fontFamily,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: _nameError != null
            ? Border.all(color: CupertinoColors.systemRed, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Enter Tasbeeh name...',
            placeholderStyle: TextStyle(
              color: AppColors.textSecondaryColor(isDark),
              fontSize: 16,
              fontFamily: AppTextStyles.fontFamily,
            ),
            style: TextStyle(
              color: AppColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontFamily: AppTextStyles.fontFamily,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            maxLength: 50,
            onChanged: (value) {
              if (_nameError != null) {
                setState(() {
                  _nameError = null;
                });
              }
            },
          ),
          if (_nameError != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                _nameError!,
                style: TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountLimitSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Segmented Control
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _selectedCountOption,
              children: {
                for (int i = 0; i < _countOptions.length; i++)
                  i: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Text(
                      _countOptions[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: AppTextStyles.fontFamily,
                      ),
                    ),
                  ),
              },
              onValueChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCountOption = value;
                    if (_countError != null) {
                      _countError = null;
                    }
                  });
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),

          // Description for selected option
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              _getCountOptionDescription(_selectedCountOption),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor(isDark),
                fontFamily: AppTextStyles.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCountField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: _countError != null
            ? Border.all(color: CupertinoColors.systemRed, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _customCountController,
            placeholder: 'Enter custom count...',
            placeholderStyle: TextStyle(
              color: AppColors.textSecondaryColor(isDark),
              fontSize: 16,
              fontFamily: AppTextStyles.fontFamily,
            ),
            style: TextStyle(
              color: AppColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontFamily: AppTextStyles.fontFamily,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5), // Max 99999
            ],
            onChanged: (value) {
              if (_countError != null) {
                setState(() {
                  _countError = null;
                });
              }
            },
          ),
          if (_countError != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                _countError!,
                style: TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'About Count Limits',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Unlimited: Count without any limit\n'
            '• 33 & 99: Traditional dhikr counts\n'
            '• Custom: Set your own target count\n\n'
            'When you reach the target, the counter will reset and start a new round.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryColor(isDark),
              fontFamily: AppTextStyles.fontFamily,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getCountOptionDescription(int option) {
    switch (option) {
      case 0:
        return 'Count without any limit - perfect for continuous dhikr';
      case 1:
        return 'Traditional count of 33 - commonly used for Tasbih';
      case 2:
        return 'Traditional count of 99 - commonly used for Tasbih';
      case 3:
        return 'Set your own custom target count';
      default:
        return '';
    }
  }

  int? _getTargetCount() {
    if (_selectedCountOption == 0) {
      return null; // Unlimited
    } else if (_selectedCountOption == 1) {
      return 33;
    } else if (_selectedCountOption == 2) {
      return 99;
    } else {
      // Custom
      final customCount = int.tryParse(_customCountController.text);
      return customCount;
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate name
    final nameValidation = context.read<TasbeehProvider>().validateTasbeehName(
      _nameController.text,
      excludeId: widget.tasbeeh?.id,
    );
    if (nameValidation != null) {
      setState(() {
        _nameError = nameValidation;
      });
      isValid = false;
    }

    // Validate custom count if selected
    if (_selectedCountOption == 3) {
      final customCount = int.tryParse(_customCountController.text);
      final countValidation = context
          .read<TasbeehProvider>()
          .validateTargetCount(customCount);
      if (countValidation != null) {
        setState(() {
          _countError = countValidation;
        });
        isValid = false;
      }
    }

    return isValid;
  }

  void _saveTasbeeh() async {
    if (!_validateForm()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    try {
      final tasbeehProvider = context.read<TasbeehProvider>();
      final name = _nameController.text.trim();
      final targetCount = _getTargetCount();

      bool success;
      if (widget.isEditing) {
        success = await tasbeehProvider.updateTasbeeh(
          id: widget.tasbeeh!.id,
          name: name,
          targetCount: targetCount,
        );
      } else {
        success = await tasbeehProvider.createTasbeeh(
          name: name,
          targetCount: targetCount,
        );
      }

      if (success && mounted) {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      } else if (mounted) {
        HapticFeedback.heavyImpact();
        // Error is already set in the provider
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
