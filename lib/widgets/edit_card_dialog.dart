import 'package:flutter/material.dart';

class EditCardDialog extends StatefulWidget {
  final String initialQuestion;
  final String initialAnswer;

  const EditCardDialog({
    required this.initialQuestion,
    required this.initialAnswer,
    super.key,
  });

  @override
  State<EditCardDialog> createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<EditCardDialog> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initialQuestion);
    _answerController = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Card'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _questionController,
            decoration: const InputDecoration(labelText: 'Question'),
            autofocus: true,
          ),
          TextField(
            controller: _answerController,
            decoration: const InputDecoration(labelText: 'Answer'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, {
            'question': _questionController.text,
            'answer': _answerController.text,
          }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}