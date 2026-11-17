import 'package:flutter/material.dart';

/// Keeps navigation visible and gives the page the remaining viewport height.
class FarmerPageLayout extends StatelessWidget {
  const FarmerPageLayout({
    super.key,
    required this.header,
    required this.child,
  });

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final padding = compact ? 12.0 : 20.0;
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  SizedBox(height: compact ? 12 : 16),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, viewport) => SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: viewport.maxHeight),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
