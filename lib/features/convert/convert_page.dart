import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'convert_controller.dart';
import '../../core/ffmpeg/ffmpeg_providers.dart';

class ConvertPage extends ConsumerStatefulWidget {
  const ConvertPage({super.key});

  @override
  ConsumerState<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends ConsumerState<ConvertPage> {
  String _selectedExtension = '.mp4';
  
  // Lista expandida com foco em vídeo e áudio
  final List<String> _videoExtensions = ['.mp4', '.mkv', '.avi', '.mov', '.webm'];
  final List<String> _audioExtensions = ['.mp3', '.m4a', '.wav', '.flac', '.ogg'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(convertProvider);
    final controller = ref.read(convertProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
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
                  'Conversão de Mídia',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Seção de Seleção de Arquivo
            Card(
              child: ListTile(
                leading: const Icon(Icons.perm_media, color: Colors.blue),
                title: Text(state.selectedFilePath ?? 'Nenhum arquivo selecionado'),
                subtitle: const Text('Selecione o arquivo de mídia original (Vídeo ou Áudio)'),
                trailing: ElevatedButton(
                  onPressed: state.status == ProcessStatus.loading 
                    ? null 
                    : () => controller.pickFile(),
                  child: const Text('Selecionar'),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (state.selectedFilePath != null) ...[
              const Text(
                'Formatos de Vídeo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _videoExtensions.map((ext) {
                  return ChoiceChip(
                    label: Text(ext.toUpperCase().replaceAll('.', '')),
                    selected: _selectedExtension == ext,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedExtension = ext);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Formatos de Áudio:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _audioExtensions.map((ext) {
                  return ChoiceChip(
                    label: Text(ext.toUpperCase().replaceAll('.', '')),
                    selected: _selectedExtension == ext,
                    selectedColor: Colors.orange.withOpacity(0.3),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedExtension = ext);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              
              Center(
                child: Column(
                  children: [
                    if (state.status == ProcessStatus.loading)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Convertendo... Isso pode levar alguns minutos.'),
                        ],
                      )
                    else if (state.status == ProcessStatus.success)
                      const Text(
                        '✅ Conversão concluída com sucesso!',
                        style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    else if (state.status == ProcessStatus.error)
                      Text(
                        '❌ Erro: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => controller.startConversion(_selectedExtension),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('INICIAR CONVERSÃO', style: TextStyle(fontSize: 16)),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
