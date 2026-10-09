import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';

/// Labeled text field, CRED-style (uppercase label above an inset input).
class NeuTextField extends StatelessWidget {
  const NeuTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.keyboardType,
    this.validator,
    this.autofocus = false,
    this.inputFormatters,
    this.onSubmitted,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.label.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: autofocus,
          validator: validator,
          inputFormatters: inputFormatters,
          onFieldSubmitted: onSubmitted,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppText.body.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, color: c.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }
}
