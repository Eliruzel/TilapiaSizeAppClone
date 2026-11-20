
import 'dart:ui';
import 'package:flutter/material.dart';

const _termsNavy = Color(0xFF102B76);
const _termsHeaderNavy = Color(0xFF071A4D);
const _termsPanelNavy = Color(0xFF0B246C);
const _termsAccent = Color(0xFF9BE2DF);
const _termsBodyText = Color(0xFFE2EBFF);

// Opens the Terms and Conditions window.
Future<void> showTermsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Dialog(
          backgroundColor: _termsNavy,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: const Color(0xFF5876B5),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight:
                  MediaQuery.sizeOf(dialogContext).height * 0.80,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button.
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Original TilapiaSize logo.
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 115,
                    height: 75,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Terms and Conditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Scrollable terms.
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _termsPanelNavy,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF3C619E),
                        ),
                      ),
                      child: const SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _TermsSection(
                              title: '1. Acceptance of Terms',
                              description:
                                  'By using TilapiaSize, you agree '
                                  'to these Terms and Conditions.',
                            ),

                            _TermsSection(
                              title: '2. Use of Application',
                              description:
                                  'TilapiaSize is designed to assist '
                                  'with tilapia size grading using '
                                  'image-based machine learning.',
                            ),

                            _TermsSection(
                              title: '3. User Accounts',
                              description:
                                  'Users are responsible for keeping '
                                  'their account information and '
                                  'passwords secure.',
                            ),

                            _TermsSection(
                              title: '4. Image Uploads',
                              description:
                                  'Users must have permission to use '
                                  'the images they upload.',
                            ),

                            _TermsSection(
                              title: '5. Grading Results',
                              description:
                                  'Grading results are predictions '
                                  'and may not always be accurate.',
                            ),

                            _TermsSection(
                              title: '6. Updates',
                              description:
                                  'These terms may change as '
                                  'TilapiaSize is developed.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Button to close the window.
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _termsAccent,
                        foregroundColor: _termsHeaderNavy,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// A reusable section inside the Terms window.
class _TermsSection extends StatelessWidget {
  final String title;
  final String description;

  const _TermsSection({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _termsAccent,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            style: const TextStyle(
              color: _termsBodyText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
