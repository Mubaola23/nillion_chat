import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:nillion_chat/model/ai_message_response.dart';

class NillionApiService {
  static const String baseUrl = 'https://nilai-a779.nillion.network/v1/chat';
  static const String apiKey = 'Nillion2025';

  static Future<List<Choice>> sendMessage(String message) async {
    try {
      final prompt = message.toLowerCase().contains('nillion')
          ? ' $message using https://nillion.com/ as reference'
          : message;
      final response = await http.post(
        Uri.parse('$baseUrl/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "meta-llama/Llama-3.1-8B-Instruct",
          "messages": [
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.2,
          "top_p": 0.95,
          "max_tokens": 2048,
          "stream": false,
          "nilrag": {},
        }),
      );

      debugPrint(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cleanedResponse = AiMessageResponse.fromJson(data);
        return cleanedResponse.choices;
      }
    } catch (e) {
      debugPrint('Error storing message: $e');
    }
    return [];
  }
}
