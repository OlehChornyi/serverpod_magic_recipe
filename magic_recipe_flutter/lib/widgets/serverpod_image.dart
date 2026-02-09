import 'package:flutter/material.dart';
import 'package:magic_recipe_flutter/main.dart';

class ServerpodImage extends StatefulWidget {
  final String? imagePath;

  const ServerpodImage({super.key, required this.imagePath});

  @override
  State<ServerpodImage> createState() => _ServerpodImageState();
}

class _ServerpodImageState extends State<ServerpodImage> {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      fetchUrlAndRebuild();
    }
  }

  Future<void> fetchUrlAndRebuild() async {
    imageUrl = await client.recipes.getPublicUrlForPath(widget.imagePath!);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ServerpodImage oldWidget) {
    if (widget.imagePath != oldWidget.imagePath) {
      imageUrl = null;
      fetchUrlAndRebuild();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Image.network(
      imageUrl!,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
