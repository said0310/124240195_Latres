import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  final _scrollController = ScrollController();
  final List<Episode> _episodes = [];
  int _currentPage = 1;
  bool _hasNext = true;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchEpisodes(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingInitial && !_isLoadingMore && _hasNext) {
        _fetchEpisodes(loadMore: true);
      }
    }
  }

  Future<void> _fetchEpisodes({bool reset = false, bool loadMore = false}) async {
    if (reset) {
      setState(() {
        _isLoadingInitial = true;
        _errorMessage = null;
        _currentPage = 1;
        _episodes.clear();
      });
    } else if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final pageToFetch = reset ? 1 : _currentPage;

    try {
      final response = await ApiService.getEpisodes(page: pageToFetch);
      if (!mounted) return;

      setState(() {
        if (reset) {
          _episodes.clear();
        }
        _episodes.addAll(response.episodes);
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
    if (_isLoadingInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: () => _fetchEpisodes(reset: true),
      );
    }

    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: () => _fetchEpisodes(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _episodes.length + (_hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _episodes.length) {
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

          final episode = _episodes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Episode Code Badge (Mint background, Teal text)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      episode.episode.isNotEmpty ? episode.episode : '#${episode.id}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Air Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                episode.airDate,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
        },
      ),
    );
  }
}
