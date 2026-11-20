import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import '../../../theme/mobile_colors.dart';

/// Runs the trained Tilapia detector on the live mobile camera.
///
/// Put the exported model at assets/models/tilapia_detector.tflite before
/// running this screen. The .pt training checkpoint cannot be loaded directly
/// by Android.
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  static const modelPath = 'assets/models/tilapia_detector.tflite';

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final YOLOViewController _controller = YOLOViewController();
  Uint8List? _capturedBytes;
  String? _modelError;
  String? _detectionMessage;
  bool _modelLoaded = false;
  bool _capturing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onResults(List<YOLOResult> results) {
    if (!mounted) return;
    final tilapia = results
        .where((result) => result.className.toLowerCase() == 'tilapia')
        .toList(growable: false);
    final message = tilapia.isEmpty
        ? 'No tilapia detected'
        : '${tilapia.length} tilapia detected · ${(tilapia.first.confidence * 100).round()}% confidence';
    if (message != _detectionMessage) {
      setState(() => _detectionMessage = message);
    }
  }

  Future<void> _capture() async {
    if (!_modelLoaded || _capturing) return;
    setState(() => _capturing = true);
    try {
      final bytes = await _controller.capturePhoto(withOverlays: true);
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        _showMessage('Could not capture the camera frame. Try again.');
        return;
      }
      setState(() => _capturedBytes = bytes);
    } catch (_) {
      if (mounted) {
        _showMessage('Could not capture the camera frame. Try again.');
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final captured = _capturedBytes;
    return Scaffold(
      backgroundColor: MobileColors.background,
      appBar: AppBar(
        backgroundColor: MobileColors.background,
        foregroundColor: Colors.white,
        title: const Text('Live Tilapia Detection'),
        actions: [
          if (captured == null)
            IconButton(
              tooltip: 'Switch camera',
              onPressed: _modelLoaded ? _controller.switchCamera : null,
              icon: const Icon(Icons.flip_camera_android_outlined),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: ColoredBox(
                    color: const Color(0xFF020A20),
                    child: SizedBox.expand(
                      child: captured == null
                          ? _liveView()
                          : Image.memory(captured, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: captured == null ? _liveControls() : _reviewControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveView() => Stack(
    fit: StackFit.expand,
    children: [
      YOLOView(
        modelPath: CameraCaptureScreen.modelPath,
        task: YOLOTask.detect,
        controller: _controller,
        lensFacing: LensFacing.back,
        confidenceThreshold: .35,
        onResult: _onResults,
        onModelLoad: (_, task) {
          if (mounted) {
            setState(() {
              _modelLoaded = task == YOLOTask.detect;
              _modelError = null;
            });
          }
        },
        onModelError: (error, _, _) {
          if (mounted) {
            setState(() {
              _modelLoaded = false;
              _modelError = error.toString();
            });
          }
        },
      ),
      if (_modelError != null)
        Positioned.fill(
          child: ColoredBox(
            color: const Color(0xF0020A20),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.model_training_outlined,
                      color: MobileColors.accent,
                      size: 44,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tilapia model not ready',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Export your trained best.pt checkpoint to LiteRT (.tflite), then add it at:\nassets/models/tilapia_detector.tflite',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MobileColors.muted, height: 1.45),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _modelError!,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MobileColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      else if (_modelLoaded)
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xD9020A20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                _detectionMessage ?? 'Looking for tilapia…',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
    ],
  );

  Widget _liveControls() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        _modelLoaded
            ? 'Keep the whole fish visible and centered.'
            : 'Loading the local Tilapia detector…',
        textAlign: TextAlign.center,
        style: const TextStyle(color: MobileColors.muted),
      ),
      const SizedBox(height: 16),
      Semantics(
        button: true,
        label: 'Capture detected tilapia',
        child: InkWell(
          onTap: _modelLoaded && !_capturing ? _capture : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _modelLoaded ? MobileColors.accent : MobileColors.card,
              border: Border.all(color: Colors.white, width: 5),
            ),
            child: _capturing
                ? const Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.camera_alt,
                    color: MobileColors.background,
                    size: 30,
                  ),
          ),
        ),
      ),
    ],
  );

  Widget _reviewControls() => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => setState(() => _capturedBytes = null),
          icon: const Icon(Icons.refresh),
          label: const Text('Retake'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: MobileColors.accent),
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_capturedBytes),
          icon: const Icon(Icons.check),
          label: const Text('Use photo'),
          style: FilledButton.styleFrom(
            backgroundColor: MobileColors.accent,
            foregroundColor: MobileColors.background,
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ),
    ],
  );
}
