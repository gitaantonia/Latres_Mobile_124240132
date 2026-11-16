import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/series.dart';
import '../services/favorite_service.dart';
import 'detail.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Daftar Favorit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: FavoriteService.listenable(),
        builder: (context, box, _) {
          final favorites = FavoriteService.getFavorites();

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada favorit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan show favoritmu dari halaman detail!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final show = favorites[index];
              return _FavoriteCard(show: show);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Series show;
  const _FavoriteCard({required this.show});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(id: show.id, initialShow: show),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: show.image.isNotEmpty
              ? Image.network(
                  show.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    width: 50,
                    height: 50,
                    color: const Color(0xFF333333),
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: const Color(0xFF333333),
                  child: const Icon(Icons.movie, color: Colors.grey, size: 24),
                ),
        ),
        title: Text(
          show.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                show.rating > 0 ? show.rating.toStringAsFixed(1) : 'N/A',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Color(0xFFE50914), size: 22),
          tooltip: 'Hapus dari favorit',
          onPressed: () async {
            await FavoriteService.removeFavorite(show.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${show.name} dihapus dari favorit'),
                backgroundColor: const Color(0xFF333333),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
