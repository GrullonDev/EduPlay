import 'package:get_it/get_it.dart';
import 'package:edu_play/data/datasources/auth_datasource.dart';
import 'package:edu_play/data/datasources/student_datasource.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/data/repositories/student_repository.dart';
// import 'package:edu_play/data/repositories/mock_auth_repository.dart';

class InjectionContainer {}

final sl = GetIt.instance;

void init() {
  // Datasources
  sl.registerLazySingleton<AuthDatasource>(() => ImplAuthDatasource());
  sl.registerLazySingleton<StudentDatasource>(() => StudentDatasource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => ImplAuthRepository(authDatasource: sl()),
  );
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepository(datasource: sl()),
  );
}
