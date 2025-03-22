# Tests unitaires

Le fichier `_endpoints.dart` contient des fonctions qui permettent de faire des requêtes HTTP vers les différents endpoints de l'API. Lorsque vous aurez implémenté les endpoints dans votre modèle, vous pourrez les tester en utilisant ces fonctions et supprimer ce fichier.

**Remarque** : L'accès concurrenciel à Hive n'est pas supporté. Il est donc nécessaire de donner instruction à dart d'exécuter les tests de manière séquentielle. Pour ce faire, il suffit de rajouter le paramètre `--concurrency=1` à la commande flutter test dans la configuration.
