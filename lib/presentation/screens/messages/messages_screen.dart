import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../data/models/message.dart' as msg;
import '../../../l10n/app_localizations.dart';

/// Format a DateTime into a human-readable time string
String _formatTime(DateTime? dt, AppLocalizations l10n) {
  if (dt == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return l10n.commonNow;
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${dt.day}/${dt.month}';
}

/// Messages Screen - Conversations list with auto-refresh on tab visibility
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      ref.read(conversationsProvider.notifier).loadConversations(
            currentUserId: authState.user?.id,
          );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      _refreshIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshIfNeeded() {
    final authState = ref.read(authStateProvider);
    ref.read(conversationsProvider.notifier).refreshConversations(
          currentUserId: authState.user?.id,
        );
  }

  void _onScroll() {
    final state = ref.read(conversationsProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading) {
      final nextPage = (state.conversations.length ~/ 10) + 1;
      final authState = ref.read(authStateProvider);
      ref.read(conversationsProvider.notifier).loadConversations(
            page: nextPage,
            currentUserId: authState.user?.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(conversationsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        title: Text(l10n.messagesTitle),
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(ConversationsState state, AppLocalizations l10n) {
    if (state.isLoading && state.conversations.isEmpty) {
      return _buildConversationsSkeleton();
    }

    if (state.errorMessage != null && state.conversations.isEmpty) {
      return WaveMessageScreen.error(
        title: 'Error Loading Conversations',
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(conversationsProvider.notifier).loadConversations();
        },
        isEmbedded: true,
      );
    }

    final List<msg.Conversation> conversations =
        state.conversations.cast<msg.Conversation>().toList();

    if (conversations.isEmpty) {
      return WaveEmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: l10n.messagesEmpty,
        subtitle: l10n.favoritesEmptySubtitle,
        actionLabel: l10n.homeViewAll,
        onAction: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authState = ref.read(authStateProvider);
        await ref.read(conversationsProvider.notifier).loadConversations(
              currentUserId: authState.user?.id,
            );
      },
      child: ListView.separated(
        controller: _scrollController,
        itemCount: conversations.length + (state.isLoading ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= conversations.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final conversation = conversations[index];
          return _ConversationTile(
            conversation: conversation,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                      conversationId: conversation.id,
                      conversation: conversation),
                ),
              );
              // Refresh conversations after returning to update unread badges
              if (mounted) {
                final authState = ref.read(authStateProvider);
                ref.read(conversationsProvider.notifier).refreshConversations(
                      currentUserId: authState.user?.id,
                    );
              }
            },
          );
        },
      ),
    );
  }


  Widget _buildConversationsSkeleton() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: context.shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          title: Container(height: 16, width: 140, color: context.shimmerBase),
          subtitle: Container(
              height: 12,
              width: 200,
              color: context.shimmerBase,
              margin: const EdgeInsets.only(top: 8)),
          trailing:
              Container(height: 12, width: 40, color: context.shimmerBase),
        );
      },
    );
  }
}

/// Conversation Tile Widget - WhatsApp-like with actual user initials
class _ConversationTile extends ConsumerWidget {
  final msg.Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.user?.id ?? 0;
    final l10n = AppLocalizations.of(context);

    // Compute initials and name dynamically with currentUserId
    final initials = conversation.getInitials(currentUserId);
    final displayName = conversation.getDisplayTitle(currentUserId);

    // Check if this is a property-related conversation
    final isAssetChat =
        conversation.isAssetChat || conversation.listingId != null;
    final listingTitle = conversation.listingTitle;

    final hasUnread =
        conversation.unreadCount != null && conversation.unreadCount! > 0;

    // Format "You: " prefix for own messages - use lastMessageSenderId for accuracy
    String previewText =
        conversation.lastMessage != null && conversation.lastMessage!.isNotEmpty
            ? conversation.lastMessage!
            : l10n.messagesEmpty;

    if (conversation.lastMessage != null &&
        conversation.lastMessage!.isNotEmpty) {
      final isOwnLastMessage = conversation.isLastMessageFromMe(currentUserId);
      if (isOwnLastMessage) {
        previewText = '${l10n.commonYou}: $previewText';
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasUnread
                    ? [AppColors.wave500, AppColors.wave600]
                    : [AppColors.navy400, AppColors.navy600],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode
                      ? AppColors.navy900
                      : AppColors.surface,
                ),
              ),
            ),
          ),
          // Unread badge
          if (hasUnread)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    conversation.unreadCount! > 99
                        ? '99+'
                        : '${conversation.unreadCount}',
                    style: TextStyle(
                      color: context.isDarkMode
                          ? AppColors.navy900
                          : AppColors.surface,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        displayName,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (isAssetChat) ...[
            const Icon(Icons.home_outlined, size: 12, color: AppColors.zinc400),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                listingTitle ?? l10n.listingsTitle,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.zinc500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Text('·', style: TextStyle(color: AppColors.zinc400)),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              previewText,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                color: hasUnread ? AppColors.navy800 : AppColors.zinc500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageAt != null)
            Text(
              _formatTime(conversation.lastMessageAt, l10n),
              style: TextStyle(
                fontSize: 11,
                color: hasUnread ? AppColors.wave600 : AppColors.zinc400,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// Chat Screen - Individual conversation with full messaging
class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final msg.Conversation conversation;

  const ChatScreen(
      {super.key, required this.conversationId, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  bool _isSending = false;
  bool _hasScrolledToUnread = false;
  bool _contextDropdownOpen = false;

  @override
  void dispose() {
    _messageController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _toggleContextDropdown() {
    setState(() {
      _contextDropdownOpen = !_contextDropdownOpen;
    });
  }

  void _closeContextDropdown() {
    setState(() {
      _contextDropdownOpen = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final success = await ref
        .read(chatMessagesProvider(widget.conversationId).notifier)
        .sendMessage(text);

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _scrollToBottom();
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.commonError), // Using commonError for now
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listScrollController.hasClients) {
        _listScrollController.animateTo(
          _listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToFirstUnread(List<msg.Message> messages, int currentUserId) {
    if (_hasScrolledToUnread || messages.isEmpty) return;

    // Find index of first unread message (not from me, not read)
    int firstUnreadIndex = -1;
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (msg.senderId != currentUserId && !msg.isRead && msg.readAt == null) {
        firstUnreadIndex = i;
        break;
      }
    }

    _hasScrolledToUnread = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listScrollController.hasClients) return;

      if (firstUnreadIndex >= 0) {
        // Scroll to the unread message
        final double offset = firstUnreadIndex * 80.0;
        _listScrollController.animateTo(
          offset.clamp(0, _listScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } else {
        // No unread - scroll to bottom
        _scrollToBottom();
      }
    });
  }

  Widget _buildContextDropdown(BuildContext context, AppLocalizations l10n,
      bool isDark, List<msg.Conversation> relatedConversations) {
    return GestureDetector(
      onTap: _closeContextDropdown,
      child: Container(
        margin: const EdgeInsets.only(top: 48),
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          color: context.cardBgElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: context.divider.withOpacity(0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color:
                    context.isDarkMode ? AppColors.navy900 : AppColors.zinc400,
                child: Text(
                  l10n.messagesSwitchContext,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Conversation list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: relatedConversations.length,
                  itemBuilder: (context, index) {
                    final conv = relatedConversations[index];
                    final isSelected = conv.id == widget.conversationId;
                    return _buildContextItem(conv, isSelected, l10n, isDark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildContextItem(msg.Conversation conv, bool isSelected,
      AppLocalizations l10n, bool isDark) {
    return InkWell(
      onTap: () {
        _closeContextDropdown();
        if (conv.id != widget.conversationId) {
          // Navigate to the selected conversation
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: conv.id,
                conversation: conv,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color:
            isSelected ? (isDark ? AppColors.navy700 : AppColors.navy50) : null,
        child: Row(
          children: [
            // Icon/Image
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: conv.isAssetChat
                    ? (isDark ? AppColors.navy700 : AppColors.navy100)
                    : (isDark ? AppColors.zinc700 : AppColors.zinc100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: conv.listingImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        conv.listingImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          conv.isAssetChat ? Icons.home : Icons.chat,
                          size: 18,
                          color: conv.isAssetChat
                              ? AppColors.navy600
                              : AppColors.zinc500,
                        ),
                      ),
                    )
                  : Icon(
                      conv.isAssetChat ? Icons.home : Icons.chat,
                      size: 18,
                      color: conv.isAssetChat
                          ? AppColors.navy600
                          : AppColors.zinc500,
                    ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.contextDisplayTitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isDark ? AppColors.zinc100 : AppColors.zinc900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (conv.unreadCount != null && conv.unreadCount! > 0)
                        Text(
                          '${conv.unreadCount} ${l10n.messagesUnread}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        )
                      else if (conv.lastMessageAt != null)
                        Text(
                          _formatRelativeTime(conv.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.zinc400,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Checkmark for selected
            if (isSelected)
              const Icon(
                Icons.check,
                size: 18,
                color: AppColors.navy600,
              ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}';
  }

  Widget _buildMessagesList(List<msg.Message> messages,
      int currentUserId, AppLocalizations l10n, int? listingOwnerId) {
    // Trigger scroll to first unread on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstUnread(messages, currentUserId);
    });

    // Find first unread index for divider
    int firstUnreadIndex = -1;
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (msg.senderId != currentUserId && !msg.isRead && msg.readAt == null) {
        firstUnreadIndex = i;
        break;
      }
    }

    return ListView.builder(
      controller: _listScrollController,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Add unread divider
        if (index == firstUnreadIndex && firstUnreadIndex >= 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? AppColors.wave950
                      : AppColors.wave100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.messagesEmpty,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.wave500,
                  ),
                ),
              ),
              _MessageBubble(
                  message: messages[index], listingOwnerId: listingOwnerId),
            ],
          );
        }
        return _MessageBubble(
            message: messages[index], listingOwnerId: listingOwnerId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatMessagesProvider(widget.conversationId));
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.user?.id ?? 0;
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build proper title from conversation data
    String title = widget.conversation.contextDisplayTitle;
    String otherUserName = widget.conversation.getDisplayTitle(currentUserId);
    final relatedConversations = chatState.relatedConversations;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap:
              relatedConversations.isNotEmpty ? _toggleContextDropdown : null,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (relatedConversations.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _contextDropdownOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20,
                          color: AppColors.navy400,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'with $otherUserName',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.zinc400 : AppColors.zinc500,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              // Dropdown overlay
              if (_contextDropdownOpen)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: _buildContextDropdown(
                        context, l10n, isDark, relatedConversations),
                  ),
                ),
            ],
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Additional actions (call, profile, etc.)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? _buildMessagesSkeleton()
                : chatState.errorMessage != null && chatState.messages.isEmpty
                    ? WaveMessageScreen.error(
                        isEmbedded: true,
                        title: 'Error Loading Messages',
                        subtitle: chatState.errorMessage!,
                        onRetry: () {
                          ref
                              .read(chatMessagesProvider(widget.conversationId)
                                  .notifier)
                              .loadMessages();
                        },
                      )
                    : chatState.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 64, color: AppColors.navy300),
                                const SizedBox(height: 16),
                                Text(l10n.messagesEmpty,
                                    style: AppTextStyles.bodyLarge
                                        .copyWith(color: AppColors.navy500)),
                              ],
                            ),
                          )
                        : _buildMessagesList(chatState.messages, currentUserId,
                            l10n, widget.conversation.listingOwnerId),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: context.isDarkMode ? AppColors.navy900 : AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy950.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: l10n.messagesTypeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isSending ? AppColors.zinc400 : AppColors.wave500,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.surface)),
                            )
                          : const Icon(Icons.send, color: AppColors.surface),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for chat messages
Widget _buildMessagesSkeleton() {
  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: 6,
    itemBuilder: (context, index) {
      final isLeft = index % 2 == 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment:
              isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (isLeft) ...[
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.zinc200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              height: 40,
              width: 120 + (index * 20),
              decoration: BoxDecoration(
                color: AppColors.zinc200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isLeft ? 16 : 4),
                  bottomRight: Radius.circular(isLeft ? 4 : 16),
                ),
              ),
            ),
            if (!isLeft) ...[
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.zinc200,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

/// Format message time for bubbles
String _formatMessageTime(DateTime createdAt, AppLocalizations l10n) {
  final now = DateTime.now();
  final diff = now.difference(createdAt);

  if (diff.inMinutes < 1) return l10n.commonNow;
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}

/// Message Bubble Widget - WhatsApp-like with actual user initials
class _MessageBubble extends ConsumerWidget {
  final msg.Message message;
  final int? listingOwnerId;

  const _MessageBubble({required this.message, this.listingOwnerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.user?.id ?? 0;
    final isOwn = message.senderId == currentUserId;
    final isSeen = message.readAt != null;
    final initials = message.senderInitials;
    final l10n = AppLocalizations.of(context);
    final isListingOwner =
        listingOwnerId != null && message.senderId == listingOwnerId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for incoming messages
          if (!isOwn) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isListingOwner
                      ? [AppColors.wave400, AppColors.wave600]
                      : [AppColors.navy400, AppColors.navy600],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode
                        ? AppColors.navy900
                        : AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isOwn && isListingOwner)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      '(Owner)',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.wave500,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOwn
                        ? (context.isDarkMode
                            ? AppColors.wave600
                            : AppColors.navy600)
                        : context.cardBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isOwn ? 16 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 16),
                    ),
                    boxShadow: context.isDarkMode ? null : AppColors.shadowSm,
                    border: isOwn
                        ? null
                        : Border.all(color: context.divider.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: isOwn
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.body,
                        style: TextStyle(
                          color: isOwn ? Colors.white : context.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatMessageTime(message.createdAt, l10n),
                            style: TextStyle(
                              color: isOwn
                                  ? AppColors.surface.withOpacity(0.7)
                                  : AppColors.zinc400,
                              fontSize: 10,
                            ),
                          ),
                          if (isOwn) ...[
                            const SizedBox(width: 4),
                            Icon(
                              isSeen ? Icons.done_all : Icons.done,
                              size: 14,
                              color: isSeen
                                  ? AppColors.wave300
                                  : AppColors.surface.withOpacity(0.5),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Avatar for outgoing messages
          if (isOwn) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.wave400, AppColors.wave600],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode
                        ? AppColors.navy900
                        : AppColors.surface,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

