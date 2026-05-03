import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/ffmpeg/ffmpeg_providers.dart';

/// Representa o estado de um arquivo individual na fila.
enum BatchItemStatus { pending, processing, completed, error }

class BatchItem {
  final String path;
  final BatchItemStatus status;
  final String? error;

  BatchItem({required this.path, this.status = BatchItemStatus.pending, this.error});

  BatchItem copyWith({BatchItemStatus? status, String? error}) {
    return BatchItem(
      path: path,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

/// Estado da tela de processamento em lote.
class BatchState {
  final List<BatchItem> items;
  final bool isProcessing;
  final String targetExtension;

  BatchState({
    this.items = const [],
    this.isProcessing = false,
    this.targetExtension = '.mp3',
  });

  BatchState copyWith({
    List<BatchItem>? items,
    bool? isProcessing,
    String? targetExtension,
  }) {
    return BatchState(
      items: items ?? this.items,
      isProcessing: isProcessing ?? this.isProcessing,
      targetExtension: targetExtension ?? this.targetExtension,
    );
  }
}

class BatchNotifier extends StateNotifier<BatchState> {
  final Ref _ref;

  BatchNotifier(this._ref) : super(BatchState());

  /// Seleciona múltiplos arquivos para a fila.
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      final newItems = result.files
          .where((f) => f.path != null)
          .map((f) => BatchItem(path: f.path!))
          .toList();
      
      state = state.copyWith(items: [...state.items, ...newItems]);
    }
  }

  void updateTargetExtension(String ext) {
    state = state.copyWith(targetExtension: ext);
  }

  void removeItem(int index) {
    final newList = List<BatchItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: newList);
  }

  /// Inicia o processamento sequencial da fila.
  Future<void> startBatch() async {
    if (state.items.isEmpty || state.isProcessing) return;

    state = state.copyWith(isProcessing: true);
    final service = _ref.read(ffmpegServiceProvider);

    for (int i = 0; i < state.items.length; i++) {
      if (state.items[i].status == BatchItemStatus.completed) continue;

      // Atualiza status para processando
      _updateItemStatus(i, BatchItemStatus.processing);

      try {
        final inputPath = state.items[i].path;
        final directory = p.dirname(inputPath);
        final fileName = p.basenameWithoutExtension(inputPath);
        final outputPath = p.join(directory, '${fileName}_batch${state.targetExtension}');

        await service.convert(inputPath, outputPath);
        _updateItemStatus(i, BatchItemStatus.completed);
      } catch (e) {
        _updateItemStatus(i, BatchItemStatus.error, error: e.toString());
      }
    }

    state = state.copyWith(isProcessing: false);
  }

  void _updateItemStatus(int index, BatchItemStatus status, {String? error}) {
    final newList = List<BatchItem>.from(state.items);
    newList[index] = newList[index].copyWith(status: status, error: error);
    state = state.copyWith(items: newList);
  }

  void reset() {
    state = BatchState();
  }
}

final batchProvider = StateNotifierProvider<BatchNotifier, BatchState>((ref) {
  return BatchNotifier(ref);
});
