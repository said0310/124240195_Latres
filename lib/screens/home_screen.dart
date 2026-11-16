import 'dart:async';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../stores/favorite_store.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  final List<Character> _characters = [];
  int _currentPage = 1;
  bool _hasNext = true;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  String _selectedStatus = 'All';
  final List<String> _statusOptions = ['All', 'Alive', 'Dead', 'unknown'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchCharacters(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingInitial && !_isLoadingMore && _hasNext) {
        _fetchCharacters(loadMore: true);
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchCharacters(reset: true);
    });
  }

  void _onStatusSelected(String status) {
    if (_selectedStatus == status) return;
    setState(() {
      _selectedStatus = status;
    });
    _fetchCharacters(reset: true);
  }

  Future<void> _fetchCharacters({bool reset = false, bool loadMore = false}) async {
    if (reset) {
      setState(() {
        _isLoadingInitial = true;
        _errorMessage = null;
        _currentPage = 1;
        _characters.clear();
      });
    } else if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final pageToFetch = reset ? 1 : _currentPage;

    try {
      final response = await ApiService.getCharacters(
        page: pageToFetch,
        status: _selectedStatus == 'All' ? null : _selectedStatus,
        name: _searchController.text,
      );

      if (!mounted) return;

      setState(() {
        if (reset) {
          _characters.clear();
        }
        _characters.addAll(response.characters);
        _hasNext = response.hasNext;
        _currentPage = pageToFetch + 1;
        _isLoadingInitial = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
        _isLoadingMore = false;
        if (reset) {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Search & Filter Section
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: AppColors.gray,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field (white, radius 16)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: AppColors.navy),
                  decoration: InputDecoration(
                    hintText: 'Cari karakter...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _fetchCharacters(reset: true);
                            },
                          )
                        : null,
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips (terpilih = teal + putih, lain = mint + navy)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusOptions.map((status) {
                    final isSelected = _selectedStatus.toLowerCase() == status.toLowerCase();
                    final label = status == 'unknown'
                        ? 'Unknown'
                        : (status == 'All' ? 'All' : status);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => _onStatusSelected(status),
                        backgroundColor: AppColors.mint,
                        selectedColor: AppColors.teal,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.navy,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Character List / Body
        Expanded(
          child: RefreshIndicator(
            color: AppColors.teal,
            onRefresh: () => _fetchCharacters(reset: true),
            child: _buildBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoadingInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: () => _fetchCharacters(reset: true),
      );
    }

    if (_characters.isEmpty) {
      return const EmptyView(
        icon: Icons.search_off_rounded,
        title: 'Karakter tidak ditemukan',
        subtitle: 'Coba gunakan kata kunci pencarian atau filter status yang lain.',
      );
    }

    return ListenableBuilder(
      listenable: FavoriteStore.instance,
      builder: (context, _) {
        return ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _characters.length + (_hasNext ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _characters.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
                  ),
                ),
              );
            }

            final character = _characters[index];
            final isFav = FavoriteStore.instance.isFavorite(character.id);

            return CharacterCard(
              c: character,
              isFav: isFav,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(characterId: character.id),
                  ),
                );
              },
              onFav: () async {
                final added = await FavoriteStore.instance.toggleFavorite(character);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? '${character.name} ditambahkan ke favorit'
                            : '${character.name} dihapus dari favorit',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
