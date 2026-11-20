import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A short, one-time entrance that also honours reduced-motion preferences.
class PageEntrance extends StatefulWidget { 
  const PageEntrance({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 120),
    this.distance = 16,
    this.blur = 0,
    this.showLogoLoader = false,
    this.loaderColor = AppColors.mint,
    this.loaderBackgroundColor = AppColors.background,
  });

  final Widget child;
  final Duration delay;
  final double distance;
  final double blur;
  final bool showLogoLoader;
  final Color loaderColor;
  final Color loaderBackgroundColor;

  @override
  State<PageEntrance> createState() => _PageEntranceState();
}

class _PageEntranceState extends State<PageEntrance>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  bool _started = false;
  Timer? _startTimer;

  void _startAfterPaint() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startTimer?.cancel();
      // Let the first frame become visible before the entrance begins.
      _startTimer = Timer(widget.delay, () {
        if (!mounted) return;
        if (MediaQuery.disableAnimationsOf(context)) {
          _controller.value = 1;
        } else {
          _controller.forward();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _startTimer?.cancel();
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _startAfterPaint();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Replay during development so hot reload can preview the entrance too.
    _startTimer?.cancel();
    if (!MediaQuery.disableAnimationsOf(context)) {
      _controller.reset();
      _startAfterPaint();
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    if (!widget.showLogoLoader) {
      return SmoothPageTransition(
        animation: _controller,
        distance: widget.distance,
        blur: widget.blur,
        child: widget.child,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final progress = const Interval(
          0.4,
          1,
          curve: Curves.easeOutCubic,
        ).transform(_controller.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              ignoring: progress < 1,
              child: ExcludeSemantics(
                excluding: progress < 1,
                child: Opacity(opacity: progress, child: child),
              ),
            ),
            if (progress < 1)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 1 - progress,
                    child: ColoredBox(
                      color: widget.loaderBackgroundColor,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/app_icon.png',
                              width: 120,
                              height: 100,
                              excludeFromSemantics: true,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: widget.loaderColor,
                                semanticsLabel: 'Opening page',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class SmoothPageTransition extends StatelessWidget {
  const SmoothPageTransition({
    super.key,
    required this.animation,
    required this.child,
    this.distance = 16,
    this.blur = 0,
  });

  final Animation<double> animation;
  final Widget child;
  final double distance;
  final double blur;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(animation.value);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, distance * (1 - progress)),
            child: ImageFiltered(
              enabled: blur > 0 && progress < 1,
              imageFilter: ImageFilter.blur(
                sigmaX: blur * (1 - progress),
                sigmaY: blur * (1 - progress),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
