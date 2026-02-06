import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:magic_recipe_server/src/generated/protocol.dart';
import 'package:meta/meta.dart';
import 'package:serverpod/serverpod.dart';

@visibleForTesting
var generateContent = (String apiKey, String prompt) async =>
    (await GenerativeModel(
      model: 'models/gemini-2.5-flash',
      apiKey: apiKey,
    ).generateContent([Content.text(prompt)])).text;

class RecipesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<Recipe> generateRecipe(Session session, String ingredients) async {
    final geminiApiKey = session.passwords['gemini'];

    if (geminiApiKey == null) {
      throw Exception('Gemini API key not found');
    }

    final cacheKey = 'recipe-${ingredients.hashCode}';
    final cachedRecipe = await session.caches.local.get<Recipe>(cacheKey);

    if (cachedRecipe != null) {
      final userId = session.authenticated?.userIdentifier;
      session.log('Recipe found in cache for ingredients: $ingredients');
      cachedRecipe.userId = userId;
      final recipeWithId = await Recipe.db.insertRow(
        session,
        cachedRecipe.copyWith(userId: userId),
      );

      return recipeWithId;
    }

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

    final responseText = await generateContent(geminiApiKey, prompt);

    if (responseText == null || responseText.isEmpty) {
      throw Exception('No response from Gemini API');
    }

    final userId = session.authenticated?.userIdentifier;

    final recipe = Recipe(
      author: 'Gemini',
      text: responseText,
      date: DateTime.now(),
      ingredients: ingredients,
    );

    await session.caches.local.put(
      cacheKey,
      recipe,
      lifetime: const Duration(days: 1),
    );

    final recipeWithId = await Recipe.db.insertRow(
      session,
      recipe.copyWith(userId: userId),
    );

    return recipeWithId;
  }

  Future<List<Recipe>> getRecipes(Session session) async {
    final userId = session.authenticated?.userIdentifier;

    return await Recipe.db.find(
      session,
      where: (t) => t.deletedAt.equals(null) & t.userId.equals(userId),
      orderBy: (t) => t.date,
      orderDescending: true,
    );
  }

  Future<void> deleteRecipe(Session session, int recipeId) async {
    final userId = session.authenticated?.userIdentifier;

    final recipe = await Recipe.db.findById(session, recipeId);
    if (recipe == null || recipe.userId != userId) {
      throw Exception('Recipe not found');
    }
    recipe.deletedAt = DateTime.now();
    await Recipe.db.updateRow(session, recipe);
  }
}
