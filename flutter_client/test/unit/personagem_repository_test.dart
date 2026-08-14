import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client/data/models/personagem.dart';
import 'package:flutter_client/data/repositories/personagem_repository.dart';
import 'package:flutter_client/data/storage/local_storage_service.dart';

void main() {
  late PersonagemRepository repository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  setUp(() {
    repository = PersonagemRepository();
  });

  group('PersonagemRepository Unit Tests', () {
    test('save, get and delete character profile correctly', () async {
      final p = Personagem(
        id: 1,
        nome: 'Lucas',
        avatar: 'assets/avatar/avatar_1.jpg',
        dificuldade: 'MEDIO',
      );

      await repository.savePersonagem(p);
      final list = repository.getPersonagens();
      expect(list.any((item) => item.id == 1 && item.nome == 'Lucas'), isTrue);

      await repository.setActivePersonagem(p);
      expect(repository.getActivePersonagem()?.nome, 'Lucas');
      expect(repository.getActivePersonagem()?.dificuldade, 'MEDIO');

      await repository.deletePersonagem(1);
      final updatedList = repository.getPersonagens();
      expect(updatedList.any((item) => item.id == 1), isFalse);
    });
  });
}
