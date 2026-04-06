import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationDocumentsDirectory();

  final cookieJar = PersistCookieJar (
    ignoreExpires: false, 
    storage: FileStorage('${directory.path}/.cookies/'),
  );

  final dio = createDioClient(cookieJar);
  final authRemoteDataSource = AuthRemoteDataSource(dio);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource, cookieJar);

  runApp(App(authRepository: authRepository));
}