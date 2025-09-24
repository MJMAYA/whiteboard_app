import 'package:flutter/material.dart';
import '../services/enhanced_ocr_service.dart';

class ImageEnhancementSelector extends StatelessWidget {
  final ImageEnhancement selectedEnhancement;
  final ValueChanged<ImageEnhancement> onChanged;
  final bool enabled;

  const ImageEnhancementSelector({
    super.key,
    required this.selectedEnhancement,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_fix_high, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Preprocesado de Imagen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Selecciona el tipo de mejora a aplicar antes del OCR:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ImageEnhancement.values.map((enhancement) {
                final isSelected = enhancement == selectedEnhancement;

                return GestureDetector(
                  onTap: enabled ? () => onChanged(enhancement) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : (enabled
                                ? Colors.grey.shade100
                                : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconForEnhancement(enhancement),
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : (enabled
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          enhancement.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (enabled
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade400),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getDescriptionForEnhancement(selectedEnhancement),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForEnhancement(ImageEnhancement enhancement) {
    switch (enhancement) {
      case ImageEnhancement.standard:
        return Icons.auto_awesome;
      case ImageEnhancement.contrast:
        return Icons.contrast;
      case ImageEnhancement.sharpness:
        return Icons.center_focus_strong;
      case ImageEnhancement.brightness:
        return Icons.brightness_6;
      case ImageEnhancement.binarize:
        return Icons.invert_colors;
      case ImageEnhancement.denoise:
        return Icons.blur_off;
      case ImageEnhancement.none:
        return Icons.disabled_by_default;
    }
  }

  String _getDescriptionForEnhancement(ImageEnhancement enhancement) {
    switch (enhancement) {
      case ImageEnhancement.standard:
        return 'Aplicar mejoras estándar: contraste moderado + nitidez. Recomendado para la mayoría de casos.';
      case ImageEnhancement.contrast:
        return 'Aumentar contraste significativamente. Útil para texto con poco contraste sobre el fondo.';
      case ImageEnhancement.sharpness:
        return 'Incrementar nitidez de la imagen. Ideal para texto borroso o desenfocado.';
      case ImageEnhancement.brightness:
        return 'Ajustar brillo de la imagen. Útil para imágenes muy oscuras.';
      case ImageEnhancement.binarize:
        return 'Convertir a blanco y negro puro. Excelente para texto manuscrito o con fondos complejos.';
      case ImageEnhancement.denoise:
        return 'Eliminar ruido de la imagen. Útil para fotos con grano o artifacts.';
      case ImageEnhancement.none:
        return 'Sin preprocesado. Usar la imagen original tal como está.';
    }
  }
}

class EnhancementPreview extends StatelessWidget {
  final ImageEnhancement enhancement;
  final Widget originalImage;

  const EnhancementPreview({
    super.key,
    required this.enhancement,
    required this.originalImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👁️ Vista Previa: ${enhancement.displayName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColorFiltered(
                  colorFilter: _getColorFilterForEnhancement(enhancement),
                  child: originalImage,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPreviewDescription(enhancement),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ColorFilter _getColorFilterForEnhancement(ImageEnhancement enhancement) {
    switch (enhancement) {
      case ImageEnhancement.contrast:
        return const ColorFilter.matrix([
          1.5,
          0,
          0,
          0,
          -64,
          0,
          1.5,
          0,
          0,
          -64,
          0,
          0,
          1.5,
          0,
          -64,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageEnhancement.brightness:
        return const ColorFilter.matrix([
          1.2,
          0,
          0,
          0,
          0,
          0,
          1.2,
          0,
          0,
          0,
          0,
          0,
          1.2,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageEnhancement.binarize:
        return const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      default:
        return const ColorFilter.matrix([
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }

  String _getPreviewDescription(ImageEnhancement enhancement) {
    switch (enhancement) {
      case ImageEnhancement.contrast:
        return 'Simulación: Mayor contraste entre texto y fondo';
      case ImageEnhancement.brightness:
        return 'Simulación: Imagen más brillante y clara';
      case ImageEnhancement.binarize:
        return 'Simulación: Conversión a escala de grises';
      default:
        return 'Vista previa aproximada del efecto aplicado';
    }
  }
}
