import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extract_controller.dart';
import '../../core/ffmpeg/ffmpeg_providers.dart';

class ExtractPage extends ConsumerStatefulWidget {
  const ExtractPage({super.key});

  @override
  ConsumerState<ExtractPage> createState() => _ExtractPageState();
}

class _ExtractPageState extends ConsumerState<ExtractPage> {
  String _selectedExtension = '.mp3';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(extractProvider);
    final controller = ref.read(extractProvider.notifier);

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
                'Extrair Áudio',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Remova o vídeo e salve apenas a trilha sonora.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.music_note, color: Colors.purple),
              title: Text(state.selectedFilePath ?? 'Nenhum vídeo selecionado'),
              subtitle: const Text('Selecione o vídeo de onde deseja extrair o som'),
              trailing: ElevatedButton(
                onPressed: state.status == ProcessStatus.loading 
                  ? null 
                  : () => controller.pickFile(),
                child: const Text('Selecionar Vídeo'),
              ),
            ),
          ),
          
          if (state.selectedFilePath != null) ...[
            const SizedBox(height: 32),
            const Text(
              'Formato de saída:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('MP3 (Universal)'),
                  selected: _selectedExtension == '.mp3',
                  onSelected: (val) => setState(() => _selectedExtension = '.mp3'),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Original (Sem perda)'),
                  selected: _selectedExtension == '.m4a',
                  onSelected: (val) => setState(() => _selectedExtension = '.m4a'),
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
                        CircularProgressIndicator(color: Colors.purple),
                        SizedBox(height: 16),
                        Text('Extraindo trilha sonora...'),
                      ],
                    )
                  else if (state.status == ProcessStatus.success)
                    const Text(
                      '✅ Áudio extraído com sucesso!',
                      style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  else if (state.status == ProcessStatus.error)
                    Text('❌ Erro: ${state.errorMessage}', style: const TextStyle(color: Colors.red))
                  else
                    ElevatedButton.icon(
                      onPressed: () => controller.startExtraction(_selectedExtension),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.audiotrack),
                      label: const Text('EXTRAIR AGORA', style: TextStyle(fontSize: 16)),
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
