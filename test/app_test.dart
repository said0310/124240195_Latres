import 'package:flutter_test/flutter_test.dart';
import 'package:latres/models/character.dart';
import 'package:latres/models/episode.dart';
import 'package:latres/services/db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latres/stores/favorite_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Character Model Tests', () {
    test('fromJson and toJson should preserve character fields correctly', () {
      final json = {
        'id': 1,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'gender': 'Male',
        'origin': {'name': 'Earth (C-137)', 'url': 'https://...'},
        'location': {'name': 'Citadel of Ricks', 'url': 'https://...'},
        'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
      };

      final char = Character.fromJson(json);

      expect(char.id, 1);
      expect(char.name, 'Rick Sanchez');
      expect(char.status, 'Alive');
      expect(char.species, 'Human');
      expect(char.gender, 'Male');
      expect(char.origin, 'Earth (C-137)');
      expect(char.location, 'Citadel of Ricks');
      expect(char.image, 'https://rickandmortyapi.com/api/character/avatar/1.jpeg');

      final serialized = char.toJson();
      expect(serialized['id'], 1);
      expect(serialized['name'], 'Rick Sanchez');
      expect(serialized['origin'], 'Earth (C-137)');
    });
  });

  group('Episode Model Tests', () {
    test('fromJson should parse episode data correctly', () {
      final json = {
        'id': 1,
        'name': 'Pilot',
        'air_date': 'December 2, 2013',
        'episode': 'S01E01',
      };

      final episode = Episode.fromJson(json);

      expect(episode.id, 1);
      expect(episode.name, 'Pilot');
      expect(episode.airDate, 'December 2, 2013');
      expect(episode.episode, 'S01E01');
    });
  });

  group('Password Hashing Tests', () {
    test('DbService.hashPassword returns predictable SHA-256 hash', () {
      final hash1 = DbService.hashPassword('secret123');
      final hash2 = DbService.hashPassword('secret123');
      final hashDiff = DbService.hashPassword('secret124');

      expect(hash1, isNotEmpty);
      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hashDiff)));
      expect(hash1.length, 64); // SHA-256 hex is 64 characters
    });
  });

  group('FavoriteStore Tests', () {
    test('Adding and removing favorites with SharedPreferences mock', () async {
      SharedPreferences.setMockInitialValues({});

      final store = FavoriteStore.instance;
      await store.init(99);

      expect(store.favorites.isEmpty, isTrue);

      const testChar = Character(
        id: 42,
        name: 'Morty Test',
        status: 'Alive',
        species: 'Human',
        gender: 'Male',
        origin: 'Earth',
        location: 'Earth',
        image: 'https://...',
      );

      // Add favorite
      final added = await store.toggleFavorite(testChar);
      expect(added, isTrue);
      expect(store.isFavorite(42), isTrue);
      expect(store.favorites.length, 1);

      // Re-initialize store to test persistence in SharedPreferences
      final store2 = FavoriteStore.instance;
      await store2.init(99);
      expect(store2.isFavorite(42), isTrue);

      // Remove favorite
      final removed = await store.toggleFavorite(testChar);
      expect(removed, isFalse);
      expect(store.isFavorite(42), isFalse);
      expect(store.favorites.isEmpty, isTrue);
    });
  });
}
