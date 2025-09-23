import 'package:flutter/material.dart';

class OcrTextDisplay extends StatelessWidget {
  final String? recognizedText;
  final VoidCallback onClear;

  const OcrTextDisplay({
    super.key,
    required this.recognizedText,
    required this.onClear,
  });

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
        children: [_buildHeader(), _buildTextArea()],
      ),
    );
  }

  Widget _buildHeader() => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
    ),
    child: Row(
      children: [
        const Icon(Icons.text_fields, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        const Text(
          'Texto OCR Detectado:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        if (recognizedText?.isNotEmpty == true)
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.clear, size: 16, color: Colors.grey),
          ),
      ],
    ),
  );

  Widget _buildTextArea() => Expanded(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Text(
          recognizedText?.isEmpty ?? true
              ? 'Pulsa el botón de reconocimiento para detectar texto...'
              : recognizedText!,
          style: TextStyle(
            fontSize: 14,
            color: recognizedText?.isEmpty ?? true
                ? Colors.grey.shade500
                : Colors.black87,
            fontStyle: recognizedText?.isEmpty ?? true
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
      ),
    ),
  );
}
