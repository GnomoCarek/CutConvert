import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/ffmpeg/ffmpeg_providers.dart';

class ExtractNotifier extends StateNotifier<MediaState> {
  final Ref _ref;

  ExtractNotifier(this._ref) : super(MediaState());

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video, // Foco em vídeos para extrair áudio
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

  Future<void> startExtraction(String targetExt) async {
    if (state.selectedFilePath == null) return;

    state = state.copyWith(status: ProcessStatus.loading);

    try {
      final service = _ref.read(ffmpegServiceProvider);
      
      final inputPath = state.selectedFilePath!;
      final directory = p.dirname(inputPath);
      final fileName = p.basenameWithoutExtension(inputPath);
      
      final outputPath = p.join(directory, '${fileName}_audio$targetExt');

      await service.extractAudio(inputPath, outputPath);

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

final extractProvider = StateNotifierProvider<ExtractNotifier, MediaState>((ref) {
  return ExtractNotifier(ref);
});
