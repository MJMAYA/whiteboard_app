import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'draw_point.dart';
import 'detected_square.dart';
import 'whiteboard_painter.dart';
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
  DetectedSquare? _tryDetectSquare(List<DrawPoint> stroke) {
    if (stroke.length < 20) return null;
    double minX = stroke.first.offset.dx;
    double maxX = stroke.first.offset.dx;
    double minY = stroke.first.offset.dy;
    double maxY = stroke.first.offset.dy;
    for (var p in stroke) {
      if (p.offset.dx < minX) minX = p.offset.dx;
      if (p.offset.dx > maxX) maxX = p.offset.dx;
      if (p.offset.dy < minY) minY = p.offset.dy;
      if (p.offset.dy > maxY) maxY = p.offset.dy;
    }
    double width = maxX - minX;
    double height = maxY - minY;
    if ((width - height).abs() < 15 && width > 30 && height > 30) {
      int countOnPerimeter = 0;
      for (var p in stroke) {
        bool onLeft = (p.offset.dx - minX).abs() < 15;
        bool onRight = (p.offset.dx - maxX).abs() < 15;
        bool onTop = (p.offset.dy - minY).abs() < 15;
        bool onBottom = (p.offset.dy - maxY).abs() < 15;
        if ((onLeft || onRight) && (onTop || onBottom)) countOnPerimeter++;
      }
      if (countOnPerimeter > stroke.length * 0.7) {
        return DetectedSquare(
          Rect.fromLTWH(minX, minY, width, height),
          _selectedColor,
        );
      }
    }
    return null;
  }

  String? _figureMessage;
  double _lastPressure = 1.0;
  bool _showPressure = false;
  final GlobalKey _paintKey = GlobalKey();
  final GlobalKey _boundaryKey = GlobalKey();
  final List<DrawPoint?> _points = [];
  final List<DetectedSquare> _squares = [];
  Color _selectedColor = Colors.black;
  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.yellow,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pizarra Interactiva ws2')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: (event) {
                        //print(
                        //  '[DEBUG] PointerDown: pressure=${event.pressure}, position=${event.position}, device=${event.device}',
                        //);
                        setState(() {
                          RenderBox? box =
                              _paintKey.currentContext?.findRenderObject()
                                  as RenderBox?;
                          Offset point = box != null
                              ? box.globalToLocal(event.position)
                              : event.localPosition;
                          double pressure = event.pressure;
                          _lastPressure = pressure;
                          double minStroke = 2.0;
                          double maxStroke = 8.0;
                          double normalized = pressure.clamp(0.0, 1.0);
                          double stroke =
                              minStroke + (maxStroke - minStroke) * normalized;
                          _points.add(DrawPoint(point, _selectedColor, stroke));
                        });
                      },
                      onPointerMove: (event) {
                        // print(
                        //   '[DEBUG] PointerMove: pressure=${event.pressure}, position=${event.position}, device=${event.device}',
                        // );
                        setState(() {
                          RenderBox? box =
                              _paintKey.currentContext?.findRenderObject()
                                  as RenderBox?;
                          Offset point = box != null
                              ? box.globalToLocal(event.position)
                              : event.localPosition;
                          double pressure = event.pressure;
                          if (pressure == 0.0) {
                            pressure = _lastPressure;
                          } else {
                            _lastPressure = pressure;
                          }
                          double minStroke = 2.0;
                          double maxStroke = 8.0;
                          double normalized = pressure.clamp(0.0, 1.0);
                          double stroke =
                              minStroke + (maxStroke - minStroke) * normalized;
                          _points.add(DrawPoint(point, _selectedColor, stroke));
                        });
                      },
                      onPointerUp: (event) {
                        setState(() {
                          List<DrawPoint> stroke = [];
                          int i = _points.length - 1;
                          while (i >= 0 && _points[i] != null) {
                            stroke.insert(0, _points[i]!);
                            i--;
                          }
                          if (stroke.length >= 10) {
                            final square = _tryDetectSquare(stroke);
                            if (square != null) {
                              _points.removeRange(i + 1, _points.length);
                              _squares.add(square);
                              _figureMessage = '¡Cuadrado detectado!';
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() => _figureMessage = null);
                                }
                              });
                            } else {
                              _points.add(null);
                            }
                          } else {
                            _points.add(null);
                          }
                        });
                      },
                      child: CustomPaint(
                        key: _paintKey,
                        painter: WhiteboardPainter(_points, _squares),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
                if (_figureMessage != null)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _figureMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_showPressure)
                  Positioned(
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
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _points.clear();
                _squares.clear();
              });
            },
            tooltip: 'Limpiar pizarra',
            child: const Icon(Icons.clear),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _showPressure = !_showPressure;
              });
            },
            tooltip: _showPressure ? 'Ocultar presión' : 'Mostrar presión',
            backgroundColor: Colors.blueGrey,
            child: Icon(
              _showPressure ? Icons.visibility_off : Icons.visibility,
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _recognizeTextFromWhiteboard,
            tooltip: 'Reconocer texto',
            backgroundColor: Colors.green,
            child: const Icon(Icons.text_fields),
          ),
        ],
      ),
    );
  }

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
        print('parseada url');
        request.files.add(
          http.MultipartFile.fromBytes(
            'the_file',
            pngBytes,
            filename: 'ocr_temp.png',
          ),
        );
        print('antes de enviar');
        var response = await request.send();
        if (response.statusCode == 200) {
          print('respuesta correcta');
          final respStr = await response.stream.bytesToString();
          // Parsear JSON para obtener el campo 'result'
          try {
            final Map<String, dynamic> jsonResp = respStr.isNotEmpty
                ? (respStr.startsWith('{') ? jsonDecode(respStr) : {})
                : {};
            recognizedText = jsonResp.containsKey('result')
                ? jsonResp['result'].toString()
                : 'No se detectó texto';
            print('Resultado: $recognizedText');
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
          print('Resultado: $result');
          recognizedText = result != null
              ? result.group(1)!
              : 'No se detectó texto';
        } else {
          recognizedText = 'Error en el servicio OCR';
        }
        await tempFile.delete();
      }

      setState(() {
        _figureMessage = 'Texto detectado: $recognizedText';
      });
    } catch (e) {
      setState(() {
        _figureMessage = 'Error al reconocer texto: $e';
      });
    }
  }
}
