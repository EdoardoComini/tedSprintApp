class WatchNextResponse {
  final String mainTitle;
  final List<RecommendedTalk> recommendations;

  WatchNextResponse({required this.mainTitle, required this.recommendations});

  factory WatchNextResponse.fromJson(Map<String, dynamic> json) {
    var list = json['recommendations'] as List? ?? [];
    List<RecommendedTalk> recs = list.map((i) => RecommendedTalk.fromJson(i)).toList();

    return WatchNextResponse(
      mainTitle: json['main_title'] ?? 'Talk sconosciuto',
      recommendations: recs,
    );
  }
}

class RecommendedTalk {
  final String title;
  final String presenter;
  final String duration;
  final String explanation;

  RecommendedTalk({
    required this.title,
    required this.presenter,
    required this.duration,
    required this.explanation,
  });

  factory RecommendedTalk.fromJson(Map<String, dynamic> json) {
    return RecommendedTalk(
      title: json['related_title'] ?? 'Nessun titolo',
      presenter: json['related_presenter'] ?? 'Autore sconosciuto',
      duration: json['related_duration']?.toString() ?? '0',
      explanation: json['explanation'] ?? 'Consigliato per affinità tematica.',
    );
  }
}