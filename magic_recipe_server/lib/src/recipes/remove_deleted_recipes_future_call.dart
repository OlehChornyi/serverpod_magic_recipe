import 'package:magic_recipe_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class RemoveDeletedRecipesFutureCall extends FutureCall {
  @override
  Future<void> invoke(Session session, SerializableModel? _) async {
    final deletedRecipes = await Recipe.db.deleteWhere(
      session,
      where: (RecipeTable recipe) => recipe.deletedAt.notEquals(null),
    );

    session.log('Deleted ${deletedRecipes.length} recipes during cleanup');
  }
}
