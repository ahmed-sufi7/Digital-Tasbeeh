import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// iOS-style header with blur effect and navigation elements
class IOSHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? trailing;
  final bool showBlur;
  final double height;

  const IOSHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.showBlur = false,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Container(
      height: height + statusBarHeight,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(isDark),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000),
            width: 0.5,
          ),
        ),
      ),
      child: _buildHeaderContent(context, isDark, statusBarHeight),
    );
  }

  Widget _buildHeaderContent(
    BuildContext context,
    bool isDark,
    double statusBarHeight,
  ) {
    const contentPadding = 12.0; // Equal top and bottom padding for content

    return Padding(
      padding: EdgeInsets.only(
        top: statusBarHeight + contentPadding,
        left: 16.0,
        right: 16.0,
        bottom: contentPadding,
      ),
      child: Row(
        children: [
          // Leading widget (back button, menu, etc.)
          if (leading != null)
            leading!
          else
            const SizedBox(width: 44), // Default spacing
          // Title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
                letterSpacing: -0.4,
              ),
            ),
          ),

          // Trailing widgets (buttons, icons, etc.)
          if (trailing != null && trailing!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: trailing!)
          else
            const SizedBox(width: 44), // Default spacing for balance
        ],
      ),
    );
  }
}

/// iOS-style header button
class IOSHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const IOSHeaderButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoButton(
      padding: const EdgeInsets.all(8.0),
      minimumSize: const Size(44.0, 44.0),
      onPressed: onPressed,
      child: Icon(
        icon,
        size: size,
        color: color ?? (isDark ? Colors.white : Colors.black),
      ),
    );
  }
}
