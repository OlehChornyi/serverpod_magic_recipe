// import 'package:dartantic_ai/dartantic_ai.dart';
// import 'package:magic_recipe_server/src/generated/protocol.dart';
// import 'package:serverpod/serverpod.dart';

// abstract class RecipeAIService {
//   const RecipeAIService();

//   factory RecipeAIService.fromApiKey(String apiKey) {
//     return ProductionRecipeAIService(apiKey: apiKey);
//   }
// }

// class ProductionRecipeAIService extends RecipeAIService {
//   ProductionRecipeAIService({
//     required String apiKey,
//     String modelName = 'models/gemini-2.5-flash',
//   }) : _agent = _createAgent(apiKey, modelName);

//   final Agent _agent;

//   static Agent _createAgent(String apiKey, String modelName) {
//     Agent.environment['GEMINI_API_KEY'] = apiKey;
//     return Agent.forProvider(
//       Providers.google,
//       chatModelName: modelName,
//     );
//   }

//   @override
//   Future<Recipe> generateRecipe(
//     Session session,
//     String ingredients,
//   ) async {
//     _validateIngredients(ingredients);

//     final history = <ChatMessage>[
//       ChatMessage.user(_buildTextPrompt(ingredients)),
//     ];

//     final response = await _agent.generateMedia(
//       '',
//       mimeTypes: [],
//       history: history,
//       attachments: [],
//     );

//     if (response.output.isEmpty) {
//       throw Exception('Empty response from AI service');
//     }

//     final recipe = Recipe(
//       author: 'Gemini',
//       text: response.output.text,
//       date: DateTime.now(),
//       ingredients: ingredients,
//     );

//     return recipe;
//   }

//   void _validateIngredients(String ingredients) {
//     if (ingredients.trim().isEmpty) {
//       throw Exception('Ingredients cannot be empty');
//     }
//   }

//   String _buildTextPrompt(String ingredients) {
//     return '''
// Create a recipe using these ingredients: $ingredients

// Please provide:
// - A creative recipe name
// - A list of all ingredients needed (including amounts)
// - Step-by-step cooking instructions
// - Estimated cooking time
// - Number of servings

// Make it delicious and creative!
// ''';
//   }
// }
