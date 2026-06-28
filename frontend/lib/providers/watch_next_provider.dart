import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/watch_next_model.dart'; // Verifica che il percorso sia corretto

// Creiamo una classe di supporto per passare due parametri insieme al provider
class SearchQuery {
  final String tag;
  final String minutes;
  SearchQuery({required this.tag, required this.minutes});
}

final watchNextProvider = FutureProvider.family<WatchNextResponse, SearchQuery>((ref, query) async {
  // Se l'utente non ha digitato nulla, evitiamo di sparare la chiamata a vuoto
  if (query.tag.isEmpty || query.minutes.isEmpty) {
    return WatchNextResponse(mainTitle: "Inserisci argomento e minuti per iniziare", recommendations: []);
  }

  final url = "https://hl4wurb5o1.execute-api.us-east-1.amazonaws.com/default/Get_Watch_Next_by_Idx?tag=${query.tag}&minutes=${query.minutes}";
  
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return WatchNextResponse.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 404) {
    throw Exception("Nessun talk trovato con questi criteri.");
  } else {
    throw Exception("Errore di comunicazione con il server.");
  }
});