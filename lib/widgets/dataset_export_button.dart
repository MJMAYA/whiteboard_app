import 'package:flutter/material.dart';
import '../services/dataset_exporter.dart';

class DatasetExportButton extends StatefulWidget {
  final VoidCallback? onExportComplete;

  const DatasetExportButton({super.key, this.onExportComplete});

  @override
  _DatasetExportButtonState createState() => _DatasetExportButtonState();
}

class _DatasetExportButtonState extends State<DatasetExportButton> {
  bool _isExporting = false;

  Future<void> _exportDataset() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final sampleCount = await DatasetExporter.getDatasetSize();

      if (sampleCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay muestras para exportar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Copiar el dataset CSV al portapapeles
      await DatasetExporter.copyDatasetToClipboard();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dataset CSV copiado al portapapeles ($sampleCount muestras)',
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver muestras',
            onPressed: _showDatasetInfo,
          ),
        ),
      );

      widget.onExportComplete?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _showDatasetInfo() {
    final samples = DatasetExporter.getDatasetSamples();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dataset Info (${samples.length} muestras)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // Aumentado para más botones
          child: samples.isEmpty
              ? const Center(child: Text('No hay muestras en el dataset'))
              : Column(
                  children: [
                    // Botones de descarga
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            DatasetExporter.downloadCsvFile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('CSV descargado'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.file_download, size: 16),
                          label: const Text('CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            DatasetExporter.downloadAllImages();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Descargando ${samples.length} imágenes',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.image, size: 16),
                          label: const Text('Imágenes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            DatasetExporter.downloadCompleteDataset();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Descargando dataset completo'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.archive, size: 16),
                          label: const Text('Todo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Lista de muestras
                    Expanded(
                      child: ListView.builder(
                        itemCount: samples.length,
                        itemBuilder: (context, index) {
                          final sample = samples[index];
                          return Card(
                            child: ListTile(
                              title: Text('Muestra ${index + 1}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Significado: ${sample['meaningText']}'),
                                  Text(
                                    'OCR: ${sample['recognizedText'].isEmpty ? 'N/A' : sample['recognizedText']}',
                                  ),
                                  Text('Imagen: ${sample['imageName']}'),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  DatasetExporter.downloadImage(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Descargando ${sample['imageName']}',
                                      ),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Descargar imagen individual',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              DatasetExporter.clearDataset();
              Navigator.of(context).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dataset limpiado'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Limpiar Dataset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: DatasetExporter.getDatasetSize(),
      builder: (context, snapshot) {
        final sampleCount = snapshot.data ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              // Botón principal: Copiar al portapapeles
              ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportDataset,
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.copy),
                label: Text(
                  _isExporting ? 'Copiando...' : 'Copiar CSV al Portapapeles',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Botón: Descargar CSV como archivo
              ElevatedButton.icon(
                onPressed: sampleCount > 0
                    ? () {
                        DatasetExporter.downloadCsvFile();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Archivo CSV descargado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.file_download),
                label: const Text('Descargar CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sampleCount > 0 ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Botón: Descargar dataset completo
              ElevatedButton.icon(
                onPressed: sampleCount > 0
                    ? () {
                        DatasetExporter.downloadCompleteDataset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Descargando dataset completo: CSV + $sampleCount imágenes',
                            ),
                            backgroundColor: Colors.purple,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.archive),
                label: const Text('Descargar Todo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sampleCount > 0
                      ? Colors.purple
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$sampleCount muestras en dataset',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (sampleCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _showDatasetInfo,
                      child: const Text('Ver Detalles'),
                    ),
                    TextButton(
                      onPressed: () {
                        DatasetExporter.printDatasetInfo();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Información del dataset mostrada en consola del navegador',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      child: const Text('Ver Consola'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
