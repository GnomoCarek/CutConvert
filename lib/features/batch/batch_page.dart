import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'batch_controller.dart';

class BatchPage extends ConsumerWidget {
  const BatchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchProvider);
    final controller = ref.read(batchProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => controller.reset(),
              ),
              const Text(
                'Fila de Processamento',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Adicione vários arquivos para converter todos de uma vez.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: state.isProcessing ? null : () => controller.pickFiles(),
                icon: const Icon(Icons.add_to_photos),
                label: const Text('ADICIONAR ARQUIVOS'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 24),
              const Text('Formato de Destino:'),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: state.targetExtension,
                onChanged: state.isProcessing ? null : (val) => controller.updateTargetExtension(val!),
                items: ['.mp3', '.mp4', '.mkv', '.m4a', '.wav']
                    .map((ext) => DropdownMenuItem(value: ext, child: Text(ext.toUpperCase())))
                    .toList(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: state.items.isEmpty
                  ? const Center(child: Text('Nenhum arquivo na fila.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return ListTile(
                          leading: _getStatusIcon(item.status),
                          title: Text(p.basename(item.path)),
                          subtitle: Text(item.error ?? item.path, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: state.isProcessing
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => controller.removeItem(index),
                                ),
                        );
                      },
                    ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          if (state.items.isNotEmpty)
            Center(
              child: ElevatedButton.icon(
                onPressed: state.isProcessing ? null : () => controller.startBatch(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                icon: state.isProcessing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.play_circle_fill),
                label: Text(state.isProcessing ? 'PROCESSANDO FILA...' : 'INICIAR FILA'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(BatchItemStatus status) {
    switch (status) {
      case BatchItemStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
      case BatchItemStatus.processing:
        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
      case BatchItemStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case BatchItemStatus.error:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
