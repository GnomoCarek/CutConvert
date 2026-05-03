import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

/// Serviço responsável por gerenciar e executar comandos do FFmpeg.
class FFmpegService {
  String? _ffmpegPath;

  /// Inicializa o serviço, garantindo que os binários estejam disponíveis no sistema.
  /// Como estamos usando a abordagem 'Bundled', extraímos o executável dos assets
  /// para uma pasta de suporte da aplicação no primeiro uso.
  Future<void> initialize() async {
    if (_ffmpegPath != null) return;

    final supportDir = await getApplicationSupportDirectory();
    final binDir = Directory(p.join(supportDir.path, 'bin'));
    
    if (!await binDir.exists()) {
      await binDir.create(recursive: true);
    }

    // Caminho onde o executável ficará no Windows
    final ffmpegFile = File(p.join(binDir.path, 'ffmpeg.exe'));

    // Se não existir, extrai dos assets
    if (!await ffmpegFile.exists()) {
      try {
        final byteData = await rootBundle.load('assets/bin/ffmpeg.exe');
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        await ffmpegFile.writeAsBytes(bytes);
      } catch (e) {
        throw Exception('Erro ao carregar binário do FFmpeg dos assets: $e');
      }
    }

    _ffmpegPath = ffmpegFile.path;
  }

  /// Obtém a duração total de um arquivo de mídia em formato HH:mm:ss.
  Future<String> getDuration(String filePath) async {
    if (_ffmpegPath == null) await initialize();

    final ffprobePath = _ffmpegPath!.replaceAll('ffmpeg.exe', 'ffprobe.exe');
    final shell = Shell();
    
    // Comando para pegar a duração em segundos
    final result = await shell.run(
      '$ffprobePath -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$filePath"'
    );

    final durationSeconds = double.tryParse(result.first.stdout.toString().trim()) ?? 0;
    
    // Converte segundos para HH:mm:ss
    final duration = Duration(seconds: durationSeconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return "$hours:$minutes:$seconds";
  }

  /// Comprime um vídeo para um tamanho alvo em MB.
  Future<void> compressVideo(String inputPath, String outputPath, int targetSizeMB) async {
    if (_ffmpegPath == null) await initialize();

    final shell = Shell();
    
    // 1. Pegar a duração em segundos para calcular o bitrate
    final ffprobePath = _ffmpegPath!.replaceAll('ffmpeg.exe', 'ffprobe.exe');
    final probeResult = await shell.run(
      '$ffprobePath -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$inputPath"'
    );
    final duration = double.tryParse(probeResult.first.stdout.toString().trim()) ?? 0;
    
    if (duration <= 0) throw Exception('Não foi possível determinar a duração do vídeo.');

    // 2. Calcular o bitrate total necessário (em bits por segundo)
    // Tamanho alvo em bits = MB * 1024 * 1024 * 8
    final targetSizeBits = targetSizeMB * 1024 * 1024 * 8;
    // Deixamos uma margem de segurança de 10% para o container e áudio
    final totalBitrate = (targetSizeBits * 0.9) / duration;
    
    // Bitrate de vídeo (subtraindo ~128kbps para o áudio)
    int videoBitrate = (totalBitrate - 128000).toInt();
    if (videoBitrate < 100000) videoBitrate = 100000; // Mínimo de 100kbps

    // 3. Executar compressão em um único passo (para MVP)
    // Usamos H.264 e AAC para máxima compatibilidade com WhatsApp
    // -pix_fmt yuv420p é crucial para rodar em iPhones e alguns Androids antigos
    await shell.run(
      '$_ffmpegPath -i "$inputPath" -c:v libx264 -b:v $videoBitrate -pass 1 -an -f mp4 NUL && ' '$_ffmpegPath -i "$inputPath" -c:v libx264 -b:v $videoBitrate -pass 2 -c:a aac -b:a 128k -pix_fmt yuv420p "$outputPath"'
    );
    
    // Limpar arquivos temporários do pass log se existirem
    final ffmpeg2pass = File('ffmpeg2pass-0.log');
    if (await ffmpeg2pass.exists()) await ffmpeg2pass.delete();
  }

  /// Extrai o áudio de um vídeo.
  /// Se [originalCodec] for true, tenta manter o codec original (mais rápido).
  Future<void> extractAudio(String inputPath, String outputPath) async {
    if (_ffmpegPath == null) await initialize();

    final shell = Shell();
    // Comando: ffmpeg -i entrada -vn -acodec copy ou mp3 dependendo da extensão
    // -vn remove o vídeo.
    final extension = p.extension(outputPath).toLowerCase();
    
    if (extension == '.mp3') {
      // Para MP3 geralmente precisamos recodificar para garantir compatibilidade
      await shell.run('$_ffmpegPath -i "$inputPath" -vn -ar 44100 -ac 2 -b:a 192k "$outputPath"');
    } else {
      // Tenta extração direta (copy) para outros formatos
      await shell.run('$_ffmpegPath -i "$inputPath" -vn -acodec copy "$outputPath"');
    }
  }

  /// Executa um comando de conversão simples.
  /// [inputPath]: Caminho do arquivo de origem.
  /// [outputPath]: Caminho do arquivo de destino.
  Future<void> convert(String inputPath, String outputPath) async {
    if (_ffmpegPath == null) await initialize();

    final shell = Shell();
    // Comando básico: ffmpeg -i entrada.mp4 saida.mkv
    await shell.run('$_ffmpegPath -i "$inputPath" "$outputPath"');
  }

  /// Executa um comando de corte de vídeo.
  /// [startTime]: Formato "HH:mm:ss"
  /// [duration]: Formato "HH:mm:ss" ou segundos.
  Future<void> cut(String inputPath, String outputPath, String startTime, String duration) async {
    if (_ffmpegPath == null) await initialize();

    final shell = Shell();
    // Comando básico: ffmpeg -ss início -i entrada -t duração -c copy saida
    await shell.run('$_ffmpegPath -ss $startTime -i "$inputPath" -t $duration -c copy "$outputPath"');
  }
}
