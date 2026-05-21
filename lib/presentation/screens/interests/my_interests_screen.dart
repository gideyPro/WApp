import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_glass.dart';
import '../listing/listing_detail_screen.dart';

class MyInterestsScreen extends ConsumerStatefulWidget {
  const MyInterestsScreen({super.key});

  @override
  ConsumerState<MyInterestsScreen> createState() => _MyInterestsScreenState();
}

class _MyInterestsScreenState extends ConsumerState<MyInterestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myInterestsProvider.notifier).loadInterests();
    });
  }

  Color _stageColor(String? stage) {
    switch (stage) {
      case 'contacted':
        return AppColors.primary900;
      case 'new':
        return AppColors.warning;
      case 'negotiating':
      case 'offer':
        return AppColors.emerald500;
      case 'won':
        return AppColors.emerald600;
      case 'lost':
        return AppColors.error;
      default:
        return AppColors.primary400;
    }
  }

  String _stageLabel(String? stage) {
    switch (stage) {
      case 'new':
        return 'New';
      case 'contacted':
        return 'Contacted';
      case 'negotiating':
        return 'Negotiating';
      case 'offer':
        return 'Offer';
      case 'won':
        return 'Won';
      case 'lost':
        return 'Lost';
      default:
        return stage ?? 'Unknown';
    }
  }

  Future<void> _cancelInterest(int interestId) async {
    final service = ref.read(leadServiceProvider);
    final response = await service.cancelInterest(interestId);
    if (mounted) {
      if (response.success) {
        ref.read(myInterestsProvider.notifier).loadInterests();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.emerald600,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final interestsState = ref.watch(myInterestsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.profileMyInterests),
        backgroundColor: context.cardBg,
        surfaceTintColor: context.cardBg,
      ),
      body: interestsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : interestsState.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: context.textSecondary),
                        const SizedBox(height: 16),
                        Text(interestsState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: context.textSecondary)),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: () => ref
                              .read(myInterestsProvider.notifier)
                              .loadInterests(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                )
              : interestsState.interests.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.interests_outlined,
                                size: 80,
                                color: context.textSecondary
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text(
                              'No interests yet',
                              style: AppTextStyles.title,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Properties you express interest in will appear here',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(myInterestsProvider.notifier)
                          .loadInterests(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        itemCount: interestsState.interests.length,
                        itemBuilder: (context, index) {
                          final lead = interestsState.interests[index];
                          final listing = lead.listing;
                          final listingId = lead.listingId;
                          final stage = lead.stage;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: WaveGlass(
                              borderRadius: 12,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  if (listingId > 0) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ListingDetailScreen(
                                            listingId: listingId),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _stageColor(stage)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _stageLabel(stage),
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color: _stageColor(stage),
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (lead.buyerMessage != null &&
                                              lead.buyerMessage!.isNotEmpty)
                                            Icon(Icons.message_outlined,
                                                size: 16,
                                                color: context.textSecondary),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () =>
                                                _cancelInterest(lead.id),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.error
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 16,
                                                  color: AppColors.error),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (lead.buyerMessage != null &&
                                          lead.buyerMessage!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: context.theme.isDark
                                                ? AppColors.primary800
                                                : AppColors.primary50,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: context.divider
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Text(
                                            lead.buyerMessage!,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                              color: context.textSecondary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                      if (listing != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          listing['title'] ??
                                              listing['description'] ??
                                              'Listing #$listingId',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (listing['price_fixed'] != null ||
                                            listing['price'] != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              'ETB ${_formatPrice(listing['price_fixed'] ?? listing['price'])}',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                color: AppColors.accent600,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time_rounded,
                                              size: 14,
                                              color: context.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(lead.createdAt),
                                            style: AppTextStyles.caption
                                                .copyWith(
                                              color: context.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final n = price is int ? price : (price is double ? price : 0);
    final formatter =
        NumberFormat('#,##0', AppLocalizations.of(context).localeName);
    return formatter.format(n);
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final formatter = DateFormat('MMM d, yyyy');
      return formatter.format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}
