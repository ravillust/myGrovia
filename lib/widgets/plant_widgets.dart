import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/plant.dart';

import '../services/database_helper.dart';

const plantGreen = Color(0xff2f7255);
const mutedText = Color(0xff626c65);
const neutralSurface = Color(0xfff1f0eb);
const warmBrown = Color(0xff856137);

class PlantPhoto extends StatelessWidget {
  final Plant plant;
  final double? height;
  const PlantPhoto({super.key, required this.plant, this.height});
  @override
  Widget build(BuildContext context) {
    final String? imagePath = plant.image;
    if (imagePath != null && imagePath.startsWith('local:')) {
      return FutureBuilder<Uint8List>(
        future: DatabaseHelper.instance.photo(imagePath.substring(6)),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: height,
              child: Center(
                child: Text(
                  snapshot.hasError ? 'Photo unavailable' : 'Loading photo...',
                ),
              ),
            );
          }
          return Image.memory(
            snapshot.data!,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            semanticLabel: plant.name,
            errorBuilder: (_, error, stack) => SizedBox(
              height: height,
              child: const Center(child: Text('Unable to open photo')),
            ),
          );
        },
      );
    }
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: const Alignment(0, 0.35),
        semanticLabel: plant.name,
        errorBuilder: (_, error, stack) => SizedBox(
          height: height,
          child: const Center(
            child: Icon(Icons.eco_outlined, size: 48, color: plantGreen),
          ),
        ),
      );
    }
    return Container(
      height: height,
      color: neutralSurface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/illustration/empty_collection_plant.svg',
              width: 70,
              height: 70,
            ),
            if ((height ?? 200) >= 150) const SizedBox(height: 8),
            if ((height ?? 200) >= 150)
              const Text(
                'Photo not available',
                style: TextStyle(color: mutedText, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class PageHeading extends StatelessWidget {
  final String title;
  final Widget? action;
  const PageHeading({super.key, required this.title, this.action});
  @override
  Widget build(BuildContext context) {
    final List<Widget> headingItems = [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    ];
    final Widget? actionButton = action;
    if (actionButton != null) {
      headingItems.add(actionButton);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Row(children: headingItems),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 20),
            if (icon != null) const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
