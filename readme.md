- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
serverpod create magic_recipe
cd magic_recipe
git init .
git add .
git commit -m "initial commit"
docker compose up -d
dart run bin/main.dart --apply-migrations
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
cd magic_recipe
cd magic_recipe_flutter
flutter run -d chrome
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
cd magic_recipe_server
//This command updates everything in our client and server directories
serverpod generate
dart pub add google_generative_ai
exit
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
cd magic_recipe_server
serverpod generate
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
cd magic_recipe_server
docker compose up -d
dart run bin/main.dart --apply-migrations
cd magic_recipe_flutter
flutter run -d chrome
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
table: recipe
cd magic_recipe_server
serverpod generate
serverpod create-migration
dart run bin/main.dart --apply-migrations
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
serverpod create-migration --force
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
chmod +x ./scripts/build_flutter_web
./scripts/build_flutter_web
