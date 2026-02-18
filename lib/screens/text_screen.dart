import 'package:flutter/material.dart';

class TextScreen extends StatefulWidget {
  final String initialText;

  const TextScreen({super.key, this.initialText = ""});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _confirmText() {
    final trimmedText = _controller.text.trim();
    if (trimmedText.isNotEmpty) {
      Navigator.pop(context, trimmedText);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialText.isEmpty ? 'Add New Text' : 'Edit Text'),
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
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Your Text Here',
                hintStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).hintColor, // Changed from Colors.grey
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
              cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
            ),
          ),
        ],
      ),
    );
  }
}
