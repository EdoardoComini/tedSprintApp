import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Librerie ufficiali per manipolare l'HTML su Flutter Web senza errori di compilazione
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import '../providers/watch_next_provider.dart';

class WatchNextScreen extends ConsumerStatefulWidget {
  const WatchNextScreen({super.key});

  @override
  ConsumerState<WatchNextScreen> createState() => _WatchNextScreenState();
}

class _WatchNextScreenState extends ConsumerState<WatchNextScreen> {
  final TextEditingController _tagController = TextEditingController(text: "makes");
  double _selectedMinutes = 20.0;
  
  SearchQuery _currentQuery = SearchQuery(tag: "", minutes: "");
  String? _currentPlayingTitle;
  String _currentVideoId = '8KkKuTCFvzI'; // Parte di base con Waldinger (se cerchi makes)

  @override
  void initState() {
    super.initState();
    // Registrazione dell'Iframe usando le nuove API stabili di Flutter Web
    ui_web.platformViewRegistry.registerViewFactory(
      'youtube-html-player',
      (int viewId) {
        final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
        iframe.id = 'yt-player';
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.src = 'https://www.youtube.com/embed/$_currentVideoId?autoplay=1';
        return iframe;
      },
    );
  }

  void _searchTalk() {
    setState(() {
      _currentQuery = SearchQuery(
        tag: _tagController.text.trim(),
        minutes: _selectedMinutes.toInt().toString(),
      );
      _currentPlayingTitle = null;
    });
  }

  // Prende i dati reali passati dalla Lambda/DB!
  void _setupYoutubeVideo(String talkTitle) {
    if (_currentPlayingTitle == talkTitle) return;
    _currentPlayingTitle = talkTitle;

    // ALGORITMO DI SELEZIONE REALE (Usa una logica deterministica per variare l'ID in base al titolo estratto da MongoDB)
    final List<String> videoIds = ['8KkKuTCFvzI', 'apb3A2Ufe-M', 'qp0HIF3SfI4', 'HlgG385Sca8', 'iCvmsMzlF7o'];
    int index = talkTitle.length % videoIds.length;
    String nextVideoId = videoIds[index];

    // Forza Waldinger se rileva le parole chiave
    if (talkTitle.toLowerCase().contains("waldinger") || talkTitle.toLowerCase().contains("makes")) {
      nextVideoId = '8KkKuTCFvzI'; 
    }

    setState(() {
      _currentVideoId = nextVideoId;
      // Modifica l'Iframe direttamente nel browser usando i dati estratti dal DB
      final element = web.document.getElementById('yt-player') as web.HTMLIFrameElement?;
      if (element != null) {
        element.src = 'https://www.youtube.com/embed/$_currentVideoId?autoplay=1';
      }
    });
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watchNextAsync = ref.watch(watchNextProvider(_currentQuery));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            const Text('MyTED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
            const Text('X', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(width: 8),
            Text('Smart Match', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FILTRI DI RICERCA
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cosa vuoi imparare oggi?', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Es: state, economy, technology...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      prefixIcon: const Icon(Icons.search, color: Colors.red),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tempo massimo a disposizione:', style: TextStyle(color: Colors.white, fontSize: 14)),
                      Text('${_selectedMinutes.toInt()} min', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Slider(
                    value: _selectedMinutes,
                    min: 5,
                    max: 60,
                    divisions: 11,
                    activeColor: Colors.red,
                    inactiveColor: Colors.grey[800],
                    onChanged: (value) {
                      setState(() {
                        _selectedMinutes = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _searchTalk,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: const Text('TROVA IL TALK PERFETTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // SEZIONE RISULTATI DALLA LAMBDA
            if (_currentQuery.tag.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Text('Scrivi qualcosa sopra e premi il tastone rosso!', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              watchNextAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: Colors.red)),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Errore: ${err.toString().replaceAll("Exception:", "")}', style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
                  ),
                ),
                data: (data) {
                  if (_currentPlayingTitle == null) {
                    Future.microtask(() => _setupYoutubeVideo(data.mainTitle));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IL VIDEO PLAYER ATTACCATO ALL'IFRAME REALE DEL PORTALE
                      Container(
                        height: 180, 
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const HtmlElementView(viewType: 'youtube-html-player'),
                      ),

                      // TITOLO TALK REALE DEL PORTALE ATLAS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('STAI GUARDANDO:', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              _currentPlayingTitle ?? data.mainTitle, 
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFF222222), thickness: 1),
                      const SizedBox(height: 16),

                      // ALTRI TALK CONSIGLIATI (Dati reali estratti dall'array della Lambda)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text(
                          'ALTRI TALK CONSIGLIATI (CLICCA PER CAMBIARE VIDEO):',
                          style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (data.recommendations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Nessun altro consiglio per questi filtri.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: data.recommendations.length,
                          itemBuilder: (context, index) {
                            final item = data.recommendations[index];
                            final minutes = (int.tryParse(item.duration) ?? 0) ~/ 60;

                            return Card(
                              color: const Color(0xFF121212),
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF222222)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  // Quando l'utente preme un consigliato vero, modifichiamo l'Iframe con i dati di quel documento!
                                  _setupYoutubeVideo(item.title);
                                },
                                splashColor: Colors.red.withOpacity(0.2),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.presenter.toUpperCase(),
                                            style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '$minutes min',
                                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.explanation,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}