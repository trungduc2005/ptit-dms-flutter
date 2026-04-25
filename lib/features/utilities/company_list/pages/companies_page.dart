import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/bloc/company_list_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/widgets/company_list_card.dart';
import 'package:ptit_dms_flutter/features/utilities/navigation/utilities_routes.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utilities_header.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CompanyListBloc(context.read<CompanyRepository>())
            ..add(const CompanyListStarted()),
      child: const _CompaniesView(),
    );
  }
}

class _CompaniesView extends StatelessWidget {
  const _CompaniesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const UtilitiesHeader(
        title: 'Doanh nghiệp',
        showBackButton: true,
      ),
      body: BlocBuilder<CompanyListBloc, CompanyListState>(
        builder: (context, state) {
          if (state.status == CompanyListStatus.loading ||
              state.status == CompanyListStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.brandColor,
              ),
            );
          }

          if (state.status == CompanyListStatus.failure) {
            return _CompanyListMessage(
              message:
                  state.errorMessage ?? 'Không thể tải danh sách doanh nghiệp.',
              actionLabel: 'Thử lại',
              onPressed: () {
                context.read<CompanyListBloc>().add(
                      const CompanyListRefreshed(),
                    );
              },
            );
          }

          if (!state.hasCompanies) {
            return const _CompanyListMessage(
              message: 'Chưa có doanh nghiệp.',
            );
          }

          return RefreshIndicator(
            color: AppTheme.brandColor,
            onRefresh: () => _refresh(context),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              itemCount: state.companies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final company = state.companies[index];

                return CompanyListCard(
                  company: company,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      UtilitiesRoutes.companyDetail,
                      arguments: company,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<CompanyListBloc>();

    bloc.add(const CompanyListRefreshed());

    await bloc.stream.firstWhere(
      (state) => state.status != CompanyListStatus.loading,
    );
  }
}

class _CompanyListMessage extends StatelessWidget {
  const _CompanyListMessage({
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6C7278),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
