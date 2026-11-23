import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/plant.dart';
import '../services/database_helper.dart';
import '../widgets/plant_widgets.dart';

class EditPlantPage extends StatefulWidget {
  final CollectionPlant item;
  const EditPlantPage({super.key, required this.item});
  @override
  State<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
  final formKey = GlobalKey<FormState>();
  late final nameController = TextEditingController(
    text: widget.item.plant.name,
  );
  late final roomController = TextEditingController(text: widget.item.room);
  late final intervalController = TextEditingController(
    text: '${widget.item.plant.wateringDays}',
  );
  late final id = widget.item.id!;
  XFile? photo;
  bool isBusy = false;
  String? error;
  String? savedPhotoReference;
  bool useDefaultPhoto = false;
  Plant? dictionaryPlant;

  Future<void> restoreDefaultPhoto() async {
    if (isBusy) return;
    setState(() {
      isBusy = true;
      error = null;
    });
    try {
      final catalogId = widget.item.plant.id;
      Plant? source;
      if (catalogId != null) {
        source = await DatabaseHelper.instance.detail(
          catalogId,
          includeArchived: true,
        );
      }
      if (!mounted) return;
      setState(() {
        dictionaryPlant = source;
        useDefaultPhoto = true;
        photo = null;
        savedPhotoReference = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Unable to load the default photo. Try again.');
      }
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    roomController.dispose();
    intervalController.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (mounted && file != null) {
        setState(() {
          photo = file;
          savedPhotoReference = null;
          useDefaultPhoto = false;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Unable to open the photo gallery.');
    }
  }

  Future<void> save() async {
    if (isBusy || !formKey.currentState!.validate()) return;
    setState(() {
      isBusy = true;
      error = null;
    });
    try {
      final databaseHelper = DatabaseHelper.instance;
      String? image = useDefaultPhoto
          ? dictionaryPlant?.image
          : widget.item.plant.image;
      if (photo != null) {
        if (savedPhotoReference == null) {
          final bytes = await photo!.readAsBytes();
          if (bytes.length > DatabaseHelper.maxPhotoBytes) {
            throw Exception('Photo is too large');
          }
          savedPhotoReference = await databaseHelper.savePhoto(
            const Uuid().v4(),
            bytes,
          );
        }
        image = savedPhotoReference;
      }
      final old = widget.item.plant;
      String photoReference = '';
      if (useDefaultPhoto) {
        photoReference = dictionaryPlant?.photoReference ?? '';
      } else if (image == old.image) {
        photoReference = old.photoReference;
      }
      final plant = Plant(
        id: old.id,
        name: nameController.text.trim(),
        botanicalName: old.botanicalName,
        image: image,
        light: old.light,
        wateringDays: int.parse(intervalController.text),
        temperature: old.temperature,
        description: old.description,
        tip: old.tip,
        fullDescription: old.fullDescription,
        reference: old.reference,
        wateringKnown: old.wateringKnown,
        photoReference: photoReference,
      );
      await databaseHelper.savePlant(id, plant, roomController.text.trim());
      if (!mounted) return;
      widget.item.plant = plant;
      widget.item.room = roomController.text.trim();
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Unable to save. Check device storage and use a JPEG or PNG photo up to 5 MB, then try again.',
        );
      }
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  Widget buildPhotoPreview() {
    final selectedPhoto = photo;
    if (selectedPhoto != null) {
      return Image.file(
        File(selectedPhoto.path),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        semanticLabel: 'Selected plant photo',
        errorBuilder: (_, error, stack) => const SizedBox(
          height: 180,
          child: Center(child: Text('Unable to preview photo')),
        ),
      );
    }

    Plant previewPlant = widget.item.plant;
    if (useDefaultPhoto) {
      // Koleksi lama tanpa entri Dictionary kembali ke ilustrasi bawaan.
      previewPlant =
          dictionaryPlant ?? Plant.fromJson({'name': nameController.text});
    }
    return PlantPhoto(plant: previewPlant, height: 180);
  }

  @override
  Widget build(BuildContext context) {
    final hasPersonalPhoto =
        widget.item.plant.image?.startsWith('local:') ?? false;
    final canRestorePhoto =
        !useDefaultPhoto && (photo != null || hasPersonalPhoto);

    return PopScope(
      canPop: !isBusy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit plant')),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: nameController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Plant name',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a plant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: roomController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Room',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a room';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Watering interval (days)',
                ),
                validator: (value) {
                  final days = int.tryParse(value ?? '');
                  if (days == null || days < 1 || days > 365) {
                    return 'Enter a number from 1 to 365';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: buildPhotoPreview(),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: isBusy ? null : pickPhoto,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  photo == null
                      ? 'Choose a personal photo (optional)'
                      : 'Photo selected',
                ),
              ),
              if (canRestorePhoto)
                TextButton.icon(
                  onPressed: isBusy ? null : restoreDefaultPhoto,
                  icon: const Icon(Icons.restore),
                  label: const Text('Use default photo'),
                ),
              if (useDefaultPhoto) ...[
                const SizedBox(height: 8),
                const Text('Default photo selected. Tap Save to apply.'),
              ],
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: isBusy ? null : save,
                label: isBusy ? 'Saving...' : 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
