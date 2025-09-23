import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'draw_point.dart';
import 'whiteboard_painter.dart';
import 'widgets/ocr_text_display.dart';
import 'widgets/color_palette.dart';
import 'widgets/whiteboard_action_buttons.dart';
import 'widgets/meaning_text_input.dart';
import 'widgets/add_sample_button.dart';
import 'widgets/dataset_export_button.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
// ...existing code...
import 'package:http/http.dart' as http;

class WhiteboardScreen extends StatefulWidget {
  const WhiteboardScreen({super.key});

  @override
  State<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  String? _figureMessage;
  String _recognizedText = ''; // Variable para almacenar texto OCR
  String _meaningText = ''; // Variable para almacenar significado real
  double _lastPressure = 1.0;
  bool _showPressure = false;
  final GlobalKey _paintKey = GlobalKey();
  final GlobalKey _boundaryKey = GlobalKey();
  final List<DrawPoint?> _points = [];
  Color _selectedColor = Colors.black;
  final List<Color> _colors = [
    Colors.black, // Mejor para OCR
    Colors.blue.shade800, // Azul oscuro - buena legibilidad
    Colors.red.shade700, // Rojo oscuro - visible pero legible
    Colors.green.shade700, // Verde oscuro - mejor contraste
    Colors.indigo.shade800, // Índigo - excelente para texto
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pizarra Interactiva ws2')),
      body: Column(
        children: [
          Expanded(flex: 3, child: _buildWhiteboardArea()),
          ColorPalette(
            colors: _colors,
            selectedColor: _selectedColor,
            onColorSelected: (color) => setState(() => _selectedColor = color),
          ),
          OcrTextDisplay(
            recognizedText: _recognizedText,
            onClear: () => setState(() => _recognizedText = ''),
          ),
          MeaningTextInput(
            meaningText: _meaningText,
            onTextChanged: (text) => setState(() => _meaningText = text),
            onClear: () => setState(() => _meaningText = ''),
          ),
          AddSampleButton(
            boundaryKey: _boundaryKey,
            meaningText: _meaningText,
            recognizedText: _recognizedText,
            points: _points,
            onSampleAdded: () {
              // Limpiar la pizarra después de agregar al dataset
              setState(() {
                _points.clear();
                _recognizedText = '';
                _meaningText = '';
              });
            },
          ),
          DatasetExportButton(),
        ],
      ),
      floatingActionButton: WhiteboardActionButtons(
        onClear: () => setState(() {
          _points.clear();
          _recognizedText = '';
          _meaningText = '';
        }),
        onTogglePressure: () => setState(() => _showPressure = !_showPressure),
        onRecognizeText: _recognizeTextFromWhiteboard,
        showPressure: _showPressure,
      ),
    );
  }

  Widget _buildWhiteboardArea() {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            key: _boundaryKey,
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerUp,
              child: CustomPaint(
                key: _paintKey,
                painter: WhiteboardPainter(_points),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        if (_figureMessage != null) _buildStatusMessage(),
        if (_showPressure) _buildPressureIndicator(),
      ],
    );
  }

  // Handlers de eventos de puntero
  void _handlePointerDown(PointerDownEvent event) {
    setState(() {
      final point = _getLocalPoint(event.position);
      final stroke = _calculateStroke(event.pressure);
      _points.add(DrawPoint(point, _selectedColor, stroke));
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    setState(() {
      final point = _getLocalPoint(event.position);
      final pressure = event.pressure == 0.0 ? _lastPressure : event.pressure;
      _lastPressure = pressure;
      final stroke = _calculateStroke(pressure);
      _points.add(DrawPoint(point, _selectedColor, stroke));
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() => _points.add(null)); // Separador de trazos
  }

  // Métodos auxiliares
  Offset _getLocalPoint(Offset globalPosition) {
    final box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.globalToLocal(globalPosition) ?? globalPosition;
  }

  double _calculateStroke(double pressure) {
    const double minStroke = 2.0, maxStroke = 8.0;
    final normalized = pressure.clamp(0.0, 1.0);
    return minStroke + (maxStroke - minStroke) * normalized;
  }

  // Widgets de UI
  Widget _buildStatusMessage() => Positioned(
    top: 60,
    left: 0,
    right: 0,
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _figureMessage!,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ),
  );

  Widget _buildPressureIndicator() => Positioned(
    top: 16,
    right: 16,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        'Presión: ${_lastPressure.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );

  Future<void> _recognizeTextFromWhiteboard() async {
    try {
      RenderRepaintBoundary boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      String recognizedText = '';

      // Detectar si estamos en Flutter Web
      bool isWeb = identical(0, 0.0);
      // El truco de identical(0, 0.0) es true solo en web, pero puedes usar kIsWeb de foundation si lo importas
      // import 'package:flutter/foundation.dart'; y usar kIsWeb

      if (isWeb) {
        // Enviar los bytes directamente como multipart
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:1688/upload'),
        );

        // Cabeceras comunes para maximizar compatibilidad
        request.headers.addAll({
          'Accept': '*/*',
          'Connection': 'keep-alive',
          'User-Agent': 'FlutterWebClient',
        });
        request.files.add(
          http.MultipartFile.fromBytes(
            'the_file',
            pngBytes,
            filename: 'ocr_temp.png',
          ),
        );
        var response = await request.send();
        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          // Parsear JSON para obtener el campo 'result'
          try {
            final Map<String, dynamic> jsonResp = respStr.isNotEmpty
                ? (respStr.startsWith('{') ? jsonDecode(respStr) : {})
                : {};
            recognizedText = jsonResp.containsKey('result')
                ? jsonResp['result'].toString()
                : 'No se detectó texto';
          } catch (e) {
            recognizedText = 'No se detectó texto';
          }
        } else {
          recognizedText = 'Error en el servicio OCR';
        }
      } else {
        // Desktop/móvil: guardar archivo temporal
        final tempDir = Directory.systemTemp;
        final tempFile = await File('${tempDir.path}/ocr_temp.png').create();
        await tempFile.writeAsBytes(pngBytes);
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:1688/upload'),
        );
        request.files.add(
          await http.MultipartFile.fromPath('the_file', tempFile.path),
        );
        var response = await request.send();
        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final result = RegExp(
            r'"result"\s*:\s*"([^"]*)"',
          ).firstMatch(respStr);
          recognizedText = result != null
              ? result.group(1)!
              : 'No se detectó texto';
        } else {
          recognizedText = 'Error en el servicio OCR';
        }
        await tempFile.delete();
      }

      setState(() {
        _recognizedText = recognizedText;
      });
    } catch (e) {
      setState(() {
        _recognizedText = 'Error al reconocer texto: $e';
      });
    }
  }
}
