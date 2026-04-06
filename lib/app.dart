import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/router/router.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';

class App extends StatelessWidget {
  const App({required this.authRepository, super.key});

  final AuthRepository authRepository;
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        create: (context) => AuthBloc(context.read<AuthRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: '/',
        ),
      ),
    );
  }
}
