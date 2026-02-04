import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:serverpod/serverpod.dart';

class RecipesEndpoint extends Endpoint {
  Future<String> generateRecipe(Session session, String ingredients) async {
    final geminiApiKey = session.passwords['gemini'];

    if (geminiApiKey == null) {
      throw Exception('Gemini API key not found');
    }
    final gemini = GenerativeModel(
      model: 'models/gemini-2.5-flash',
      apiKey: geminiApiKey,
    );

    final prompt =
        'Generate a recipe using the following ingredients: $ingredients, always put name of the recipe in the first line, and then the instructions. The recipe instructions to follow and include all the necessary steps. Please provide a detailed response.';

    final response = await gemini.generateContent([Content.text(prompt)]);

    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      throw Exception('No response from Gemini API');
    }

    return responseText;
  }
}
