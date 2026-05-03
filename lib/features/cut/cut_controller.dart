import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/ffmpeg/ffmpeg_providers.dart';

/// Classe de estado específica para o corte, incluindo tempos de início e duração.
class CutState extends MediaState {
  final String startTime;
  final String duration;
  final String? totalDuration;

  CutState({
    super.status,
    super.errorMessage,
    super.selectedFilePath,
    this.startTime = '00:00:00',
    this.duration = '00:00:10',
    this.totalDuration,
  });

  @override
  CutState copyWith({
    ProcessStatus? status,
    String? errorMessage,
    String? selectedFilePath,
    String? startTime,
    String? duration,
    String? totalDuration,
  }) {
    return CutState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

/// Notifier que gerencia a lógica da funcionalidade de corte.
class CutNotifier extends StateNotifier<CutState> {
  final Ref _ref;

  CutNotifier(this._ref) : super(CutState());

  /// Seleciona um arquivo de mídia para cortar.
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      
      state = state.copyWith(
        selectedFilePath: path,
        status: ProcessStatus.idle,
        errorMessage: null,
      );

      // Busca a duração total da mídia selecionada
      try {
        final service = _ref.read(ffmpegServiceProvider);
        final total = await service.getDuration(path);
        state = state.copyWith(totalDuration: total);
      } catch (e) {
        // Se falhar ao pegar a duração, apenas ignoramos para não travar o app
      }
    }
  }

  /// Inicia o processo de corte.
  Future<void> startCut() async {
    if (state.selectedFilePath == null) return;

    state = state.copyWith(status: ProcessStatus.loading);

    try {
      final service = _ref.read(ffmpegServiceProvider);
      
      final inputPath = state.selectedFilePath!;
      final directory = p.dirname(inputPath);
      final fileName = p.basenameWithoutExtension(inputPath);
      final extension = p.extension(inputPath);
      
      // Cria o caminho de saída: pasta_original/nome_original_cortado.ext
      final outputPath = p.join(directory, '${fileName}_cortado$extension');

      await service.cut(
        inputPath, 
        outputPath, 
        state.startTime, 
        state.duration,
      );

      state = state.copyWith(status: ProcessStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: ProcessStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void updateTimes({String? start, String? dur}) {
    state = state.copyWith(
      startTime: start ?? state.startTime,
      duration: dur ?? state.duration,
    );
  }

  void reset() {
    state = CutState();
  }
}

/// Provider para o CutNotifier.
final cutProvider = StateNotifierProvider<CutNotifier, CutState>((ref) {
  return CutNotifier(ref);
});
