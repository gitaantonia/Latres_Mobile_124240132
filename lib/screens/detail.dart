import 'package:flutter/material.dart';
import '../model/series.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  final int id;
  // Optional initial show data for instant display if passed
  final Series? initialShow;

  const DetailPage({
    super.key,
    required this.id,
    this.initialShow,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Series> _showFuture;
  bool _isFavorite = false;
  Series? _loadedShow;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoriteService.isFavorite(widget.id);
    _loadedShow = widget.initialShow;
    _showFuture = ApiService.fetchShowDetail(widget.id);
  }

  void _toggleFavorite(Series show) async {
    final added = await FavoriteService.toggleFavorite(show);
    setState(() {
      _isFavorite = added;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${show.name} ditambahkan ke favorit!'
              : '${show.name} dihapus dari favorit!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: added ? Colors.green : Colors.grey[800],
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Detail',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Series>(
        future: _showFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Jika ada initialShow, tampilkan dulu sembari loading
            if (_loadedShow != null) {
              return _buildContent(_loadedShow!);
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE50914),
              ),
            );
          }

          if (snapshot.hasError) {
            if (_loadedShow != null) {
              return _buildContent(_loadedShow!);
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat detail show: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                      ),
                      onPressed: () {
                        setState(() {
                          _showFuture = ApiService.fetchShowDetail(widget.id);
                        });
                      },
                      child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final show = snapshot.data!;
          _loadedShow = show;
          return _buildContent(show);
        },
      ),
    );
  }

  Widget _buildContent(Series show) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Poster Besar
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: show.originalImage.isNotEmpty
                  ? Image.network(
                      show.originalImage,
                      height: 380,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 380,
                        color: const Color(0xFF232323),
                        child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 380,
                      width: double.infinity,
                      color: const Color(0xFF232323),
                      child: const Icon(Icons.movie, size: 80, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // Judul
          Text(
            show.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                show.rating > 0 ? show.rating.toStringAsFixed(1) : 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Genre
          if (show.genres.isNotEmpty)
            Text(
              show.genres.join(', '),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          const SizedBox(height: 20),

          // Tombol Nonton & Tombol Favorit
          Row(
            children: [
              // Tombol ▶ Nonton
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Memutar: ${show.name}...'),
                        backgroundColor: const Color(0xFFE50914),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                  label: const Text(
                    'Nonton',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Tombol Favorit (Heart Button)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF232323),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isFavorite ? const Color(0xFFE50914) : Colors.grey[800]!,
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? const Color(0xFFE50914) : Colors.white,
                    size: 26,
                  ),
                  tooltip: _isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
                  onPressed: () => _toggleFavorite(show),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview / Summary
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            show.summary,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
