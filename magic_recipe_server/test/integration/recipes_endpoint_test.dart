import 'package:magic_recipe_server/src/generated/recipes/recipe.dart';
import 'package:magic_recipe_server/src/recipes/recipes_endpoint.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Recipes Endpoint', (sessionBuilder, endpoints) {
    test(
      'When calling generateRecipe with ingredients gemini is called with a prompt which includes ingredients',
      () async {
        String capturedPrompt = '';

        generateContent = (_, prompt) {
          capturedPrompt = prompt;
          return Future.value('Mock Recipe');
        };

        final recipe = await endpoints.recipes.generateRecipe(
          sessionBuilder,
          'chicken, rice, broccoli',
        );
        expect(recipe.text, 'Mock Recipe');
        expect(capturedPrompt, contains('chicken, rice, broccoli'));
      },
    );

    test(
      'When calling getRecipies, all recipies that are not deleted are returned',
      () async {
        final session = sessionBuilder.build();

        await Recipe.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );

        final firstRecipe = Recipe(
          author: 'Gemini',
          text: 'Mock recipe 1',
          date: DateTime.now(),
          ingredients: 'Chicken, rice, broccoli',
        );

        await Recipe.db.insertRow(session, firstRecipe);

        final secondRecipe = Recipe(
          author: 'Gemini',
          text: 'Mock recipe 2',
          date: DateTime.now(),
          ingredients: 'Chicken, rice, broccoli',
        );

        await Recipe.db.insertRow(session, secondRecipe);

        final recipies = await endpoints.recipes.getRecipes(sessionBuilder);

        expect(recipies.length, 2);

        final recipeToDelete = await Recipe.db.findFirstRow(
          session,
          where: (t) => t.text.equals('Mock recipe 1'),
        );

        await endpoints.recipes.deleteRecipe(
          sessionBuilder,
          recipeToDelete!.id!,
        );

        final recipies2 = await endpoints.recipes.getRecipes(sessionBuilder);

        expect(recipies2[0].text, 'Mock recipe 2');
      },
    );
  });
}
