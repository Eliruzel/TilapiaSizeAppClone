import 'package:flutter/material.dart';

import '../../theme/web_colors.dart';
import '../services/image_picker.dart';
import '../services/image_selection.dart';

class WebUploadDialog extends StatefulWidget {
  const WebUploadDialog({super.key});

  @override
  State<WebUploadDialog> createState() => _WebUploadDialogState();
}

class _WebUploadDialogState extends State<WebUploadDialog> {
  PickedWebImage? _image;
  bool _picking = false;

  Future<void> _chooseImage() async {
    setState(() => _picking = true);
    final picked = await pickWebImage();
    if (!mounted) return;
    setState(() {
      _image = picked ?? _image;
      _picking = false;
    });
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: WebColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Upload image',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: WebColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_image == null)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: WebColors.accent,
                      size: 42,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Choose a tilapia image from your computer',
                      style: TextStyle(color: WebColors.muted),
                    ),
                  ],
                ),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Image.memory(_image!.bytes, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _image!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: WebColors.muted, fontSize: 13),
              ),
            ],
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _picking ? null : _chooseImage,
              icon: _picking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_upload_outlined),
              label: Text(_image == null ? 'Choose image' : 'Choose another'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: WebColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyze image'),
              style: FilledButton.styleFrom(
                backgroundColor: WebColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Image analysis will be available when the grading model is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(color: WebColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
