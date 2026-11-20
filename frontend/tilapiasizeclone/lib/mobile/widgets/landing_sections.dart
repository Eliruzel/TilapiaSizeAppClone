import 'package:flutter/material.dart';


class LandingSections {
  static const _mobileMint = Color(0xFF9BE2DF);
  static const _mobileCard = Color(0xFF142F73);
  static const _mobileCardBorder = Color(0xFF3C619E);
  static const _mobileMuted = Color(0xFFD4DFF6);

  static Widget primaryButton(
    String title,
    VoidCallback onPressed, {
    bool fullWidth = false,
    bool mobile = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: mobile ? 52 : 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _mobileMint,
          foregroundColor: const Color(0xFF071A4D),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          shape: const StadiumBorder(),
        ),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Hero section at the top of the landing page.
  static Widget hero({
    required bool wide,
    required VoidCallback onStart,
    required VoidCallback onHow,
  }) {
    if (!wide) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 138, 20, 46),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              const TextSpan(children: [
                TextSpan(text: 'Measure '),
                TextSpan(
                  text: 'Smarter.\n',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                TextSpan(text: 'Grade '),
                TextSpan(
                  text: 'Better.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ]),
              style: const TextStyle(
                color: _mobileMint,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                height: 1.14,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'TilapiaSize is a grading application that supports efficient and consistent aquaculture operations.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.55),
            ),
            const SizedBox(height: 28),
            primaryButton('Get Started', onStart, fullWidth: true, mobile: true),
            const SizedBox(height: 12),
            _outlineButton('How It Works', onHow, fullWidth: true, mobile: true),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 470),
      padding: EdgeInsets.fromLTRB(
        wide ? 48 : 24,
        125,
        wide ? 48 : 24,
        45,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 530),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main headline.
                  Text.rich(
                    TextSpan(
                      children: const [
                        TextSpan(text: 'Measure '),
                        TextSpan(
                          text: 'Smarter.\n',
                          style: TextStyle(
                            color: _mobileMint,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(text: 'Grade '),
                        TextSpan(
                          text: 'Better.',
                          style: TextStyle(
                          color: _mobileMint,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: wide ? 48 : 34,
                      fontWeight: FontWeight.bold,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'TilapiaSize is a grading application that '
                    'supports efficient and consistent '
                    'aquaculture operations.',
                    style: TextStyle(
                      color: _mobileMuted,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Full-width buttons on mobile.
                  if (wide)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        primaryButton('Get Started', onStart),
                        _outlineButton('How It Works', onHow),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        primaryButton(
                          'Get Started',
                          onStart,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        _outlineButton(
                          'How It Works',
                          onHow,
                          fullWidth: true,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // About section without an extra image.
  static Widget about({required bool wide}) {
    if (!wide) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 38),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ABOUT TILAPIASIZE',
              style: TextStyle(
                color: _mobileMint,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A Smarter Approach to Fish Grading',
              style: TextStyle(color: Colors.white, fontSize: 28, height: 1.2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            const Text(
              'TilapiaSize helps aquaculture practitioners quickly classify tilapia into size grades using a simple image input, providing consistent and useful results.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.55),
            ),
            const SizedBox(height: 24),
            _mobileFeatureCard(Icons.track_changes_outlined, 'Accurate', 'Consistent size grading.'),
            const SizedBox(height: 12),
            _mobileFeatureCard(Icons.bolt_outlined, 'Efficient', 'Quick and easy to use.'),
            const SizedBox(height: 12),
            _mobileFeatureCard(Icons.eco_outlined, 'Practical', 'Designed for aquaculture needs.'),
          ],
        ),
      );
    }

    final description = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'ABOUT TILAPIASIZE',
          style: TextStyle(
            color: _mobileMint,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'A Smarter Approach to Fish Grading',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'TilapiaSize helps aquaculture practitioners '
          'quickly classify tilapia into size grades '
          'using a simple image input, providing '
          'consistent and useful results.',
          style: TextStyle(
            color: _mobileMuted,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ],
    );

    final features = Column(
      children: [
        _featureCard(
          Icons.track_changes_outlined,
          'Accurate',
          'Consistent size grading.',
        ),
        const SizedBox(height: 10),
        _featureCard(
          Icons.bolt_outlined,
          'Efficient',
          'Quick and easy to use.',
        ),
        const SizedBox(height: 10),
        _featureCard(
          Icons.eco_outlined,
          'Practical',
          'Designed for aquaculture needs.',
        ),
      ],
    );

    return _section(
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: description),
                const SizedBox(width: 45),
                Expanded(child: features),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description,
                const SizedBox(height: 24),
                features,
              ],
            ),
    );
  }

  // Four steps describing how to use TilapiaSize.
  static Widget howItWorks({bool mobile = false}) {
    const steps = [
      (
        Icons.camera_alt_outlined,
        '01 Ready Your Camera',
        'Ensure your camera is clean, properly positioned, '
            'and ready to capture a clear image of the tilapia.',
      ),
      (
        Icons.layers_outlined,
        '02 Find a Flat Surface',
        'Place the tilapia on a clean, flat surface '
            'with good lighting so its full body is visible.',
      ),
      (
        Icons.add_photo_alternate_outlined,
        '03 Start Live / Upload',
        'Take a photo, start live grading, or upload '
            'an existing image to begin size classification.',
      ),
      (
        Icons.save_outlined,
        '04 Save Your Work',
        'Save the predicted size grade and results '
            'to your account for future reference and tracking.',
      ),
    ];

    if (mobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 34, 20, 34),
        child: Column(
          children: [
            const Text(
              'HOW IT WORKS',
              style: TextStyle(color: _mobileMint, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Grade Your Tilapia in 4 Simple Steps',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 27, height: 1.2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            for (var i = 0; i < steps.length; i++) ...[
              _mobileStepCard(steps[i].$1, steps[i].$2, steps[i].$3),
              if (i != steps.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      );
    }

    return _section(
      child: Column(
        children: [
          const Text(
            'HOW IT WORKS',
            style: TextStyle(
              color: _mobileMint,
              letterSpacing: 2,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Grade Your Tilapia in 4 Simple Steps',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),

          // Responsive card layout.
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final columns = width >= 950
                  ? 4
                  : width >= 560
                      ? 2
                      : 1;

              const gap = 14.0;
              final cardWidth =
                  (width - (columns - 1) * gap) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final step in steps)
                    SizedBox(
                      width: cardWidth,
                      child: _stepCard(
                        step.$1,
                        step.$2,
                        step.$3,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Final call-to-action banner.
  static Widget callToAction(VoidCallback onStart, {VoidCallback? onLogin, bool mobile = false}) {
    if (mobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
          decoration: BoxDecoration(
            color: _mobileCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _mobileCardBorder),
          ),
          child: Column(
            children: [
              const Text(
                'Ready to Grade Your Tilapia?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 25, height: 1.2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 22),
              primaryButton('Get Started', onStart, fullWidth: true, mobile: true),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onLogin ?? onStart,
                child: const Text.rich(
                  TextSpan(children: [
                    TextSpan(text: 'Already have an account? ', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'Login', style: TextStyle(color: _mobileMint, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                  ]),
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _section(
      child: _landingPanel(
        radius: 30,
        padding: const EdgeInsets.all(26),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 570;

            if (narrow) {
              return Column(
                children: [
                  const Text(
                    'Ready to Grade Your Tilapia?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  primaryButton(
                    'Get Started',
                    onStart,
                    fullWidth: true,
                    mobile: true,
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: onLogin ?? onStart,
                    child: const Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: _mobileMint,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ready to Grade Your Tilapia?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                primaryButton('Get Started', onStart),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onLogin ?? onStart,
                  child: const Text.rich(
                    TextSpan(children: [
                      TextSpan(text: 'Already have an account? ', style: TextStyle(color: Colors.white)),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: _mobileMint,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Footer with the original logo and Terms link.
  static Widget footer(VoidCallback onTerms, {bool mobile = false}) {
    if (mobile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: const Color(0xFF071A4D),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/app_icon.png', width: 58, height: 48, fit: BoxFit.contain),
            TextButton(
              onPressed: onTerms,
              child: const Text(
                'Terms and Conditions',
                style: TextStyle(color: _mobileMint, fontSize: 14, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
                color: const Color(0xFF071A4D),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 18,
        runSpacing: 12,
        children: [
          Image.asset(
            'assets/images/app_icon.png',
            width: 100,
            height: 90,
            fit: BoxFit.contain,
          ),
          TextButton(
            onPressed: onTerms,
            child: const Text(
              'Terms and Conditions',
              style: TextStyle(
                color: _mobileMint,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable About feature.
  static Widget _featureCard(
    IconData icon,
    String title,
    String description,
  ) {
    return _landingPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: _mobileMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _mobileFeatureCard(IconData icon, String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _mobileCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _mobileCardBorder),
      ),
      child: Row(
        children: [
          _mobileIconBox(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _mobileStepCard(IconData icon, String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _mobileCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _mobileCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mobileIconBox(icon),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  static Widget _mobileIconBox(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: const Color(0xFF315B9B), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: _mobileMint, size: 27),
    );
  }

  // Reusable How It Works card.
  static Widget _stepCard(
    IconData icon,
    String title,
    String description,
  ) {
    return _landingPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(icon),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: _mobileMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Green icon background.
  static Widget _iconBox(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF315B9B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: _mobileMint,
        size: 25,
      ),
    );
  }

  // Reusable outlined button.
  static Widget _outlineButton(
    String title,
    VoidCallback onPressed, {
    bool fullWidth = false,
    bool mobile = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: mobile ? 52 : 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: _mobileMint, width: 1.5),
          shape: const StadiumBorder(),
        ),
        child: Text(title),
      ),
    );
  }

  // Shared spacing for all page sections.
  static Widget _section({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: child,
        ),
      ),
    );
  }

  static Widget _landingPanel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 20,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _mobileCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _mobileCardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2604163D),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
