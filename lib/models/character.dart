class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String origin;
  final String location;
  final String image;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    String parseName(dynamic val) {
      if (val is Map<String, dynamic>) {
        return val['name']?.toString() ?? 'Unknown';
      }
      return val?.toString() ?? 'Unknown';
    }

    return Character(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      status: json['status']?.toString() ?? 'unknown',
      species: json['species']?.toString() ?? 'Unknown',
      gender: json['gender']?.toString() ?? 'Unknown',
      origin: parseName(json['origin']),
      location: parseName(json['location']),
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'gender': gender,
      'origin': origin,
      'location': location,
      'image': image,
    };
  }
}
