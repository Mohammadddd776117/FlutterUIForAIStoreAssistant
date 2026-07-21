/// AI Service — interface prepared for Gemini API integration.
///
/// Architecture:
/// - [AiService] is the single entry-point for all AI features.
/// - [AiMessage] represents a chat turn (user or assistant).
/// - Image recognition and product understanding are declared as separate methods
///   for clean separation when implementing with Gemini Vision.
///
/// Security:
/// - The API key MUST be supplied at runtime via --dart-define or a secure vault.
/// - It is NEVER committed to source control.
/// - All requests are proxied through the app backend to avoid exposing the key
///   in client bundles (see _proxyRequest comment).
library;

class AiMessage {
  final String id;
  final String text;
  final AiRole role;
  final DateTime timestamp;
  final bool isError;

  const AiMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.isError = false,
  });

  AiMessage copyWith({String? text, bool? isError}) => AiMessage(
        id: id,
        text: text ?? this.text,
        role: role,
        timestamp: timestamp,
        isError: isError ?? this.isError,
      );
}

enum AiRole { user, assistant }

class AiProductSuggestion {
  final String productName;
  final String reason;
  final double? estimatedQuantity;

  const AiProductSuggestion({
    required this.productName,
    required this.reason,
    this.estimatedQuantity,
  });
}

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  // API key loaded from secure config — NEVER hardcoded here.
  // TODO: const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  // TODO: const String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  final List<AiMessage> _history = [];

  List<AiMessage> get history => List.unmodifiable(_history);

  void clearHistory() => _history.clear();

  /// Sends a text message and returns the assistant reply.
  /// Replace the stub with a real Gemini API call.
  Future<AiMessage> sendMessage(String userText, {Map<String, dynamic>? context}) async {
    final userMsg = AiMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      text: userText,
      role: AiRole.user,
      timestamp: DateTime.now(),
    );
    _history.add(userMsg);

    try {
      // TODO: Replace with real Gemini API call via backend proxy.
      // final payload = _buildPayload(userText, context);
      // final response = await _proxyRequest(payload);
      // final replyText = _extractText(response);
      await Future.delayed(const Duration(milliseconds: 900));
      final replyText = _demoReply(userText);

      final assistantMsg = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text: replyText,
        role: AiRole.assistant,
        timestamp: DateTime.now(),
      );
      _history.add(assistantMsg);
      return assistantMsg;
    } catch (e) {
      final errorMsg = AiMessage(
        id: 'err-${DateTime.now().millisecondsSinceEpoch}',
        text: 'Sorry, I encountered an error. Please try again.',
        role: AiRole.assistant,
        timestamp: DateTime.now(),
        isError: true,
      );
      _history.add(errorMsg);
      return errorMsg;
    }
  }

  /// Analyzes a product image and returns extracted product information.
  /// TODO: Implement with Gemini Vision API.
  Future<Map<String, dynamic>> analyzeProductImage(List<int> imageBytes) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'name': 'Detected Product',
      'category': 'General',
      'confidence': 0.0,
      'message': 'Image recognition not yet implemented. Connect Gemini Vision API.',
    };
  }

  /// Provides AI-driven inventory recommendations based on sales history.
  /// TODO: Wire to Gemini with business context from the backend.
  Future<List<AiProductSuggestion>> getRestockRecommendations(
    List<Map<String, dynamic>> inventorySnapshot,
  ) async {
    await Future.delayed(const Duration(milliseconds: 700));
    // Demo stubs — replace with real AI analysis
    return [
      const AiProductSuggestion(
        productName: 'Rice (5kg)',
        reason: 'High demand, low stock',
        estimatedQuantity: 50,
      ),
      const AiProductSuggestion(
        productName: 'Cooking Oil (1L)',
        reason: 'Top seller this week',
        estimatedQuantity: 30,
      ),
    ];
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  String _demoReply(String question) {
    final q = question.toLowerCase();
    if (q.contains('profit')) {
      return 'Based on today\'s sales, your estimated profit is YER 4,250. That\'s up 12% compared to yesterday. Your top profit driver is cooking oil.';
    }
    if (q.contains('order') || q.contains('stock')) {
      return 'I recommend ordering more Rice (5kg bags) and Cooking Oil (1L). Both are running low and are your best-selling items this week.';
    }
    if (q.contains('slow') || q.contains('not selling')) {
      return 'The slowest-moving products this week are canned sardines, biscuit assortments, and pomegranate juice. Consider a promotion or discount to clear stock.';
    }
    if (q.contains('sales') || q.contains('revenue')) {
      return 'Today\'s total sales revenue is YER 18,500, with 47 transactions. The busiest hour was 10:00–11:00 AM.';
    }
    return 'I\'m your AI store assistant. You can ask me about profits, inventory levels, slow-selling products, restock recommendations, and more. How can I help?';
  }
}
