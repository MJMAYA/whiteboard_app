import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../services/dataset_exporter.dart';

class AddSampleButton extends StatefulWidget {
  final GlobalKey boundaryKey;
  final String meaningText;
  final String recognizedText;
  final List<dynamic> points;
  final VoidCallback? onSampleAdded;

  const AddSampleButton({
    super.key,
    required this.boundaryKey,
    required this.meaningText,
    required this.recognizedText,
    required this.points,
    this.onSampleAdded,
  });

  @override
  _AddSampleButtonState createState() => _AddSampleButtonState();
}

class _AddSampleButtonState extends State<AddSampleButton> {
  bool _isAdding = false;

  Future<void> _addSampleToDataset() async {
    if (_isAdding ||
        widget.meaningText.trim().isEmpty ||
        widget.points.isEmpty) {
      if (widget.meaningText.trim().isEmpty || widget.points.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Necesitas dibujar algo y escribir el significado antes de agregar al dataset',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      // Capturar la imagen de la pizarra
      RenderRepaintBoundary? boundary =
          widget.boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('No se pudo capturar la imagen de la pizarra');
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('No se pudo convertir la imagen');
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Agregar al dataset
      final success = await DatasetExporter.exportSample(
        imageBytes: imageBytes,
        meaningText: widget.meaningText.trim(),
        recognizedText: widget.recognizedText.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Muestra agregada al dataset exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Notificar que se agregó la muestra
        widget.onSampleAdded?.call();
      } else {
        throw Exception('Error al guardar la muestra');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar muestra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        widget.meaningText.trim().isNotEmpty && widget.points.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ElevatedButton.icon(
        onPressed: _isAdding || !isEnabled ? null : _addSampleToDataset,
        icon: _isAdding
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(_isAdding ? 'Agregando...' : 'Agregar al Dataset'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.green : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
