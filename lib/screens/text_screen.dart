import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:provider/provider.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final TextEditingController _controller = TextEditingController();
  String _initialText = '';

  @override
  void initState() {
    super.initState();
    _initialText = _controller.text;
  }

  void _saveTextChange() {
    if (_controller.text != _initialText) {
      final undoProvider = Provider.of<UndoProvider>(context, listen: false);
      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );

      final currentState = colorProvider.captureCurrentState();
      undoProvider.saveState(
        action: 'Change text from "$_initialText" to "${_controller.text}"',
        state: currentState,
      );
    }
  }

  void _confirmText() {
    final trimmedText = _controller.text.trim();
    if (trimmedText.isNotEmpty) {
      Navigator.pop(
        context,
        trimmedText,
      ); // Return to previous screen with text
    } else {
      Navigator.pop(context); // Return without doing anything
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add New Text'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _confirmText),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 120),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Your Text Here',
                hintStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              cursorColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
