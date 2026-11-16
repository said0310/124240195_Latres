class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episode;

  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      airDate: json['air_date']?.toString() ?? 'Unknown',
      episode: json['episode']?.toString() ?? '',
    );
  }
}
