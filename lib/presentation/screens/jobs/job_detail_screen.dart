import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_providers.dart';
import '../../widgets/common/wave_card.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final int listingId;
  const JobDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobDetailProvider.notifier).loadListing(widget.listingId);
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(jobDetailProvider);
    final authState = ref.watch(authStateProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Job Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null && state.listing == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Job Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${state.errorMessage}'),
              ElevatedButton(
                onPressed: () => ref.read(jobDetailProvider.notifier).loadListing(widget.listingId),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    final listing = state.listing;
    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Job Details')),
        body: const Center(child: Text('Job not found')),
      );
    }

    final currentUserId = authState.user?.id;
    final isOwner = currentUserId != null && listing.userId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/jobs/${widget.listingId}/edit', extra: listing),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(listing.jobCompanyName ?? 'View', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (listing.description != null) Text(listing.description!),
            const SizedBox(height: 24),
            if (!isOwner && listing.sellerPhone != null && listing.sellerPhone!.isNotEmpty)
              _buildEmployerContact(listing, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployerContact(Listing listing, AppLocalizations l10n) {
    final phone = listing.sellerPhone!;
    final name = listing.sellerName ?? 'Employer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Contact Employer', style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
        ),
        WaveCard(
          useLiquidGlass: true,
          isGlass: true,
          showBorder: false,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.theme.cardBg,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'E',
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent600, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600, color: context.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (listing.userContactHidden != true) ...[
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.phone,
                      label: 'Call',
                      hint: 'Call'Hint,
                      color: const Color(0xFF4CAF50),
                      onTap: () => _launchUrl('tel:$phone'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.chat_bubble_outline,
                      label: 'WhatsApp',
                      hint: 'WhatsApp'Hint,
                      color: const Color(0xFF25D366),
                      onTap: () => _launchUrl('https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.send,
                      label: 'Telegram',
                      hint: 'Telegram'Hint,
                      color: const Color(0xFF0088CC),
                      onTap: () => _launchUrl('https://t.me/+${phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hint,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
