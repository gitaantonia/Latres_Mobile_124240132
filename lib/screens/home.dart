import 'package:flutter/material.dart';
import '../model/series.dart';
import '../services/api_service.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Series>> _showsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _showsFuture = ApiService.fetchShows();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _showsFuture = ApiService.fetchShows();
    });
  }

  List<Series> _filtered(List<Series> shows) {
    if (_searchQuery.isEmpty) return shows;
    return shows
        .where((s) =>
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.genres.any((g) => g.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Skuy Nonton!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (jika ingin mencari)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                hintText: 'Cari judul show...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Show List
          Expanded(
            child: FutureBuilder<List<Series>>(
              future: _showsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE50914)),
                        SizedBox(height: 16),
                        Text(
                          'Memuat daftar shows...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off, size: 72, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Gagal memuat data!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pastikan koneksi internet aktif.',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('Coba Lagi',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final shows = _filtered(snapshot.data!);

                if (shows.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 72, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          '"$_searchQuery" tidak ditemukan',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: shows.length,
                  itemBuilder: (context, index) {
                    return _ShowCard(show: shows[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowCard extends StatelessWidget {
  final Series show;
  const _ShowCard({required this.show});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(id: show.id, initialShow: show),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: show.image.isNotEmpty
                  ? Image.network(
                      show.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: const Color(0xFF333333),
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF333333),
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.grey, size: 48),
                      ),
                    ),
            ),

            // Info (Judul & Rating sesuai mockup)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        show.rating > 0
                            ? show.rating.toStringAsFixed(1)
                            : 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
