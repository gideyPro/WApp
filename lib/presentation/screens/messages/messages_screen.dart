import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_glass.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../../data/models/v2/conversation.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/v2/api_v2_error.dart';

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

/// Messages Screen - cursor-paginated v2 conversations list.
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).loadConversations();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh on returning from a chat, but not before the first load.
    if (ModalRoute.of(context)?.isCurrent == true &&
        ref.read(conversationsProvider).conversations.isNotEmpty) {
      ref.read(conversationsProvider.notifier).refreshConversations();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(conversationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(conversationsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
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
        title: l10n.errorLoadingConversations,
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(conversationsProvider.notifier).loadConversations();
        },
        isEmbedded: true,
      );
    }

    if (state.conversations.isEmpty) {
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
      onRefresh: () =>
          ref.read(conversationsProvider.notifier).loadConversations(),
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.paddingLg,
        itemCount: state.conversations.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.conversations.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final conversation = state.conversations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WaveGlass(
              child: InkWell(
                onTap: () async {
                  await context.push(
                    '/chat/${conversation.id}',
                    extra: conversation,
                  );
                  if (mounted) {
                    ref
                        .read(conversationsProvider.notifier)
                        .refreshConversations();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: _ConversationTile(conversation: conversation),
              ),
            ),
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
class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final participant = conversation.otherParticipant;
    final initials =
        participant?.initials.isNotEmpty == true ? participant!.initials : '?';
    final avatarUrl = participant?.avatarUrl;
    final displayName =
        conversation.title.isNotEmpty ? conversation.title : l10n.messagesTitle;

    final listingTitle = conversation.listing?.title;
    final hasUnread = conversation.hasUnread;

    final lastMessage = conversation.lastMessage;
    var previewText = lastMessage != null && lastMessage.body.isNotEmpty
        ? lastMessage.body
        : l10n.messagesEmpty;

    if (lastMessage != null &&
        lastMessage.body.isNotEmpty &&
        lastMessage.isMine) {
      previewText = '${l10n.commonYou}: $previewText';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: ResizeImage(
                            CachedNetworkImageProvider(avatarUrl),
                            width: 100,
                            height: 100,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient: avatarUrl != null
                      ? null
                      : LinearGradient(
                          colors: hasUnread
                              ? [AppColors.accent500, AppColors.accent600]
                              : [
                                  context.isDarkMode
                                      ? AppColors.primary700
                                      : AppColors.primary400,
                                  context.isDarkMode
                                      ? AppColors.primary800
                                      : AppColors.primary600,
                                ],
                        ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: avatarUrl != null
                    ? null
                    : Center(
                        child: Text(
                          initials,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.isDarkMode
                                ? AppColors.primary900
                                : AppColors.surface,
                          ),
                        ),
                      ),
              ),
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
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        conversation.unreadCount > 99
                            ? '99+'
                            : '${conversation.unreadCount}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? AppColors.primary900
                              : AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (listingTitle != null) ...[
                      Icon(Icons.home_outlined,
                          size: 12, color: context.theme.iconSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          listingTitle,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('·',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textMuted)),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        previewText,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w500,
                          color: hasUnread
                              ? (context.isDarkMode
                                  ? Colors.white
                                  : AppColors.primary800)
                              : context.theme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (conversation.lastMessageAt != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _formatTime(conversation.lastMessageAt, l10n),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color:
                      hasUnread ? AppColors.accent600 : context.theme.textMuted,
                  fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chat Screen - individual conversation backed by `/v2/conversations/{id}`.
class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final ChatConversation? conversation;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  bool _isSending = false;
  bool _hasScrolledToUnread = false;
  bool _contextDropdownOpen = false;
  ChatConversation? _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
    _listScrollController.addListener(_onMessagesScroll);

    // Opened from a notification or deep link: no list row was passed.
    if (_conversation == null) {
      _loadConversation();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(conversationsProvider).conversations.isEmpty) {
        ref
            .read(conversationsProvider.notifier)
            .loadConversations(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    try {
      final conversation = await ref
          .read(conversationV2ServiceProvider)
          .fetchConversation(widget.conversationId);
      if (mounted) setState(() => _conversation = conversation);
    } catch (_) {
      // The thread still renders; the app bar falls back to the id.
    }
  }

  void _onMessagesScroll() {
    if (!_listScrollController.hasClients) return;
    if (_listScrollController.position.pixels <= 120) {
      ref
          .read(chatMessagesProvider(widget.conversationId).notifier)
          .loadOlder();
    }
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

  Future<void> _startCall({required bool isVideo}) async {
    final l10n = AppLocalizations.of(context);
    try {
      final conf = await ref.read(conferenceV2ServiceProvider).startDirect(
            conversationId: widget.conversationId,
            isVideo: isVideo,
          );
      final joinResult =
          await ref.read(conferenceV2ServiceProvider).join(conf.id);
      if (mounted) {
        context.push('/call/${conf.id}', extra: {
          'url': joinResult.credentials.url,
          'token': joinResult.credentials.token,
          'is_video': isVideo,
        });
      }
    } on ApiV2Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
            content: Text(l10n.commonError),
            backgroundColor: AppColors.error,
          ),
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

  void _scrollToFirstUnread(List<ChatMessage> messages) {
    if (_hasScrolledToUnread || messages.isEmpty) return;

    int firstUnreadIndex = -1;
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (!message.isMine && !message.isRead) {
        firstUnreadIndex = i;
        break;
      }
    }

    _hasScrolledToUnread = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listScrollController.hasClients) return;

      if (firstUnreadIndex >= 0) {
        final double offset = firstUnreadIndex * 80.0;
        _listScrollController.animateTo(
          offset.clamp(0, _listScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } else {
        _scrollToBottom();
      }
    });
  }

  /// Threads about the same listing are switchable from the app bar.
  List<ChatConversation> _relatedConversations(ConversationsState state) {
    final listingId = _conversation?.listing?.id;
    if (listingId == null) return const [];

    return state.conversations
        .where(
          (conversation) =>
              conversation.id != widget.conversationId &&
              conversation.listing?.id == listingId,
        )
        .toList();
  }

  Widget _buildContextDropdown(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    List<ChatConversation> relatedConversations,
  ) {
    return GestureDetector(
      onTap: _closeContextDropdown,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: LiquidGlass(
          borderRadius: 16,
          blur: 24,
          variant: LiquidGlassVariant.prominent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: context.isDarkMode
                      ? AppColors.primary900
                      : context.theme.textMuted,
                  child: Text(
                    l10n.messagesSwitchContext,
                    style: AppTextStyles.caption.copyWith(
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
                      final conversation = relatedConversations[index];
                      final isSelected =
                          conversation.id == widget.conversationId;
                      return _buildContextItem(
                        conversation,
                        isSelected,
                        l10n,
                        isDark,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextItem(
    ChatConversation conversation,
    bool isSelected,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final imageUrl = conversation.listing?.coverImage?.url;
    final isAssetChat = conversation.hasListing;

    return InkWell(
      onTap: () {
        _closeContextDropdown();
        if (conversation.id != widget.conversationId) {
          context.pushReplacement(
            '/chat/${conversation.id}',
            extra: conversation,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected
            ? (isDark ? AppColors.primary700 : AppColors.primary50)
            : null,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isAssetChat
                    ? (isDark ? AppColors.primary700 : AppColors.primary100)
                    : (isDark ? AppColors.stone700 : AppColors.stone100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 72,
                        memCacheHeight: 72,
                        errorWidget: (_, __, ___) => Icon(
                          isAssetChat ? Icons.home : Icons.chat,
                          size: 18,
                          color: ThemeColors(context).textPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      isAssetChat ? Icons.home : Icons.chat,
                      size: 18,
                      color: isAssetChat
                          ? ThemeColors(context).textPrimary
                          : AppColors.stone500,
                    ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title.isNotEmpty
                        ? conversation.title
                        : l10n.messagesTitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isDark ? AppColors.stone100 : AppColors.stone900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (conversation.hasUnread)
                        Text(
                          '${conversation.unreadCount} ${l10n.messagesUnread}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        )
                      else if (conversation.lastMessageAt != null)
                        Text(
                          _formatRelativeTime(conversation.lastMessageAt!),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: context.theme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 18,
                color: context.theme.textPrimary,
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

  Widget _buildMessagesList(
    ChatMessagesState state,
    AppLocalizations l10n,
  ) {
    final messages = state.messages;

    // Trigger scroll to first unread on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstUnread(messages);
    });

    int firstUnreadIndex = -1;
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (!message.isMine && !message.isRead) {
        firstUnreadIndex = i;
        break;
      }
    }

    final headerCount = state.isLoadingMore ? 1 : 0;

    return ListView.builder(
      controller: _listScrollController,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length + headerCount,
      itemBuilder: (context, index) {
        if (headerCount == 1 && index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final messageIndex = index - headerCount;
        final message = messages[messageIndex];

        if (messageIndex == firstUnreadIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? AppColors.accent950
                      : AppColors.accent100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.messagesUnreadMessages,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent500,
                  ),
                ),
              ),
              _MessageBubble(message: message),
            ],
          );
        }

        return _MessageBubble(message: message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatMessagesProvider(widget.conversationId));
    final conversationsState = ref.watch(conversationsProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final conversation = _conversation;
    final otherName = conversation?.otherParticipant?.displayName ?? '';
    final listingTitle = conversation?.listing?.title;
    final title = listingTitle?.isNotEmpty == true
        ? listingTitle!
        : (otherName.isNotEmpty ? otherName : '#${widget.conversationId}');
    final showSubtitle =
        listingTitle?.isNotEmpty == true && otherName.isNotEmpty;

    final relatedConversations = _relatedConversations(conversationsState);

    return Scaffold(
      appBar: WaveAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 48),
        ),
        title: GestureDetector(
          onTap:
              relatedConversations.isNotEmpty ? _toggleContextDropdown : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (relatedConversations.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _contextDropdownOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: context.theme.iconSecondary,
                    ),
                  ],
                ],
              ),
              if (showSubtitle)
                Text(
                  l10n.messagesWith(otherName),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: context.theme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (conversation?.otherParticipant != null) ...[
            IconButton(
              icon: const Icon(Icons.call, size: 22),
              tooltip: 'Audio Call',
              onPressed: () => _startCall(isVideo: false),
            ),
            IconButton(
              icon: const Icon(Icons.videocam, size: 22),
              tooltip: 'Video Call',
              onPressed: () => _startCall(isVideo: true),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Messages list
              Expanded(
                child: chatState.isLoading && chatState.messages.isEmpty
                    ? _buildMessagesSkeleton()
                    : chatState.errorMessage != null &&
                            chatState.messages.isEmpty
                        ? WaveMessageScreen.error(
                            isEmbedded: true,
                            title: l10n.errorLoadingMessages,
                            subtitle: chatState.errorMessage!,
                            onRetry: () {
                              ref
                                  .read(chatMessagesProvider(
                                          widget.conversationId)
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
                                        size: 64,
                                        color: context.theme.iconSecondary),
                                    const SizedBox(height: 16),
                                    Text(l10n.messagesEmpty,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                            color:
                                                context.theme.iconSecondary)),
                                  ],
                                ),
                              )
                            : _buildMessagesList(chatState, l10n),
              ),

              // Message input
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? AppColors.primary900
                      : AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary950.withValues(alpha: 0.05),
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
                              borderRadius: BorderRadius.circular(12),
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
                          color: _isSending
                              ? context.theme.textMuted
                              : AppColors.accent500,
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
                              : const Icon(Icons.send,
                                  color: AppColors.surface),
                          onPressed: _isSending ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Context dropdown overlay
          if (_contextDropdownOpen) ...[
            GestureDetector(
              onTap: _closeContextDropdown,
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: _buildContextDropdown(
                  context,
                  l10n,
                  isDark,
                  relatedConversations,
                ),
              ),
            ),
          ],
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
        child: Shimmer.fromColors(
          baseColor: context.shimmerBase,
          highlightColor: context.shimmerHighlight,
          child: Row(
            mainAxisAlignment:
                isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isLeft) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.stone200,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                height: 40,
                width: 120 + (index * 20),
                decoration: BoxDecoration(
                  color: AppColors.stone200,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
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
                    color: AppColors.stone200,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String _displayTime(DateTime? dt, AppLocalizations l10n) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return l10n.notificationJustNow;
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

/// Message Bubble Widget - WhatsApp-like with actual user initials
class _MessageBubble extends ConsumerWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isOwn = message.isMine;
    final isSeen = message.isRead || message.readAt != null;
    final sender = message.sender;
    final authUser = authState.user;

    final avatarUrl =
        sender?.avatarUrl ?? (isOwn ? authUser?.googleAvatar : null);
    final initials = sender?.initials.isNotEmpty == true
        ? sender!.initials
        : (isOwn && authUser != null ? authUser.initials : '?');
    final l10n = AppLocalizations.of(context);

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
                image: avatarUrl != null
                    ? DecorationImage(
                        image: ResizeImage(
                          CachedNetworkImageProvider(avatarUrl),
                          width: 64,
                          height: 64,
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: avatarUrl != null
                    ? null
                    : LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer
                        ],
                      ),
                shape: BoxShape.circle,
              ),
              child: avatarUrl != null
                  ? null
                  : Center(
                      child: Text(
                        initials,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? AppColors.primary900
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOwn
                        ? (context.isDarkMode
                            ? AppColors.accent600
                            : AppColors.primary600)
                        : context.cardBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isOwn ? 16 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 16),
                    ),
                    boxShadow: context.isDarkMode ? null : AppColors.shadowSm,
                    border: isOwn
                        ? null
                        : Border.all(
                            color: context.divider.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: isOwn
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.body,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isOwn ? Colors.white : context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _displayTime(message.createdAt, l10n),
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: isOwn
                                  ? AppColors.surface.withValues(alpha: 0.7)
                                  : context.theme.textMuted,
                            ),
                          ),
                          if (isOwn) ...[
                            const SizedBox(width: 4),
                            Icon(
                              isSeen ? Icons.done_all : Icons.done,
                              size: 14,
                              color: isSeen
                                  ? AppColors.accent300
                                  : AppColors.surface.withValues(alpha: 0.5),
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
                image: avatarUrl != null
                    ? DecorationImage(
                        image: ResizeImage(
                          CachedNetworkImageProvider(avatarUrl),
                          width: 64,
                          height: 64,
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: avatarUrl != null
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.accent400, AppColors.accent600],
                      ),
                shape: BoxShape.circle,
              ),
              child: avatarUrl != null
                  ? null
                  : Center(
                      child: Text(
                        initials,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? AppColors.primary900
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
