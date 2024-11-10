import 'package:flutter/material.dart';

class EditDeckDialog extends StatefulWidget {
  final String initialName;

  const EditDeckDialog({required this.initialName, super.key});

  @override
  State<EditDeckDialog> createState() => _EditDeckDialogState();
}

class _EditDeckDialogState extends State<EditDeckDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Deck'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Deck Name',
              hintText: 'Enter deck name',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(context, _nameController.text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
