import 'package:flutter/material.dart';

class AppPopupDialog extends StatelessWidget {
  const AppPopupDialog({
    required this.title,
    required this.message,
    this.primaryLabel,
    this.secondaryLabel,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    super.key,
  });

  final String title;
  final String message;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  bool get _hasActions {
    return (primaryLabel?.trim().isNotEmpty ?? false) ||
        (secondaryLabel?.trim().isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                if (_hasActions) ...[
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      if (secondaryLabel != null && secondaryLabel!.isNotEmpty)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onSecondaryPressed,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              secondaryLabel!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (secondaryLabel != null && secondaryLabel!.isNotEmpty)
                        const SizedBox(width: 12),
                      if (primaryLabel != null && primaryLabel!.isNotEmpty)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onPrimaryPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              primaryLabel!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: -60,
            right: 12,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF98A2B3),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
