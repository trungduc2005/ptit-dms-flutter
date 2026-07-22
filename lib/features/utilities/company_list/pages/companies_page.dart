import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/bloc/company_list_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/widgets/company_list_card.dart';
import 'package:ptit_dms_flutter/features/utilities/navigation/utilities_routes.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompanyListBloc(
        context.read<CompanyRepository>(),
        context.read<AcademicYearRepository>(),
      )..add(const CompanyListStarted()),
      child: const _CompaniesView(),
    );
  }
}

class _CompaniesView extends StatelessWidget {
  const _CompaniesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const AppHeader(title: 'Doanh nghiệp', showBackButton: true),
      body: BlocBuilder<CompanyListBloc, CompanyListState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.academicYears.isNotEmpty)
                _AcademicYearSelector(
                  academicYears: state.academicYears,
                  selectedAcademicYear: state.selectedAcademicYear,
                  enabled: state.status != CompanyListStatus.loading,
                  onChanged: (academicYear) {
                    context.read<CompanyListBloc>().add(
                      CompanyListAcademicYearChanged(academicYear),
                    );
                  },
                ),
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CompanyListState state) {
    if (state.status == CompanyListStatus.loading ||
        state.status == CompanyListStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.brandColor),
      );
    }

    if (state.status == CompanyListStatus.failure) {
      return _CompanyListMessage(
        icon: Icons.cloud_off_outlined,
        message: state.errorMessage ?? 'Không thể tải danh sách doanh nghiệp.',
        actionLabel: 'Thử lại',
        onPressed: () {
          context.read<CompanyListBloc>().add(const CompanyListRefreshed());
        },
      );
    }

    if (!state.hasCompanies) {
      return const _CompanyListMessage(
        icon: Icons.business_outlined,
        message: 'Chưa có doanh nghiệp trong năm học này.',
      );
    }

    return RefreshIndicator(
      color: AppTheme.brandColor,
      onRefresh: () => _refresh(context),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        itemCount: state.companies.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final company = state.companies[index];

          return CompanyListCard(
            company: company,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(UtilitiesRoutes.companyDetail, arguments: company);
            },
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

class _AcademicYearSelector extends StatelessWidget {
  const _AcademicYearSelector({
    required this.academicYears,
    required this.selectedAcademicYear,
    required this.enabled,
    required this.onChanged,
  });

  final List<AcademicYearOption> academicYears;
  final AcademicYearOption? selectedAcademicYear;
  final bool enabled;
  final ValueChanged<AcademicYearOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: FormDropdownField<AcademicYearOption>(
        label: 'Năm học',
        value: selectedAcademicYear,
        hintText: 'Chọn năm học',
        enabled: enabled,
        accentColor: AppTheme.brandColor,
        items: academicYears
            .map(
              (year) => DropdownMenuItem(
                value: year,
                child: Text(year.name.isNotEmpty ? year.name : year.code),
              ),
            )
            .toList(),
        onChanged: (year) {
          if (year != null) onChanged(year);
        },
      ),
    );
  }
}

class _CompanyListMessage extends StatelessWidget {
  const _CompanyListMessage({
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.actionLabel,
    this.onPressed,
  });

  final String message;
  final IconData icon;
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
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.brandColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.refresh_rounded, size: 19),
                  label: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
