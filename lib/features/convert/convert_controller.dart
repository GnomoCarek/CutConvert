import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/ffmpeg/ffmpeg_providers.dart';

/// Notifier que gerencia a lógica da funcionalidade de conversão.
class ConvertNotifier extends StateNotifier<MediaState> {
  final Ref _ref;

  ConvertNotifier(this._ref) : super(MediaState());

  /// Seleciona um arquivo (vídeo ou áudio) do computador.
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Alterado para aceitar áudios também como M4A
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      state = state.copyWith(
        selectedFilePath: result.files.single.path,
        status: ProcessStatus.idle,
        errorMessage: null,
      );
    }
  }

  /// Inicia o processo de conversão para o formato desejado.
  Future<void> startConversion(String targetExtension) async {
    if (state.selectedFilePath == null) return;

    state = state.copyWith(status: ProcessStatus.loading);

    try {
      final service = _ref.read(ffmpegServiceProvider);
      
      final inputPath = state.selectedFilePath!;
      final directory = p.dirname(inputPath);
      final fileName = p.basenameWithoutExtension(inputPath);
      // Cria o caminho de saída: pasta_original/nome_original_convertido.ext
      final outputPath = p.join(directory, '${fileName}_convertido$targetExtension');

      await service.convert(inputPath, outputPath);

      state = state.copyWith(status: ProcessStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: ProcessStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = MediaState();
  }
}

/// Provider para o ConvertNotifier.
final convertProvider = StateNotifierProvider<ConvertNotifier, MediaState>((ref) {
  return ConvertNotifier(ref);
});
