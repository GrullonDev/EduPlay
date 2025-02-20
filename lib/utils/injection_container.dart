import 'package:get_it/get_it.dart';
import 'package:edu_play/data/datasources/auth_datasource.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';

class InjectionContainer {}

final sl = GetIt.instance;

void init() {
  // Datasources
  sl.registerLazySingleton<AuthDatasource>(() => ImplAuthDatasource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => ImplAuthRepository(
      authDatasource: sl(),
    ),
  );
}
