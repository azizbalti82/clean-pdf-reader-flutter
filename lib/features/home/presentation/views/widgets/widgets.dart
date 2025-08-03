import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toastification/toastification.dart';

class newLevelWelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? iconPath;
  final double? iconSize;
  final Color? color;
  final BuildContext context;

  newLevelWelcomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.context,
    this.iconPath,
    this.iconSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color errorColor = Theme.of(context).colorScheme.error;

    final Color primaryColor = color ?? Theme.of(context).colorScheme.primary;
    final TextStyle subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
    ) ?? const TextStyle(fontSize: 13);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.5))
      ),
      child:  Row(
        children: [
          if (iconPath != null)
            const SizedBox(width: 10),
          if (iconPath != null)
            SvgPicture.asset(
              "assets/icons/$iconPath.svg",
              width: iconSize ?? 30,
              color: primaryColor,
            ),
          if (iconPath != null)
            const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: subtitleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}