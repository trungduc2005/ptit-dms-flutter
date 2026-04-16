import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/widgets/app_popup_dialog.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_background.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isPopupOpen = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double _clamp(num value, num min, num max) {
    return value.clamp(min, max).toDouble();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _showPopup({
    required String title,
    required String message,
  }) async {
    if (!mounted || _isPopupOpen) {
      return;
    }

    _isPopupOpen = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AppPopupDialog(
          title: title,
          message: message,
        );
      },
    );

    if (!mounted) {
      return;
    }

    _isPopupOpen = false;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showPopup(
        title: 'Thông báo',
        message: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.',
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            username: username,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final authState = context.watch<AuthBloc>().state;
    final isLoading = authState.status == AuthStatus.loading;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.message != current.message;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
          return;
        }

        if (state.status == AuthStatus.failure &&
            state.message != null &&
            state.message!.isNotEmpty) {
          _showPopup(
            title: 'Đăng nhập thất bại',
            message: state.message!,
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final keyboardHeight = media.viewInsets.bottom;
              final isKeyboardVisible = keyboardHeight > 0;

              final horizontalPadding = _clamp(width * 0.06, 16, 28);
              final topInset = isKeyboardVisible
                  ? 12.0
                  : _clamp(height * 0.085, 52, 82);
              final cardMaxWidth = _clamp(width * 0.90, 320, 430);
              final minBodyHeight =
                  height - media.padding.top - media.padding.bottom;

              return Stack(
                children: [
                  LoginBackground(width: width, height: height),
                  SafeArea(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        keyboardHeight + 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: isKeyboardVisible ? 0 : minBodyHeight,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: EdgeInsets.only(top: topInset),
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: cardMaxWidth),
                              child: LoginCard(
                                screenWidth: width,
                                isLoading: isLoading,
                                usernameController: _usernameController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                onTogglePassword: _togglePasswordVisibility,
                                onSubmit: _submit,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
