import 'package:flutter/material.dart';
import '../services/enhanced_ocr_service.dart';

class DatasetStatsWidget extends StatefulWidget {
  final EnhancedOcrService ocrService;

  const DatasetStatsWidget({super.key, required this.ocrService});

  @override
  State<DatasetStatsWidget> createState() => _DatasetStatsWidgetState();
}

class _DatasetStatsWidgetState extends State<DatasetStatsWidget> {
  DatasetStats? stats;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final loadedStats = await widget.ocrService.getDatasetStats();
      setState(() {
        stats = loadedStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _exportDataset() async {
    try {
      final csvData = await widget.ocrService.exportDataset();

      if (mounted) {
        // Aquí podrías implementar la descarga del CSV
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dataset exportado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📊 Dataset Statistics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadStats,
                      tooltip: 'Actualizar estadísticas',
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Exportar CSV'),
                      onPressed: _exportDataset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: $error',
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              )
            else if (stats != null)
              _buildStatsContent()
            else
              const Text('No hay estadísticas disponibles'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    final stats = this.stats!;

    return Column(
      children: [
        // Estadísticas generales
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Muestras',
                value: stats.totalSamples.toString(),
                icon: Icons.image,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Confianza Promedio',
                value: '${stats.averageConfidence.toStringAsFixed(1)}%',
                icon: Icons.verified,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Tiempo Promedio',
                value:
                    '${(stats.averageProcessingTime * 1000).toStringAsFixed(0)}ms',
                icon: Icons.timer,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Sesiones',
                value: stats.recentSessions.length.toString(),
                icon: Icons.session_timeout,
                color: Colors.purple,
              ),
            ),
          ],
        ),

        if (stats.preprocessingBreakdown.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            '🔧 Preprocesado por Tipo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPreprocessingChart(stats.preprocessingBreakdown),
        ],

        if (stats.recentSessions.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            '📅 Sesiones Recientes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSessionsList(stats.recentSessions),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreprocessingChart(List<PreprocessingStats> preprocessing) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: preprocessing.map((stat) {
          final total = preprocessing.fold<int>(
            0,
            (sum, item) => sum + item.count,
          );
          final percentage = total > 0 ? (stat.count / total) * 100 : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(stat.type, style: const TextStyle(fontSize: 12)),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getColorForPreprocessing(stat.type),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${stat.count}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${stat.avgConfidence.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionsList(List<SessionStats> sessions) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                '${session.sampleCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.indigo.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Sesión ${session.sessionId.substring(0, 8)}...',
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              '${session.sampleCount} muestras',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              '${session.avgConfidence.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Color _getColorForPreprocessing(String type) {
    switch (type.toLowerCase()) {
      case 'standard':
        return Colors.blue;
      case 'contrast':
        return Colors.red;
      case 'binarize':
        return Colors.green;
      case 'denoise':
        return Colors.orange;
      case 'sharpness':
        return Colors.purple;
      case 'brightness':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
