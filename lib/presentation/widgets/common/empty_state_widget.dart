import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

enum EmptyStateType {
  favorite,
  message,
  listing,
  search,
  notification,
  general,
}

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;

  const EmptyStateWidget({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionText,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            if (message != null) ...[
              const SizedBox(height: 8),
              _buildMessage(),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconData = icon ?? _getDefaultIcon();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 48,
        color: AppColors.navy400,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title ?? _getDefaultTitle(),
      style: AppTextStyles.title.copyWith(
        color: AppColors.navy800,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Text(
      message ?? _getDefaultMessage(),
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.navy500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.wave600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(actionText!.toUpperCase()),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case EmptyStateType.favorite:
        return Icons.favorite_border;
      case EmptyStateType.message:
        return Icons.chat_bubble_outline;
      case EmptyStateType.listing:
        return Icons.home_work_outlined;
      case EmptyStateType.search:
        return Icons.search_off;
      case EmptyStateType.notification:
        return Icons.notifications_off_outlined;
      case EmptyStateType.general:
        return Icons.inbox_outlined;
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case EmptyStateType.favorite:
        return 'No favorites yet';
      case EmptyStateType.message:
        return 'No messages yet';
      case EmptyStateType.listing:
        return 'No listings';
      case EmptyStateType.search:
        return 'No results found';
      case EmptyStateType.notification:
        return 'No notifications';
      case EmptyStateType.general:
        return 'Nothing here';
    }
  }

  String _getDefaultMessage() {
    switch (type) {
      case EmptyStateType.favorite:
        return 'Save properties to see them here';
      case EmptyStateType.message:
        return 'Start a conversation with a seller';
      case EmptyStateType.listing:
        return 'Create your first listing';
      case EmptyStateType.search:
        return 'Try a different search term';
      case EmptyStateType.notification:
        return 'You\'re all caught up';
      case EmptyStateType.general:
        return 'Nothing to display';
    }
  }
}