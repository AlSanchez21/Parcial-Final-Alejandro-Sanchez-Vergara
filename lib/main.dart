import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Nombres',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: MyHomePage(),
    );
  }
}

final myAppStateProvider = StateNotifierProvider<MyAppState, MyAppStateData>((ref) => MyAppState());

class MyAppState extends StateNotifier<MyAppStateData> {
  MyAppState() : super(MyAppStateData.initial()); // 

  void getNext() {
    state = state.copyWith(current: WordPair.random());
  }

  void toggleFavorite() {
    final updatedFavorites = List.of(state.favorites);
    if (updatedFavorites.contains(state.current)) {
      updatedFavorites.remove(state.current);
    } else {
      updatedFavorites.add(state.current);
    }
    state = state.copyWith(favorites: updatedFavorites);
  }

  void updateSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

class MyAppStateData {
  final WordPair current;
  final List<WordPair> favorites;
  final int selectedIndex;

  MyAppStateData({
    required this.current,
    required this.favorites,
    required this.selectedIndex,
  });

  factory MyAppStateData.initial() {
    return MyAppStateData(
      current: WordPair.random(),
      favorites: [],
      selectedIndex: 0,
    );
  }

  MyAppStateData copyWith({WordPair? current, List<WordPair>? favorites, int? selectedIndex}) {
    return MyAppStateData(
      current: current ?? this.current,
      favorites: favorites ?? List.from(this.favorites),
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class MyHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(myAppStateProvider);
    final notifier = ref.read(myAppStateProvider.notifier);
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Inicio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favoritos'),
                ),
              ],
              selectedIndex: appState.selectedIndex,
              onDestinationSelected: notifier.updateSelectedIndex,
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: appState.selectedIndex == 0 ? GeneratorPage() : FavoritesPage(),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(myAppStateProvider);
    final notifier = ref.read(myAppStateProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: appState.current),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: notifier.toggleFavorite,
                icon: Icon(
                  appState.favorites.contains(appState.current)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                label: const Text('Me gusta'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: notifier.getNext,
                child: const Text('Siguiente'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(myAppStateProvider);

    if (appState.favorites.isEmpty) {
      return const Center(
        child: Text('Aún no tienes favoritos.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Tienes ${appState.favorites.length} favoritos:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(pair.toString()),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});
  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.toString(),
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}