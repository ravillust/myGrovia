import 'package:flutter/material.dart';

import 'plant_widgets.dart';

class RoomSelectionSheet extends StatefulWidget {
  final String plantName;
  const RoomSelectionSheet({super.key, required this.plantName});

  @override
  State<RoomSelectionSheet> createState() {
    return _RoomSelectionSheetState();
  }
}

class _RoomSelectionSheetState extends State<RoomSelectionSheet> {
  String selectedRoom = '';
  final TextEditingController roomController = TextEditingController();
  String? roomError;

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  void confirmRoom() {
    if (selectedRoom.isEmpty) {
      return;
    }
    String room = selectedRoom;
    if (selectedRoom == 'Other room') {
      room = roomController.text.trim();
      if (room.isEmpty) {
        setState(() {
          roomError = 'Enter a room name';
        });
        return;
      }
    }
    // Kirim lokasi ke halaman detail yang menunggu hasil panel ini.
    Navigator.pop(context, room);
  }

  @override
  Widget build(BuildContext context) {
    VoidCallback? confirmAction;
    if (selectedRoom.isNotEmpty) {
      confirmAction = confirmRoom;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Where will your plant live?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close location selection',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.plantName, style: const TextStyle(color: mutedText)),
              const SizedBox(height: 24),
              roomOption('Living room', Icons.weekend_outlined),
              const Divider(height: 1),
              roomOption('Bedroom', Icons.bed_outlined),
              const Divider(height: 1),
              roomOption('Home office', Icons.desk_outlined),
              const Divider(height: 1),
              roomOption('Other room', Icons.edit_location_alt_outlined),
              if (selectedRoom == 'Other room')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    controller: roomController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    maxLength: 40,
                    decoration: InputDecoration(
                      errorText: roomError,
                      labelText: 'Room name',
                      hintText: 'e.g. Balcony',
                      errorMaxLines: 2,
                    ),
                    onChanged: (String text) {
                      if (roomError != null) {
                        setState(() {
                          roomError = null;
                        });
                      }
                    },
                    onFieldSubmitted: (String text) {
                      confirmRoom();
                    },
                  ),
                ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Add to collection',
                onPressed: confirmAction,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget roomOption(String name, IconData icon) {
    final bool selected = selectedRoom == name;
    Color optionColor = mutedText;
    Color? titleColor;
    FontWeight titleWeight = FontWeight.w400;
    Widget? checkmark;
    if (selected) {
      optionColor = plantGreen;
      titleColor = plantGreen;
      titleWeight = FontWeight.w600;
      checkmark = const Icon(Icons.check, color: plantGreen);
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 16,
      leading: Icon(icon, color: optionColor),
      title: Text(
        name,
        style: TextStyle(color: titleColor, fontWeight: titleWeight),
      ),
      trailing: checkmark,
      selected: selected,
      selectedTileColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          selectedRoom = name;
          roomError = null;
        });
      },
    );
  }
}
