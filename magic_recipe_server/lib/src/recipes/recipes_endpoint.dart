import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:magic_recipe_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class RecipesEndpoint extends Endpoint {
  Future<Recipe> generateRecipe(Session session, String ingredients) async {
    final geminiApiKey = session.passwords['gemini'];

    if (geminiApiKey == null) {
      throw Exception('Gemini API key not found');
    }
    final gemini = GenerativeModel(
      model: 'models/gemini-2.5-flash',
      apiKey: geminiApiKey,
    );

    final prompt =
        '''
Create a recipe using these ingredients: $ingredients

Please provide:
- A creative recipe name (should always be in first place in your response)
- A list of all ingredients needed (including amounts)
- Step-by-step cooking instructions
- Estimated cooking time
- Number of servings

Make it delicious and creative!
''';

    final response = await gemini.generateContent([Content.text(prompt)]);

    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      throw Exception('No response from Gemini API');
    }

    final recipe = Recipe(
      author: 'Gemini',
      text: responseText,
      date: DateTime.now(),
      ingredients: ingredients,
    );

    final recipeWithId = await Recipe.db.insertRow(session, recipe);

    return recipeWithId;
  }

  Future<List<Recipe>> getRecipes(Session session) async {
    return await Recipe.db.find(
      session,
      orderBy: (t) => t.date,
      orderDescending: true,
    );
  }
}
