import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'compress_controller.dart';
import '../../core/ffmpeg/ffmpeg_providers.dart';

class CompressPage extends ConsumerStatefulWidget {
  const CompressPage({super.key});

  @override
  ConsumerState<CompressPage> createState() => _CompressPageState();
}

class _CompressPageState extends ConsumerState<CompressPage> {
  int _targetSize = 16; // Padrão WhatsApp antigo

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compressProvider);
    final controller = ref.read(compressProvider.notifier);

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
                'Compressão Inteligente',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Reduza o tamanho do vídeo para caber no WhatsApp ou Discord sem perder a compatibilidade.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.compress, color: Colors.green),
              title: Text(state.selectedFilePath ?? 'Nenhum vídeo selecionado'),
              subtitle: const Text('Selecione o vídeo que deseja comprimir'),
              trailing: ElevatedButton(
                onPressed: state.status == ProcessStatus.loading 
                  ? null 
                  : () => controller.pickFile(),
                child: const Text('Selecionar'),
              ),
            ),
          ),
          
          if (state.selectedFilePath != null) ...[
            const SizedBox(height: 32),
            const Text(
              'Escolha o tamanho alvo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                _SizeOption(
                  label: '16 MB',
                  description: 'WhatsApp Antigo',
                  isSelected: _targetSize == 16,
                  onTap: () => setState(() => _targetSize = 16),
                ),
                _SizeOption(
                  label: '64 MB',
                  description: 'WhatsApp Atual',
                  isSelected: _targetSize == 64,
                  onTap: () => setState(() => _targetSize = 64),
                ),
                _SizeOption(
                  label: '25 MB',
                  description: 'Discord Basic',
                  isSelected: _targetSize == 25,
                  onTap: () => setState(() => _targetSize = 25),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  if (state.status == ProcessStatus.loading)
                    const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 16),
                        Text('Comprimindo vídeo em 2 passos para máxima qualidade...'),
                        Text('(Isso pode demorar dependendo do tamanho do vídeo)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  else if (state.status == ProcessStatus.success)
                    const Text(
                      '✅ Vídeo comprimido com sucesso!',
                      style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  else if (state.status == ProcessStatus.error)
                    Text('❌ Erro: ${state.errorMessage}', style: const TextStyle(color: Colors.red))
                  else
                    ElevatedButton.icon(
                      onPressed: () => controller.startCompression(_targetSize),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.speed),
                      label: const Text('INICIAR COMPRESSÃO', style: TextStyle(fontSize: 16)),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
