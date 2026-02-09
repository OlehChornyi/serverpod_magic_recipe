import 'package:flutter/material.dart';
import 'package:magic_recipe_client/magic_recipe_client.dart';
import 'package:magic_recipe_flutter/widgets/image_upload_button.dart';

import '../main.dart';

class GreetingsScreen extends StatefulWidget {
  final Future<void> Function()? onSignOut;
  const GreetingsScreen({super.key, this.onSignOut});

  @override
  State<GreetingsScreen> createState() => _GreetingsScreenState();
}

class _GreetingsScreenState extends State<GreetingsScreen> {
  /// Holds the last result or null if no result exists yet.
  Recipe? _recipe;
  List<Recipe> _recipeHistory = [];

  /// Holds the last error message that we've received from the server or null
  /// if no error exists yet.
  String? _errorMessage;

  final _textEditingController = TextEditingController();
  String? _imagePath;
  bool _loading = false;

  void _callGenerateRecipe() async {
    try {
      setState(() {
        _errorMessage = null;
        _recipe = null;
        _loading = true;
      });
      final result = await client.recipes.generateRecipe(
        _textEditingController.text,
        _imagePath,
      );
      setState(() {
        _errorMessage = null;
        _recipe = result;
        _loading = false;
        _recipeHistory.insert(0, result);
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _recipe = null;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    client.recipes.getRecipes().then((favouriteRecipes) {
      setState(() {
        _recipeHistory = favouriteRecipes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.grey[300]),
            child: ListView.builder(
              itemCount: _recipeHistory.length,
              itemBuilder: (context, index) {
                final recipe = _recipeHistory[index];
                final firstLineEnd = recipe.text.indexOf('\n');
                final title = firstLineEnd != -1
                    ? recipe.text.substring(0, firstLineEnd)
                    : recipe.text;
                return ListTile(
                  title: Text(title),
                  subtitle: Text('${recipe.author} - ${recipe.date}'),
                  onTap: () {
                    setState(() {
                      _errorMessage = null;
                      _textEditingController.text = recipe.ingredients;
                      _imagePath = recipe.imagePath;
                      _recipe = recipe;
                    });
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await client.recipes.deleteRecipe(recipe.id!);
                      setState(() {
                        _recipeHistory.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (widget.onSignOut != null) ...[
                  const Text('You are connected'),
                  ElevatedButton(
                    onPressed: widget.onSignOut,
                    child: const Text('Sign out'),
                  ),
                ],
                const SizedBox(height: 32),
                TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your ingredients',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  spacing: 16,
                  children: [
                    ElevatedButton(
                      onPressed: _loading ? null : _callGenerateRecipe,
                      child: const Text('Send to Server'),
                    ),
                    ImageUploadButton(
                      key: ValueKey(_imagePath),
                      onImagePathChanged: (imagePath) {
                        setState(() {
                          _imagePath = imagePath;
                        });
                      },
                      imagePath: _imagePath,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: ResultDisplay(
                      resultMessage: _recipe != null
                          ? '${_recipe?.author} on ${_recipe?.date}:\n${_recipe?.text}'
                          : null,
                      errorMessage: _errorMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ResultDisplays shows the result of the call. Either the returned result
/// from the `example.greeting` endpoint method or an error message.
class ResultDisplay extends StatelessWidget {
  final String? resultMessage;
  final String? errorMessage;

  const ResultDisplay({super.key, this.resultMessage, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    if (errorMessage != null) {
      backgroundColor = Colors.red[300]!;
      text = errorMessage!;
    } else if (resultMessage != null) {
      backgroundColor = Colors.green[300]!;
      text = resultMessage!;
    } else {
      backgroundColor = Colors.grey[300]!;
      text = 'No server response yet.';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Container(
        color: backgroundColor,
        child: Center(child: Text(text)),
      ),
    );
  }
}
