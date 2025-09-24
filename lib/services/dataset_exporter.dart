import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'dart:convert';

class DatasetExporter {
  static int _sampleCounter = 0;
  static final List<Map<String, dynamic>> _dataset = [];

  /// Exporta una muestra al dataset
  static Future<bool> exportSample({
    required Uint8List imageBytes,
    required String meaningText,
    String? recognizedText,
  }) async {
    try {
      _sampleCounter++;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageName = 'whiteboard_$timestamp.png';

      // Agregar muestra al dataset en memoria
      _dataset.add({
        'timestamp': DateTime.now().toIso8601String(),
        'imageName': imageName,
        'meaningText': meaningText,
        'recognizedText': recognizedText ?? '',
        'imageBytes': imageBytes,
      });

      // Para web, mostramos información de cómo acceder al dataset
      if (kDebugMode) {
        print('Muestra $_sampleCounter agregada al dataset en memoria.');
        print('Significado: $meaningText');
        print('OCR: ${recognizedText ?? "N/A"}');
        print('Para exportar, use el botón de exportar dataset.');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error exportando muestra: $e');
      }
      return false;
    }
  }

  /// Genera el CSV del dataset completo
  static String generateDatasetCsv() {
    if (_dataset.isEmpty) {
      return 'timestamp,image_filename,meaning_text,ocr_text,image_path\n';
    }

    final buffer = StringBuffer();
    buffer.writeln('timestamp,image_filename,meaning_text,ocr_text,image_path');

    for (final sample in _dataset) {
      final escapedMeaning = _escapeCsvField(sample['meaningText'] as String);
      final escapedOcr = _escapeCsvField(sample['recognizedText'] as String);

      buffer.writeln(
        '${sample['timestamp']},${sample['imageName']},$escapedMeaning,$escapedOcr,${sample['imageName']}',
      );
    }

    return buffer.toString();
  }

  /// Copia el CSV al portapapeles
  static Future<void> copyDatasetToClipboard() async {
    final csvContent = generateDatasetCsv();
    await Clipboard.setData(ClipboardData(text: csvContent));

    if (kDebugMode) {
      print('Dataset CSV copiado al portapapeles');
      print('Total de muestras: ${_dataset.length}');
      print('=== CONTENIDO DEL CSV ===');
      print(csvContent);
      print('=== FIN DEL CSV ===');
    }
  }

  /// Muestra el contenido completo del dataset en consola
  static void printDatasetInfo() {
    if (kDebugMode) {
      print('\n=== INFORMACIÓN COMPLETA DEL DATASET ===');
      print('Total de muestras: ${_dataset.length}');
      print('\n--- CSV CONTENT ---');
      print(generateDatasetCsv());
      print('\n--- SAMPLE DETAILS ---');
      for (int i = 0; i < _dataset.length; i++) {
        final sample = _dataset[i];
        print('Muestra ${i + 1}:');
        print('  - Timestamp: ${sample['timestamp']}');
        print('  - Imagen: ${sample['imageName']}');
        print('  - Significado: ${sample['meaningText']}');
        print('  - OCR: ${sample['recognizedText']}');
        print(
          '  - Tamaño imagen: ${(sample['imageBytes'] as Uint8List).length} bytes',
        );
        print('');
      }
      print('=== FIN DE LA INFORMACIÓN ===\n');
    }
  }

  /// Descarga el CSV como archivo
  static void downloadCsvFile() {
    if (kIsWeb) {
      final csvContent = generateDatasetCsv();
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'whiteboard_dataset_${DateTime.now().millisecondsSinceEpoch}.csv',
        )
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  /// Descarga una imagen específica como archivo PNG
  static void downloadImage(int index) {
    if (kIsWeb && index < _dataset.length) {
      final sample = _dataset[index];
      final imageBytes = sample['imageBytes'] as Uint8List;
      final imageName = sample['imageName'] as String;

      final blob = html.Blob([imageBytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', imageName)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  /// Descarga todas las imágenes como archivos individuales
  static void downloadAllImages() {
    if (kIsWeb) {
      for (int i = 0; i < _dataset.length; i++) {
        // Añadir un pequeño retraso entre descargas para evitar bloqueos del navegador
        Future.delayed(Duration(milliseconds: 200 * i), () {
          downloadImage(i);
        });
      }
    }
  }

  /// Crea un archivo ZIP con todo el dataset (simulado con múltiples descargas)
  static void downloadCompleteDataset() {
    if (kIsWeb) {
      // Descargar CSV
      downloadCsvFile();

      // Descargar todas las imágenes
      downloadAllImages();

      if (kDebugMode) {
        print(
          'Descargando dataset completo: CSV + ${_dataset.length} imágenes',
        );
      }
    }
  }

  /// Obtiene la lista de muestras del dataset
  static List<Map<String, dynamic>> getDatasetSamples() {
    return List.unmodifiable(_dataset);
  }

  /// Limpia el dataset
  static void clearDataset() {
    _dataset.clear();
    _sampleCounter = 0;
    if (kDebugMode) {
      print('Dataset limpiado');
    }
  }

  /// Escapa campos CSV que contienen comas o comillas
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Obtiene el número de muestras en el dataset
  static Future<int> getDatasetSize() async {
    return _dataset.length;
  }

  /// Verifica si el directorio del dataset existe (siempre true para esta implementación)
  static Future<bool> datasetDirectoryExists() async {
    return true;
  }
}
