import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AuthTermsCheckbox extends StatelessWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const AuthTermsCheckbox({
    super.key,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: initialValue,
      validator: (value) =>
          value == true ? null : 'Debes aceptar los términos y condiciones',
      builder: (state) {
        void update(bool? value) {
          final checked = value ?? false;
          state.didChange(checked);
          onChanged?.call(checked);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 26,
                  width: 26,
                  child: Checkbox(
                    value: state.value ?? false,
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    onChanged: update,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => update(!(state.value ?? false)),
                    child: Text.rich(
                      TextSpan(
                        text: 'Acepto los ',
                        children: [
                          TextSpan(
                            text: 'términos y condiciones',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' *'),
                        ],
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 4),
                child: Text(
                  state.errorText ?? '',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.rejected),
                ),
              ),
          ],
        );
      },
    );
  }
}
