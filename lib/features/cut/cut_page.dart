import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cut_controller.dart';
import '../../core/ffmpeg/ffmpeg_providers.dart';

class CutPage extends ConsumerStatefulWidget {
  const CutPage({super.key});

  @override
  ConsumerState<CutPage> createState() => _CutPageState();
}

class _CutPageState extends ConsumerState<CutPage> {
  late TextEditingController _startController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(cutProvider);
    _startController = TextEditingController(text: state.startTime);
    _durationController = TextEditingController(text: state.duration);
  }

  @override
  void dispose() {
    _startController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cutProvider);
    final controller = ref.read(cutProvider.notifier);

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
                  'Cortar Mídia',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Seção de Seleção de Arquivo
            Card(
              child: ListTile(
                leading: const Icon(Icons.content_cut, color: Colors.orange),
                title: Text(state.selectedFilePath ?? 'Nenhum arquivo selecionado'),
                subtitle: Text(
                  state.totalDuration != null 
                    ? 'Duração total: ${state.totalDuration}' 
                    : 'Selecione o arquivo que deseja cortar',
                ),
                trailing: ElevatedButton(
                  onPressed: state.status == ProcessStatus.loading 
                    ? null 
                    : () => controller.pickFile(),
                  child: const Text('Selecionar'),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (state.selectedFilePath != null) ...[
              if (state.totalDuration != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 20, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Duração Total do Arquivo: ${state.totalDuration}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Text(
                'Defina o intervalo de corte:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startController,
                      decoration: const InputDecoration(
                        labelText: 'Início (HH:mm:ss)',
                        border: OutlineInputBorder(),
                        hintText: '00:00:00',
                      ),
                      onChanged: (val) => controller.updateTimes(start: val),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duração (HH:mm:ss ou segundos)',
                        border: OutlineInputBorder(),
                        hintText: '00:00:10',
                      ),
                      onChanged: (val) => controller.updateTimes(dur: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Nota: O tempo de início indica onde o corte começa, e a duração indica quanto tempo será extraído.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 48),
              
              Center(
                child: Column(
                  children: [
                    if (state.status == ProcessStatus.loading)
                      const Column(
                        children: [
                          CircularProgressIndicator(color: Colors.orange),
                          SizedBox(height: 16),
                          Text('Cortando mídia... Isso costuma ser instantâneo.'),
                        ],
                      )
                    else if (state.status == ProcessStatus.success)
                      const Text(
                        '✅ Corte concluído com sucesso!',
                        style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    else if (state.status == ProcessStatus.error)
                      Text(
                        '❌ Erro: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => controller.startCut(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.cut),
                        label: const Text('INICIAR CORTE', style: TextStyle(fontSize: 16)),
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
