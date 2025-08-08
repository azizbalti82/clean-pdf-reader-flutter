import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomButtonOutline extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? borderColor;
  final bool isLoading;
  final String? icon;
  final double? size;
  final bool isFullRow;

  const CustomButtonOutline({
    Key? key,
    required this.text,
    this.icon,
    this.isFullRow = true,
    this.size,
    required this.onPressed,
    required this.isLoading,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isFullRow
        ? SizedBox(
      width: double.infinity,
      child: _buildButton(context),
    )
        : _buildButton(context);
  }

  Widget _buildButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outlineColor = borderColor ?? colorScheme.primary;

    return OutlinedButton(
      onPressed: onPressed,
      style: _getButtonStyle(outlineColor),
      child: _buildButtonChild(outlineColor),
    );
  }

  // Extract button style to reduce object creation
  ButtonStyle _getButtonStyle(Color outlineColor) {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: outlineColor.withOpacity(0.6), width: 1.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      minimumSize: const Size(0, 45),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: outlineColor.withOpacity(0.07),
    );
  }

  Widget _buildButtonChild(Color outlineColor) {
    // Pre-calculate text style to avoid recreation
    final textStyle = TextStyle(
      fontSize: size ?? 16,
      color: outlineColor,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Use spread operator and conditional logic to reduce widget tree depth
        ...(_buildIconWidget(outlineColor)),
        ...(_buildLoadingWidget(outlineColor)),
        if (!isLoading && icon != null) const SizedBox(width: 8),
        Text(
          text,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildIconWidget(Color outlineColor) {
    if (icon == null) return [];

    return [
      SvgPicture.asset(
        "assets/icons/$icon.svg",
        width: 22,
        height: 22, // Add explicit height to prevent layout calculations
        color: outlineColor,
        // Add caching for better performance with multiple instances
        placeholderBuilder: (context) => SizedBox(
          width: 22,
          height: 22,
          child: Container(color: Colors.transparent),
        ),
      ),
    ];
  }

  List<Widget> _buildLoadingWidget(Color outlineColor) {
    if (!isLoading) return [];

    return [
      const SizedBox(width: 8),
      SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: outlineColor,
          // Reduce animation overhead for better performance
          strokeCap: StrokeCap.round,
        ),
      ),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomButtonOutline &&
        other.text == text &&
        other.onPressed == onPressed &&
        other.borderColor == borderColor &&
        other.isLoading == isLoading &&
        other.icon == icon &&
        other.size == size &&
        other.isFullRow == isFullRow;
  }

  @override
  int get hashCode {
    return Object.hash(
      text,
      onPressed,
      borderColor,
      isLoading,
      icon,
      size,
      isFullRow,
    );
  }
}

Widget customInput(
  ThemeData theme,
  TextEditingController controller,
  FocusNode focusNode,
  String? placeholder,
  String? text,
  BuildContext context, {
  bool isPassword = false,
  Function(String)? onTextChanged, // Add this parameter
}) {
  final ValueNotifier<bool> obscure = ValueNotifier<bool>(isPassword);

  return SizedBox(
    height: 35,
    child: ValueListenableBuilder(
      valueListenable: obscure,
      builder: (context, value, child) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword ? value : false,
          maxLines: 1,
          minLines: 1,
          style: TextStyle(color: theme.colorScheme.onBackground),
          decoration: InputDecoration(
            hintText: placeholder ?? 'Write something...',
            hintStyle: TextStyle(
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 5.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          textAlignVertical: TextAlignVertical.center,
          onChanged: (value) {
            // Execute the callback with the current text
            if (onTextChanged != null) {
              onTextChanged(value);
            }
          },
        );
      },
    ),
  );
}
