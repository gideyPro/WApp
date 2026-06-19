import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/listing.dart';
import '../../../providers/listing_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../data/services/listing_service.dart';
import '../../../widgets/common/wave_upgrade_card.dart';
import '../../../widgets/common/wave_liquid_glass.dart';

class ListingContactForm extends ConsumerStatefulWidget {
  final Listing listing;
  final bool isOwner;

  const ListingContactForm({
    super.key,
    required this.listing,
    required this.isOwner,
  });

  @override
  ConsumerState<ListingContactForm> createState() =>
      _ListingContactFormState();
}

class _ListingContactFormState extends ConsumerState<ListingContactForm> {
  bool _isRevealingContact = false;
  String? _revealedContact;
  String? _revealedName;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        if (!widget.isOwner && !listing.contactRevealed && !listing.interestBlocked && !listing.contactModerated) ...[
          const SizedBox(height: 12),
          if (listing.userContactHidden)
            _buildContactUpgradeSection(l10n)
          else if (listing.contactMax > 0)
            _buildContactRevealSection(l10n),
        ],
        if (!widget.isOwner && listing.contactRevealed) ...[
          const SizedBox(height: 12),
          _buildRevealedContactSection(l10n),
        ],
      ],
    );
  }

  Widget _buildContactRevealSection(AppLocalizations l10n) {
    return LiquidGlass(
      borderRadius: 8,
      blur: 20,
      tint: AppColors.accent500,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 28, color: AppColors.accent600),
          const SizedBox(height: 8),
          Text(l10n.listingsRevealContact, style: AppTextStyles.title.copyWith(fontSize: 14)),
          if (widget.listing.contactMax > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.listingsContactViewsRemaining(widget.listing.contactRemaining, widget.listing.contactMax),
              style: AppTextStyles.caption.copyWith(color: AppColors.stone500),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRevealingContact ? null : () => _revealContact(widget.listing.id),
              icon: _isRevealingContact
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.visibility_outlined, size: 18),
              label: Text(_isRevealingContact ? l10n.listingsRevealing : l10n.listingsRevealContact),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactUpgradeSection(AppLocalizations l10n) {
    return UpgradeCard(
      icon: Icons.lock_outline,
      iconColor: AppColors.accent500,
      title: l10n.upgradeToContact,
      subtitle: l10n.subscriptionRequiredDetailsSubtitle,
      buttonLabel: l10n.listingViewPlans,
    );
  }

  Widget _buildRevealedContactSection(AppLocalizations l10n) {
    final listing = widget.listing;
    final displayName = listing.revealedName ?? _revealedName;
    final displayContact = listing.revealedContact ?? _revealedContact;
    final contact = displayContact ?? '';

    return LiquidGlass(
      borderRadius: 8,
      blur: 20,
      tint: AppColors.success,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 28, color: AppColors.success),
          const SizedBox(height: 8),
          Text(
            displayName?.isNotEmpty == true ? displayName! : l10n.listingsSeller,
            style: AppTextStyles.title.copyWith(fontSize: 14, color: AppColors.success),
          ),
          const SizedBox(height: 8),
          if (contact.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: AppColors.stone500),
                const SizedBox(width: 6),
                SelectableText(
                  contact,
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ContactActionButton(
                  icon: Icons.chat_outlined,
                  color: const Color(0xFF25D366),
                  onTap: () => _launchUrl('https://wa.me/${contact.replaceAll('+', '').replaceAll(' ', '')}'),
                ),
                const SizedBox(width: 16),
                _ContactActionButton(
                  icon: Icons.send_outlined,
                  color: const Color(0xFF0088CC),
                  onTap: () => _launchUrl('https://t.me/+${contact.replaceAll('+', '').replaceAll(' ', '')}'),
                ),
                const SizedBox(width: 16),
                _ContactActionButton(
                  icon: Icons.phone_outlined,
                  color: const Color(0xFF4CAF50),
                  onTap: () => _launchUrl('tel:$contact'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _revealContact(int listingId) async {
    setState(() => _isRevealingContact = true);
    try {
      final listingService = ListingService();
      final response = await listingService.revealContact(listingId);
      if (response.success && mounted) {
        setState(() {
          _revealedContact = response.contact;
          _revealedName = response.name;
        });
        ref.read(listingDetailProvider.notifier).loadListing(listingId);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isRevealingContact = false);
    }
  }
}

class _ContactActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContactActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
      ),
    );
  }
}
