import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/plant.dart';
import '../services/database_helper.dart';

class EditPlantPage extends StatefulWidget {
  final CollectionPlant item;
  const EditPlantPage({super.key, required this.item});
  @override
  State<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.item.plant.name);
  late final room = TextEditingController(text: widget.item.room);
  late final interval = TextEditingController(
    text: '${widget.item.plant.wateringDays}',
  );
  late final id = widget.item.id!;
  XFile? photo;
  bool busy = false;
  String? error;
  String? savedPhoto;

  @override
  void dispose() {
    name.dispose();
    room.dispose();
    interval.dispose();
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
          savedPhoto = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Unable to open the photo gallery.');
    }
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final databaseHelper = DatabaseHelper.instance;
      String? image = widget.item.plant.image;
      if (photo != null) {
        if (savedPhoto == null) {
          final bytes = await photo!.readAsBytes();
          if (bytes.length > 5 * 1024 * 1024) {
            throw Exception('Photo is too large');
          }
          savedPhoto = await databaseHelper.savePhoto(const Uuid().v4(), bytes);
        }
        image = savedPhoto;
      }
      final old = widget.item.plant;
      final plant = Plant(
        id: old.id,
        name: name.text.trim(),
        botanicalName: old.botanicalName,
        image: image,
        light: old.light,
        wateringDays: int.parse(interval.text),
        temperature: old.temperature,
        description: old.description,
        tip: old.tip,
        photoReference: image == old.image ? old.photoReference : '',
      );
      await databaseHelper.savePlant(id, plant, room.text.trim());
      if (!mounted) return;
      widget.item.plant = plant;
      widget.item.room = room.text.trim();
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Unable to save. Check device storage and use a JPEG or PNG photo up to 5 MB, then try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Edit plant')),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: name,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Plant name'),
              validator: (value) =>
                  value!.trim().isEmpty ? 'Enter a plant name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: room,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Room'),
              validator: (value) =>
                  value!.trim().isEmpty ? 'Enter a room' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: interval,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Watering interval (days)',
              ),
              validator: (value) {
                final days = int.tryParse(value ?? '');
                return days == null || days < 1 || days > 365
                    ? 'Enter a number from 1 to 365'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: busy ? null : pickPhoto,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                photo == null
                    ? 'Choose a personal photo (optional)'
                    : 'Photo selected',
              ),
            ),
            if (error != null) Text(error!),
            FilledButton(
              onPressed: busy ? null : save,
              child: Text(busy ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    ),
  );
}
