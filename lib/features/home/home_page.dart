import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../convert/convert_page.dart';
import '../cut/cut_page.dart';
import '../extract/extract_page.dart';
import '../compress/compress_page.dart';
import '../batch/batch_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Início'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.transform_outlined),
                selectedIcon: Icon(Icons.transform),
                label: Text('Converter'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.content_cut_outlined),
                selectedIcon: Icon(Icons.content_cut),
                label: Text('Cortar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.audiotrack_outlined),
                selectedIcon: Icon(Icons.audiotrack),
                label: Text('Extrair Áudio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.compress_outlined),
                selectedIcon: Icon(Icons.compress),
                label: Text('Comprimir'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.queue_outlined),
                selectedIcon: Icon(Icons.queue),
                label: Text('Fila'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _HomeContent(
                  onNavigateToConvert: () => setState(() => _selectedIndex = 1),
                  onNavigateToCut: () => setState(() => _selectedIndex = 2),
                  onNavigateToExtract: () => setState(() => _selectedIndex = 3),
                  onNavigateToCompress: () => setState(() => _selectedIndex = 4),
                  onNavigateToBatch: () => setState(() => _selectedIndex = 5),
                ),
                const ConvertPage(),
                const CutPage(),
                const ExtractPage(),
                const CompressPage(),
                const BatchPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final VoidCallback onNavigateToConvert;
  final VoidCallback onNavigateToCut;
  final VoidCallback onNavigateToExtract;
  final VoidCallback onNavigateToCompress;
  final VoidCallback onNavigateToBatch;

  const _HomeContent({
    required this.onNavigateToConvert,
    required this.onNavigateToCut,
    required this.onNavigateToExtract,
    required this.onNavigateToCompress,
    required this.onNavigateToBatch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/CutConvert.png',
                  height: 64,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.video_settings, size: 64, color: Colors.deepPurple),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CutConvert',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text('Sua ferramenta de mídia completa'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _MenuCard(
                  title: 'Converter Mídia',
                  description: 'Mude o formato de seus arquivos (MP4, MKV, M4A, MP3, etc).',
                  icon: Icons.auto_fix_high,
                  color: Colors.blue,
                  onTap: onNavigateToConvert,
                ),
                _MenuCard(
                  title: 'Cortar Mídia',
                  description: 'Remova partes indesejadas ou extraia clipes de áudio e vídeo.',
                  icon: Icons.movie_edit,
                  color: Colors.orange,
                  onTap: onNavigateToCut,
                ),
                _MenuCard(
                  title: 'Extrair Áudio',
                  description: 'Remova o vídeo e salve apenas a trilha sonora em MP3 ou original.',
                  icon: Icons.music_note,
                  color: Colors.purple,
                  onTap: onNavigateToExtract,
                ),
                _MenuCard(
                  title: 'Compressão Inteligente',
                  description: 'Reduza o tamanho para WhatsApp ou Discord (H.264/AAC).',
                  icon: Icons.compress,
                  color: Colors.green,
                  onTap: onNavigateToCompress,
                ),
                _MenuCard(
                  title: 'Fila de Mídia',
                  description: 'Converta dezenas de arquivos M4A para MP3 de uma só vez.',
                  icon: Icons.library_music,
                  color: Colors.indigo,
                  onTap: onNavigateToBatch,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
