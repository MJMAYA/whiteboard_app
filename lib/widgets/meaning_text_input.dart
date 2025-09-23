import 'package:flutter/material.dart';

class MeaningTextInput extends StatefulWidget {
  final String meaningText;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onClear;

  const MeaningTextInput({
    super.key,
    required this.meaningText,
    required this.onTextChanged,
    required this.onClear,
  });

  @override
  State<MeaningTextInput> createState() => _MeaningTextInputState();
}

class _MeaningTextInputState extends State<MeaningTextInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.meaningText);
  }

  @override
  void didUpdateWidget(MeaningTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.meaningText != oldWidget.meaningText) {
      _controller.text = widget.meaningText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Reducido de 120 a 100
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildHeader(), _buildTextInput()],
      ),
    );
  }

  Widget _buildHeader() => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
    ),
    child: Row(
      children: [
        const Icon(Icons.edit, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        const Text(
          'Significado Real:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blue,
          ),
        ),
        const Spacer(),
        if (_controller.text.isNotEmpty)
          GestureDetector(
            onTap: () {
              _controller.clear();
              widget.onTextChanged('');
              widget.onClear();
            },
            child: const Icon(Icons.clear, size: 16, color: Colors.blue),
          ),
      ],
    ),
  );

  Widget _buildTextInput() => Expanded(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Escribe aquí el significado real de tu dibujo...',
          hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        onChanged: (text) {
          widget.onTextChanged(text);
          setState(() {}); // Para actualizar la visibilidad del botón clear
        },
      ),
    ),
  );
}
