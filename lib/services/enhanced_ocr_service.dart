// Enhanced OCR Service for Flutter
// Compatible with enhanced Tesseract server

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnhancedOcrService {
  final String baseUrl;
  final String sessionId;

  EnhancedOcrService({
    this.baseUrl = 'http://localhost:1688',
    String? sessionId,
  }) : sessionId =
           sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Procesar imagen con opciones de preprocesado
  Future<OcrResult> processImage(
    Uint8List imageBytes, {
    String enhancement = 'standard',
    String? correctedText,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);

      // Añadir imagen
      request.files.add(
        http.MultipartFile.fromBytes(
          'the_file',
          imageBytes,
          filename: 'image.png',
        ),
      );

      // Añadir parámetros
      request.fields['enhancement'] = enhancement;
      request.fields['session_id'] = sessionId;
      if (correctedText != null) {
        request.fields['corrected_text'] = correctedText;
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseData);
        return OcrResult.fromJson(json);
      } else {
        throw Exception('OCR request failed: ${response.statusCode}');
      }
    } catch (e) {
      return OcrResult.error('Error processing image: $e');
    }
  }

  /// Obtener estadísticas del dataset
  Future<DatasetStats> getDatasetStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dataset/stats'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return DatasetStats.fromJson(json);
      } else {
        throw Exception('Failed to get stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting dataset stats: $e');
    }
  }

  /// Exportar dataset completo
  Future<String> exportDataset() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dataset/export'));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to export dataset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting dataset: $e');
    }
  }
}

class OcrResult {
  final String text;
  final int? sampleId;
  final double confidence;
  final double processingTime;
  final String enhancementApplied;
  final String sessionId;
  final Map<String, int>? imageSize;
  final String? error;

  OcrResult({
    required this.text,
    this.sampleId,
    required this.confidence,
    required this.processingTime,
    required this.enhancementApplied,
    required this.sessionId,
    this.imageSize,
    this.error,
  });

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      text: json['result'] ?? '',
      sampleId: json['sample_id'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      processingTime: (json['processing_time'] ?? 0).toDouble(),
      enhancementApplied: json['enhancement_applied'] ?? 'standard',
      sessionId: json['session_id'] ?? '',
      imageSize: json['image_size'] != null
          ? Map<String, int>.from(json['image_size'])
          : null,
    );
  }

  factory OcrResult.error(String errorMessage) {
    return OcrResult(
      text: '',
      confidence: 0,
      processingTime: 0,
      enhancementApplied: 'none',
      sessionId: '',
      error: errorMessage,
    );
  }

  bool get hasError => error != null;
  bool get isSuccessful => !hasError && text.isNotEmpty;
}

class DatasetStats {
  final int totalSamples;
  final double averageConfidence;
  final double averageProcessingTime;
  final List<PreprocessingStats> preprocessingBreakdown;
  final List<SessionStats> recentSessions;

  DatasetStats({
    required this.totalSamples,
    required this.averageConfidence,
    required this.averageProcessingTime,
    required this.preprocessingBreakdown,
    required this.recentSessions,
  });

  factory DatasetStats.fromJson(Map<String, dynamic> json) {
    return DatasetStats(
      totalSamples: json['total_samples'] ?? 0,
      averageConfidence: (json['average_confidence'] ?? 0).toDouble(),
      averageProcessingTime: (json['average_processing_time'] ?? 0).toDouble(),
      preprocessingBreakdown:
          (json['preprocessing_breakdown'] as List?)
              ?.map((item) => PreprocessingStats.fromJson(item))
              .toList() ??
          [],
      recentSessions:
          (json['recent_sessions'] as List?)
              ?.map((item) => SessionStats.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PreprocessingStats {
  final String type;
  final int count;
  final double avgConfidence;

  PreprocessingStats({
    required this.type,
    required this.count,
    required this.avgConfidence,
  });

  factory PreprocessingStats.fromJson(Map<String, dynamic> json) {
    return PreprocessingStats(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
      avgConfidence: (json['avg_confidence'] ?? 0).toDouble(),
    );
  }
}

class SessionStats {
  final String sessionId;
  final int sampleCount;
  final double avgConfidence;

  SessionStats({
    required this.sessionId,
    required this.sampleCount,
    required this.avgConfidence,
  });

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      sessionId: json['session_id'] ?? '',
      sampleCount: json['sample_count'] ?? 0,
      avgConfidence: (json['avg_confidence'] ?? 0).toDouble(),
    );
  }
}

// Enum para tipos de preprocesado
enum ImageEnhancement {
  standard,
  contrast,
  sharpness,
  brightness,
  binarize,
  denoise,
  none;

  String get value => name;

  String get displayName {
    switch (this) {
      case ImageEnhancement.standard:
        return 'Estándar';
      case ImageEnhancement.contrast:
        return 'Alto Contraste';
      case ImageEnhancement.sharpness:
        return 'Nitidez';
      case ImageEnhancement.brightness:
        return 'Brillo';
      case ImageEnhancement.binarize:
        return 'Binarizar';
      case ImageEnhancement.denoise:
        return 'Quitar Ruido';
      case ImageEnhancement.none:
        return 'Ninguno';
    }
  }
}
