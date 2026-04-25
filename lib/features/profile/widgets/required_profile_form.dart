import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/data/models/required_profile_update_request_model.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/profile/bloc/required_profile_bloc.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/required_profile_actions.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/required_profile_field.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/required_profile_header.dart';

class RequiredProfileForm extends StatefulWidget {
  const RequiredProfileForm({super.key});

  @override
  State<RequiredProfileForm> createState() => _RequiredProfileFormState();
}

class _RequiredProfileFormState extends State<RequiredProfileForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _citizenIdController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    final fields = context.read<RequiredProfileBloc>().state.fields;

    _emailController = TextEditingController(text: fields.email ?? '');
    _phoneController = TextEditingController(text: fields.phone ?? '');
    _citizenIdController = TextEditingController(text: fields.citizenId ?? '');
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _citizenIdController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    context.read<RequiredProfileBloc>().add(
          RequiredProfileSubmitted(
            request: RequiredProfileUpdateRequestModel(
              email: _emailController.text,
              phone: _phoneController.text,
              citizenId: _citizenIdController.text,
              newPassword: _newPasswordController.text,
              confirmPassword: _confirmPasswordController.text,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequiredProfileBloc, RequiredProfileState>(
      builder: (context, state) {
        final isSubmitting = state.status == RequiredProfileStatus.submitting;
        final mustChangePassword = state.mustChangePassword;
        final errorMessage = state.status == RequiredProfileStatus.failure
            ? state.message
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RequiredProfileHeader(
                      mustChangePassword: mustChangePassword,
                    ),
                    const SizedBox(height: 22),
                    RequiredProfileField(
                      label: 'Email',
                      hintText: 'Nhập địa chỉ email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 14),
                    RequiredProfileField(
                      label: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 14),
                    RequiredProfileField(
                      label: 'Số CCCD',
                      hintText: 'Nhập số CCCD',
                      controller: _citizenIdController,
                      keyboardType: TextInputType.number,
                      enabled: !isSubmitting,
                    ),
                    if (mustChangePassword) ...[
                      const SizedBox(height: 14),
                      RequiredProfileField(
                        label: 'Mật khẩu mới',
                        hintText: 'Nhập mật khẩu mới',
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        enabled: !isSubmitting,
                        suffixIcon: IconButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _obscureNewPassword =
                                        !_obscureNewPassword;
                                  });
                                },
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF9AA3AE),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      RequiredProfileField(
                        label: 'Xác nhận mật khẩu',
                        hintText: 'Nhập lại mật khẩu mới',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        enabled: !isSubmitting,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF9AA3AE),
                          ),
                        ),
                      ),
                    ],
                    if (errorMessage != null && errorMessage.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFFD3D3),
                            ),
                          ),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Color(0xFFB42318),
                              fontSize: 13,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            RequiredProfileActions(
              isSubmitting: isSubmitting,
              onSubmit: _submit,
              onLogout: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
          ],
        );
      },
    );
  }
}