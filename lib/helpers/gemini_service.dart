import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService to = GeminiService._();
  GeminiService._();

  GenerativeModel? _model;
  
  // Set your real Gemini API key here
  static const String _apiKey = ""; 

  void init() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );
    }
  }

  /// Automatically generate sub-tags for a given parent category tag
  Future<List<String>> suggestSubTags(String parentTag) async {
    final String query = parentTag.trim().toUpperCase();

    // 1. Live Gemini Call if API Key exists
    if (_model != null) {
      final prompt = "Generate 5 popular product sub-tags in uppercase for a local retail shop in Bangladesh under the category: $query. Return ONLY a comma-separated list without any extra explanation, numbers or formatting.";
      try {
        final content = [Content.text(prompt)];
        final response = await _model!.generateContent(content);
        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!
              .split(',')
              .map((e) => e.trim().replaceAll(RegExp(r'[^A-Z0-9\s-]'), '').toUpperCase())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (e) {
        print("Gemini AI API error: $e. Falling back to local smart tags.");
      }
    }

    // 2. Smart Local Mock Fallback when API key is missing or offline
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network lag
    switch (query) {
      case "MEDICINE":
        return ["NAPA", "ALATROL", "CEPHADIN", "SERGEL", "FENADIN"];
      case "MOBILE":
        return ["CHARGER", "USB", "SCREEN-GUARD", "POWER-BANK", "EARPHONE"];
      case "GROCERY":
        return ["RICE", "SOAP", "SUGAR", "OIL", "ONION"];
      case "FOOD":
        return ["BURGER", "PIZZA", "BIRYANI", "CHICKEN", "FRIES"];
      case "ELECTRONICS":
        return ["BULB", "MULTI-PLUG", "BATTERY", "ADAPTER", "SWITCH"];
      case "HARDWARE":
        return ["HAMMER", "SCREW", "LOCK", "NAIL", "DRILL"];
      default:
        return ["ITEM-1", "ITEM-2", "ITEM-3", "ITEM-4", "ITEM-5"];
    }
  }

  /// Extracts the main category tag from a search query using Natural Language Processing
  Future<String> extractSearchTag(String rawQuery) async {
    final String cleanText = rawQuery.trim().toLowerCase();

    // 1. Live Gemini Call
    if (_model != null) {
      final prompt = "Analyze this user search query: '$cleanText'. Find the single most relevant product category tag from: MEDICINE, MOBILE, GROCERY, FOOD, ELECTRONICS, HARDWARE. Return ONLY the matched category name in uppercase. If no match, return OTHERS.";
      try {
        final content = [Content.text(prompt)];
        final response = await _model!.generateContent(content);
        if (response.text != null) {
          return response.text!.trim().toUpperCase();
        }
      } catch (e) {
        print("Gemini AI API error: $e");
      }
    }

    // 2. Smart Regex Matcher Fallback
    if (cleanText.contains("headache") || cleanText.contains("fever") || cleanText.contains("medicine") || cleanText.contains("napa") || cleanText.contains("alatrol")) {
      return "MEDICINE";
    }
    if (cleanText.contains("phone") || cleanText.contains("charge") || cleanText.contains("usb") || cleanText.contains("cable") || cleanText.contains("mobile")) {
      return "MOBILE";
    }
    if (cleanText.contains("rice") || cleanText.contains("soap") || cleanText.contains("oil") || cleanText.contains("grocery") || cleanText.contains("dal")) {
      return "GROCERY";
    }
    if (cleanText.contains("biryani") || cleanText.contains("food") || cleanText.contains("eat") || cleanText.contains("pizza") || cleanText.contains("burger")) {
      return "FOOD";
    }
    if (cleanText.contains("light") || cleanText.contains("bulb") || cleanText.contains("wire") || cleanText.contains("electronics")) {
      return "ELECTRONICS";
    }
    return "OTHERS";
  }
}
