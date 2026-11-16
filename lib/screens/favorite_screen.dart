import 'package:flutter/material.dart';
import '../stores/favorite_store.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoriteStore.instance,
      builder: (context, _) {
        final favorites = FavoriteStore.instance.favorites;

        if (favorites.isEmpty) {
          return const EmptyView(
            icon: Icons.favorite_border_rounded,
            iconColor: AppColors.mint,
            title: 'Belum ada karakter favorit',
            subtitle: 'Tap ♡ pada karakter untuk menyimpannya',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final character = favorites[index];

            return Dismissible(
              key: ValueKey('fav_${character.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.dead,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              onDismissed: (_) async {
                await FavoriteStore.instance.removeFavorite(character.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${character.name} dihapus dari favorit'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: CharacterCard(
                c: character,
                isFav: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(characterId: character.id),
                    ),
                  );
                },
                onFav: () async {
                  await FavoriteStore.instance.removeFavorite(character.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${character.name} dihapus dari favorit'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
