import 'package:equatable/equatable.dart';

sealed class CompanyListEvent extends Equatable {
  const CompanyListEvent();

  @override
  List<Object?> get props => [];
}

final class CompanyListStarted extends CompanyListEvent {
  const CompanyListStarted();
}

final class CompanyListRefreshed extends CompanyListEvent {
  const CompanyListRefreshed();
}
