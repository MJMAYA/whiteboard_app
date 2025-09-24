import 'package:flutter/material.dart';

class WhiteboardToolbar extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onRecognizeText;
  final VoidCallback onTogglePressure;
  final bool showPressure;

  const WhiteboardToolbar({
    super.key,
    required this.onClear,
    required this.onRecognizeText,
    required this.onTogglePressure,
    required this.showPressure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón Limpiar - MÁS PROMINENTE
          _buildPrimaryButton(
            onPressed: onClear,
            label: 'Limpiar',
            icon: Icons.clear,
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),

          // Botón OCR - MÁS PROMINENTE
          _buildPrimaryButton(
            onPressed: onRecognizeText,
            label: 'OCR',
            icon: Icons.text_fields,
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),

          // Botón de presión - Secundario
          _buildSecondaryButton(
            onPressed: onTogglePressure,
            tooltip: showPressure ? 'Ocultar presión' : 'Mostrar presión',
            icon: showPressure ? Icons.visibility_off : Icons.visibility,
            isActive: showPressure,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String tooltip,
    required IconData icon,
    required bool isActive,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isActive ? Colors.blue.shade700 : Colors.grey.shade600,
        ),
        style: IconButton.styleFrom(
          backgroundColor: isActive ? Colors.blue.shade50 : Colors.transparent,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
