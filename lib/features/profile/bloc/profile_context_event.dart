import 'package:equatable/equatable.dart';

sealed class ProfileContextEvent extends Equatable {
  const ProfileContextEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileContextStarted extends ProfileContextEvent {
  const ProfileContextStarted();
}

final class ProfileContextRefreshed extends ProfileContextEvent {
  const ProfileContextRefreshed();
}
