import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/entities/notification.dart'
    as notification_entity;
import 'package:ptit_dms_flutter/domain/repositories/notification_repository.dart';
import 'package:ptit_dms_flutter/features/notifications/bloc/notification_bloc.dart';
import 'package:ptit_dms_flutter/features/notifications/widgets/notification_card.dart';
import 'package:ptit_dms_flutter/features/notifications/widgets/notification_details_sheet.dart';
import 'package:ptit_dms_flutter/features/notifications/widgets/notification_status_widgets.dart';
import 'package:ptit_dms_flutter/features/notifications/widgets/notification_toolbar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationBloc(context.read<NotificationRepository>())
            ..add(const NotificationStarted()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<NotificationBloc>().add(const NotificationLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) =>
          previous.mutationStatus != current.mutationStatus ||
          previous.loadMoreStatus != current.loadMoreStatus,
      listener: _showErrorMessage,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F6),
          appBar: const AppHeader(title: 'Thông báo'),
          body: SafeArea(
            child: Column(
              children: [
                NotificationToolbar(state: state),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorMessage(BuildContext context, NotificationState state) {
    final message = state.mutationStatus == NotificationMutationStatus.failure
        ? state.mutationErrorMessage
        : state.loadMoreStatus == NotificationLoadMoreStatus.failure
        ? state.errorMessage
        : null;

    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildBody(NotificationState state) {
    if ((state.status == NotificationStatus.initial ||
            state.status == NotificationStatus.loading) &&
        !state.hasNotifications) {
      return const Center(
        child: CircularProgressIndicator(
          key: Key('notifications_loading_indicator'),
        ),
      );
    }

    if (state.status == NotificationStatus.failure && !state.hasNotifications) {
      return NotificationMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Không thể tải thông báo',
        description:
            state.errorMessage ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.',
        actionLabel: 'Thử lại',
        onAction: () =>
            context.read<NotificationBloc>().add(const NotificationRefreshed()),
      );
    }

    if (!state.hasNotifications) {
      return NotificationMessage(
        icon: state.unreadOnly
            ? Icons.mark_email_read_outlined
            : Icons.notifications_none_rounded,
        title: state.unreadOnly
            ? 'Không có thông báo chưa đọc'
            : 'Chưa có thông báo',
        description: state.unreadOnly
            ? 'Bạn đã đọc tất cả thông báo.'
            : 'Thông báo mới sẽ xuất hiện tại đây.',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.separated(
        key: const Key('notifications_list'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: state.notifications.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return NotificationLoadMoreFooter(state: state);
          }

          final notification = state.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => _openNotification(notification),
          );
        },
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    final bloc = context.read<NotificationBloc>()
      ..add(const NotificationRefreshed());

    await bloc.stream.firstWhere(
      (state) => state.status != NotificationStatus.loading,
    );
  }

  void _openNotification(notification_entity.Notification notification) {
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        NotificationMarkedAsRead(notification.id),
      );
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationDetailsSheet(notification: notification),
    );
  }
}
