import 'package:magic_recipe_server/src/generated/recipes/recipe.dart';
import 'package:magic_recipe_server/src/recipes/recipes_endpoint.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

Future expectException(
  Future<void> Function() function,
  Matcher matcher,
) async {
  late var actualException;

  try {
    await function();
  } catch (e) {
    actualException = e;
  }
  expect(actualException, matcher);
}

void main() {
  withServerpod('Given Recipes Endpoint', (unAuthsessionBuilder, endpoints) {
    test(
      'When calling generateRecipe with ingredients gemini is called with a prompt which includes ingredients',
      () async {
        final sessionBuilder = unAuthsessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo('1', {}),
        );

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
        final sessionBuilder = unAuthsessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo('1', {}),
        );

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
          userId: '1',
        );

        await Recipe.db.insertRow(session, firstRecipe);

        final secondRecipe = Recipe(
          author: 'Gemini',
          text: 'Mock recipe 2',
          date: DateTime.now(),
          ingredients: 'Chicken, rice, broccoli',
          userId: '1',
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

    test(
      'When deleting a recipe users can only delete their own recipes ',
      () async {
        final sessionBuilder = unAuthsessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo('1', {}),
        );

        final session = sessionBuilder.build();

        await Recipe.db.insert(session, [
          Recipe(
            author: 'Gemini',
            text: 'Mock recipe 1',
            date: DateTime.now(),
            ingredients: 'Chicken, rice, broccoli',
            userId: '1',
          ),
          Recipe(
            author: 'Gemini',
            text: 'Mock recipe 2',
            date: DateTime.now(),
            ingredients: 'Chicken, rice, broccoli',
            userId: '1',
          ),
          Recipe(
            author: 'Gemini',
            text: 'Mock recipe 3',
            date: DateTime.now(),
            ingredients: 'Chicken, rice, broccoli',
            userId: '1000',
          ),
        ]);

        final recipeToDelete = await Recipe.db.findFirstRow(
          session,
          where: (t) => t.text.equals('Mock recipe 1'),
        );

        await endpoints.recipes.deleteRecipe(
          sessionBuilder,
          recipeToDelete!.id!,
        );

        final recipeYouShouldntDelete = await Recipe.db.findFirstRow(
          session,
          where: (t) => t.text.equals('Mock recipe 3'),
        );

        await expectException(
          () => endpoints.recipes.deleteRecipe(
            sessionBuilder,
            recipeYouShouldntDelete!.id!,
          ),
          isA<Exception>(),
        );
      },
    );

    test(
      'When delete a recipe with unauthenticated user,an exception is thrown',
      () async {
        await expectException(
          () => endpoints.recipes.deleteRecipe(unAuthsessionBuilder, 1),
          isA<ServerpodUnauthenticatedException>(),
        );
      },
    );

    test(
      'When trying to generate a recipe as an unauthenticated user an exception is thrown',
      () async {
        await expectException(
          () => endpoints.recipes.generateRecipe(
            unAuthsessionBuilder,
            'chicken, rice, broccolo',
          ),
          isA<ServerpodUnauthenticatedException>(),
        );
      },
    );

    test(
      'When trying to get recipes as an unauthenticated user an exception is thrown',
      () async {
        await expectException(
          () => endpoints.recipes.getRecipes(unAuthsessionBuilder),
          isA<ServerpodUnauthenticatedException>(),
        );
      },
    );
  });
}
