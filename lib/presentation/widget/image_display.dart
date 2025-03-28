import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final File? imageFile;

  const ImageDisplay({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return imageFile != null
        ? Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: FileImage(imageFile!),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          )
        : Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 100,
              color: Colors.white70,
            ),
          );
  }
}
