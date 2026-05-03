import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ffmpeg/ffmpeg_service.dart';

/// Provider que fornece uma única instância do FFmpegService para o app todo.
final ffmpegServiceProvider = Provider<FFmpegService>((ref) {
  return FFmpegService();
});

/// Estado para controlar o carregamento dos comandos.
enum ProcessStatus { idle, loading, success, error }

/// Classe de estado para as operações de mídia.
class MediaState {
  final ProcessStatus status;
  final String? errorMessage;
  final String? selectedFilePath;

  MediaState({
    this.status = ProcessStatus.idle,
    this.errorMessage,
    this.selectedFilePath,
  });

  MediaState copyWith({
    ProcessStatus? status,
    String? errorMessage,
    String? selectedFilePath,
  }) {
    return MediaState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
    );
  }
}
