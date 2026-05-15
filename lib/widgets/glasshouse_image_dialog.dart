import 'package:flutter/material.dart';

import '../utils/screen_adapter.dart';

class GlasshouseImageDialog extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const GlasshouseImageDialog({super.key, required this.imageUrl, this.onTap});

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    VoidCallback? onTap,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => GlasshouseImageDialog(imageUrl: imageUrl, onTap: onTap),
    );
  }

  @override
  State<GlasshouseImageDialog> createState() => _GlasshouseImageDialogState();
}

class _GlasshouseImageDialogState extends State<GlasshouseImageDialog> {
  double? _ratio;

  @override
  void initState() {
    super.initState();
    _resolveImageSize();
  }

  void _resolveImageSize() {
    final image = NetworkImage(widget.imageUrl);
    final stream = image.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener((info, _) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (w > 0 && h > 0) {
          setState(() => _ratio = h / w);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final ratio = _ratio ?? (413 / 327);
          final height = width * ratio;
          final image = GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              widget.onTap?.call();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                widget.imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: width,
                  height: height,
                  color: const Color(0xFFE6DAFF),
                ),
              ),
            ),
          );

          if (height <= constraints.maxHeight) {
            return image;
          }
          return SingleChildScrollView(child: image);
        },
      ),
    );
  }
}
