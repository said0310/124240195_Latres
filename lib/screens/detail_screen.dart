import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../stores/favorite_store.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class DetailScreen extends StatefulWidget {
  final int characterId;

  const DetailScreen({super.key, required this.characterId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Character? _character;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final character = await ApiService.getCharacterDetail(widget.characterId);
      if (!mounted) return;
      setState(() {
        _character = character;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          title: const Text('Detail Karakter'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.teal),
        ),
      );
    }

    if (_errorMessage != null || _character == null) {
      return Scaffold(
        backgroundColor: AppColors.gray,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          title: const Text('Detail Karakter'),
        ),
        body: ErrorView(
          message: _errorMessage ?? 'Gagal memuat detail karakter',
          onRetry: _fetchDetail,
        ),
      );
    }

    final char = _character!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: FavoriteStore.instance,
        builder: (context, _) {
          final isFav = FavoriteStore.instance.isFavorite(char.id);

          return CustomScrollView(
            slivers: [
              // SliverAppBar with Full-width Photo (height ±320)
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.favorite : Colors.white,
                    ),
                    onPressed: () async {
                      final added = await FavoriteStore.instance.toggleFavorite(char);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              added
                                  ? '${char.name} ditambahkan ke favorit'
                                  : '${char.name} dihapus dari favorit',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        char.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.navy,
                          child: const Icon(Icons.person, size: 80, color: Colors.white54),
                        ),
                      ),
                      // Gradient overlay for smooth transition
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlapping White Card (top radius 28)
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name (24 Bold Navy)
                      Text(
                        char.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Status Badge (Mint background with StatusDot)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: StatusDot(char.status),
                      ),
                      const SizedBox(height: 20),

                      const Divider(color: AppColors.gray, thickness: 1.5),

                      // Info Rows (label in gray on left, value in navy on right)
                      _buildInfoRow('Species', char.species),
                      const Divider(color: AppColors.gray, height: 1),
                      _buildInfoRow('Gender', char.gender),
                      const Divider(color: AppColors.gray, height: 1),
                      _buildInfoRow('Origin', char.origin),
                      const Divider(color: AppColors.gray, height: 1),
                      _buildInfoRow('Location', char.location),

                      const SizedBox(height: 32),

                      // Action Button (Teal filled ↔ Outlined when favorite)
                      if (isFav)
                        OutlinedButton.icon(
                          onPressed: () async {
                            await FavoriteStore.instance.removeFavorite(char.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${char.name} dihapus dari favorit'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.favorite, color: AppColors.favorite),
                          label: const Text(
                            'Hapus dari Favorit',
                            style: TextStyle(
                              color: AppColors.favorite,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(color: AppColors.favorite, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        )
                      else
                        FilledButton.icon(
                          onPressed: () async {
                            await FavoriteStore.instance.toggleFavorite(char);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${char.name} ditambahkan ke favorit'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          label: const Text(
                            'Tambah ke Favorit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
