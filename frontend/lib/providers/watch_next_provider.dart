
Dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/watch_next_model.dart';

final watchNextProvider = FutureProvider.family<WatchNextResponse, String>((ref, idx) async {
  final url = Uri.parse('https://tuo-api-gateway.amazonaws.com/dev/watchnext?idx=\$idx');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return WatchNextResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Errore AWS');
  }
});
