// screens/image_selection_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../providers/puzzle_provider.dart';
import '../models/game_mode.dart';
import 'game_screen.dart';

const List<String> kPreloadedImages = [
  'assets/images/preloaded1.jpg',
  'assets/images/preloaded2.jpg',
  'assets/images/preloaded3.jpg',
  'assets/images/preloaded4.jpg',
  'assets/images/preloaded5.jpg',
  'assets/images/preloaded6.jpg',
];

class ImageSelectionScreen extends StatelessWidget {
  const ImageSelectionScreen({Key? key}) : super(key: key);

  Future<void> _pickAndCrop(ImageSource source, BuildContext ctx) async {
    final picker = ImagePicker();
    final provider = Provider.of<PuzzleProvider>(ctx, listen: false);

    final XFile? picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Recortar imagen'),
        IOSUiSettings(title: 'Recortar imagen'),
      ],
    );
    if (cropped == null) return;

    provider.initialize(
      GameMode.image,
      provider.difficulty,
      imageFile: File(cropped.path),
    );
    Navigator.pushReplacementNamed(ctx, GameScreen.routeName);
  }

  void _startWithAsset(BuildContext ctx, String asset) {
    final provider = Provider.of<PuzzleProvider>(ctx, listen: false);
    provider.initialize(GameMode.image, provider.difficulty, imageAsset: asset);
    Navigator.pushReplacementNamed(ctx, GameScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige imagen'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: kPreloadedImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (ctx, i) {
                  final img = kPreloadedImages[i];
                  return GestureDetector(
                    onTap: () => _startWithAsset(context, img),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(img, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          ),

          // Nuevo botón para cámara
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                'Tomar foto con cámara',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _pickAndCrop(ImageSource.camera, context),
            ),
          ),
        ],
      ),
    );
  }
}
