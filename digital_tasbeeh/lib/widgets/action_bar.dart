import 'package:flutter/cupertino.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    // The ActionBar is now integrated into the CircularCounter widget
    // This widget is kept for backward compatibility but returns empty container
    return const SizedBox.shrink();
  }
}
