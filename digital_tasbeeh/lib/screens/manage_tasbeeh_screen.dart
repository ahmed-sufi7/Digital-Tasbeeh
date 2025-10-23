import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/tasbeeh.dart';
import '../providers/tasbeeh_provider.dart';
import '../providers/counter_provider.dart';
import '../widgets/tasbeeh_form_modal.dart';

class ManageTasbeehScreen extends StatefulWidget {
  const ManageTasbeehScreen({super.key});

  @override
  State<ManageTasbeehScreen> createState() => _ManageTasbeehScreenState();
}

class _ManageTasbeehScreenState extends State<ManageTasbeehScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundColor(isDark),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceColor(isDark).withOpacity(0.9),
        border: null,
        leading: Transform.translate(
          offset: const Offset(-8, 0),
          child: CupertinoButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => Navigator.pop(context),
            child: Icon(
              CupertinoIcons.back,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
        middle: Text(
          'Manage Tasbeehs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor(isDark),
            fontFamily: AppTextStyles.fontFamily,
            letterSpacing: -0.4,
          ),
        ),
        trailing: Transform.translate(
          offset: const Offset(8, 0),
          child: CupertinoButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => _showCreateTasbeehModal(context),
            child: Icon(CupertinoIcons.add, color: AppColors.primary, size: 28),
          ),
        ),
      ),
      child: SafeArea(
        child: Consumer<TasbeehProvider>(
          builder: (context, tasbeehProvider, child) {
            if (tasbeehProvider.isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 16),
              );
            }

            if (tasbeehProvider.error != null) {
              return _buildErrorState(context, tasbeehProvider.error!);
            }

            final filteredTasbeehs = _searchQuery.isEmpty
                ? tasbeehProvider.tasbeehs
                : tasbeehProvider.searchTasbeehs(_searchQuery);

            return Column(
              children: [
                // Search Bar
                _buildSearchBar(context, isDark),

                // Tasbeehs List
                Expanded(
                  child: filteredTasbeehs.isEmpty
                      ? _buildEmptyState(context, isDark)
                      : _buildTasbeehsList(context, filteredTasbeehs, isDark),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoTextField(
        controller: _searchController,
        placeholder: 'Search Tasbeehs...',
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
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            CupertinoIcons.search,
            color: AppColors.textSecondaryColor(isDark),
            size: 20,
          ),
        ),
        suffix: _searchQuery.isNotEmpty
            ? CupertinoButton(
                padding: const EdgeInsets.only(right: 16),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Icon(
                  CupertinoIcons.clear_circled_solid,
                  color: AppColors.textSecondaryColor(isDark),
                  size: 20,
                ),
              )
            : null,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildTasbeehsList(
    BuildContext context,
    List<Tasbeeh> tasbeehs,
    bool isDark,
  ) {
    // Group Tasbeehs by type
    final defaultTasbeehs = tasbeehs.where((t) => t.isDefault).toList();
    final customTasbeehs = tasbeehs.where((t) => !t.isDefault).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Default Tasbeehs Section
        if (defaultTasbeehs.isNotEmpty) ...[
          _buildSectionHeader('Default Tasbeehs', isDark),
          const SizedBox(height: 8),
          ...defaultTasbeehs.map(
            (tasbeeh) => _buildTasbeehItem(context, tasbeeh, isDark),
          ),
          const SizedBox(height: 24),
        ],

        // Custom Tasbeehs Section
        if (customTasbeehs.isNotEmpty) ...[
          _buildSectionHeader('Custom Tasbeehs', isDark),
          const SizedBox(height: 8),
          ...customTasbeehs.map(
            (tasbeeh) => _buildTasbeehItem(context, tasbeeh, isDark),
          ),
        ],

        // Bottom padding
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
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

  Widget _buildTasbeehItem(BuildContext context, Tasbeeh tasbeeh, bool isDark) {
    return Consumer2<TasbeehProvider, CounterProvider>(
      builder: (context, tasbeehProvider, counterProvider, child) {
        final isSelected = counterProvider.currentTasbeeh?.id == tasbeeh.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _selectTasbeeh(context, tasbeeh),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Leading Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTasbeehIcon(tasbeeh),
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.7),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tasbeeh Name
                        Text(
                          tasbeeh.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimaryColor(isDark),
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Target Count
                        Text(
                          tasbeeh.isUnlimited
                              ? 'Unlimited'
                              : '${tasbeeh.targetCount} counts',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryColor(isDark),
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Trailing Elements
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current Count Badge
                      if (tasbeeh.currentCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${tasbeeh.currentCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                        ),

                      const SizedBox(width: 8),

                      // Selection Checkmark
                      AnimatedScale(
                        scale: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),

                      // More Options
                      CupertinoButton(
                        padding: const EdgeInsets.only(left: 8),
                        onPressed: () => _showTasbeehOptions(context, tasbeeh),
                        child: Icon(
                          CupertinoIcons.ellipsis,
                          color: AppColors.textSecondaryColor(isDark),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.book,
            size: 64,
            color: AppColors.textSecondaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No Tasbeehs Found' : 'No Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor(isDark),
              fontFamily: AppTextStyles.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Create your first Tasbeeh to get started'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryColor(isDark),
              fontFamily: AppTextStyles.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () => _showCreateTasbeehModal(context),
              child: const Text('Create Tasbeeh'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemRed,
              fontFamily: AppTextStyles.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemRed,
              fontFamily: AppTextStyles.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () {
              context.read<TasbeehProvider>().clearError();
              context.read<TasbeehProvider>().loadTasbeehs();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  IconData _getTasbeehIcon(Tasbeeh tasbeeh) {
    // Return appropriate icons for different Tasbeehs
    if (tasbeeh.isDefault) {
      switch (tasbeeh.name.toLowerCase()) {
        case 'sallallahu alayhi wasallam':
          return CupertinoIcons.star_fill;
        case 'subhanallah':
          return CupertinoIcons.moon_stars_fill;
        case 'allahu akbar':
          return CupertinoIcons.sun_max_fill;
        case 'alhamdulillah':
          return CupertinoIcons.heart_fill;
        case 'la ilaha illa allah':
          return CupertinoIcons.sparkles;
        default:
          return CupertinoIcons.book_fill;
      }
    }
    return CupertinoIcons.book;
  }

  void _selectTasbeeh(BuildContext context, Tasbeeh tasbeeh) {
    HapticFeedback.lightImpact();

    // Update both providers
    context.read<TasbeehProvider>().selectTasbeeh(tasbeeh);
    context.read<CounterProvider>().switchTasbeeh(tasbeeh.id);
  }

  void _showCreateTasbeehModal(BuildContext context) {
    HapticFeedback.lightImpact();

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => const TasbeehFormModal(),
    );
  }

  void _showTasbeehOptions(BuildContext context, Tasbeeh tasbeeh) {
    HapticFeedback.lightImpact();

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(tasbeeh.name, style: const TextStyle(fontSize: 16)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showEditTasbeehModal(context, tasbeeh);
            },
            child: const Text('Edit'),
          ),
          if (!tasbeeh.isDefault)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, tasbeeh);
              },
              child: const Text('Delete'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showEditTasbeehModal(BuildContext context, Tasbeeh tasbeeh) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => TasbeehFormModal(tasbeeh: tasbeeh),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Tasbeeh tasbeeh) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete Tasbeeh'),
        content: Text(
          'Are you sure you want to delete "${tasbeeh.name}"? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteTasbeeh(context, tasbeeh);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTasbeeh(BuildContext context, Tasbeeh tasbeeh) async {
    HapticFeedback.mediumImpact();

    final success = await context.read<TasbeehProvider>().deleteTasbeeh(
      tasbeeh.id,
    );

    if (success && mounted) {
      // Show success feedback
      HapticFeedback.lightImpact();
    } else if (mounted) {
      // Show error if deletion failed
      HapticFeedback.heavyImpact();
    }
  }
}
