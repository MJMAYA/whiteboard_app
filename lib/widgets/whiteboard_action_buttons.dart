import 'package:flutter/material.dart';

class WhiteboardActionButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onTogglePressure;
  final VoidCallback onRecognizeText;
  final bool showPressure;

  const WhiteboardActionButtons({
    super.key,
    required this.onClear,
    required this.onTogglePressure,
    required this.onRecognizeText,
    required this.showPressure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          onPressed: onClear,
          tooltip: 'Limpiar pizarra',
          icon: Icons.clear,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          onPressed: onTogglePressure,
          tooltip: showPressure ? 'Ocultar presión' : 'Mostrar presión',
          icon: showPressure ? Icons.visibility_off : Icons.visibility,
          backgroundColor: Colors.blueGrey,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          onPressed: onRecognizeText,
          tooltip: 'Reconocer texto',
          icon: Icons.text_fields,
          backgroundColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String tooltip,
    required IconData icon,
    required Color backgroundColor,
  }) => FloatingActionButton(
    onPressed: onPressed,
    tooltip: tooltip,
    backgroundColor: backgroundColor,
    child: Icon(icon),
  );
}
