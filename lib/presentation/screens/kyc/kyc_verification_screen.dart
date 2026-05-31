import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/services/kyc_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../listing/create_listing_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// KYC Verification Screen
class KycVerificationScreen extends ConsumerStatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  ConsumerState<KycVerificationScreen> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen> {
  String? _documentType = 'national_id';
  File? _frontImage;
  File? _backImage;
  File? _selfieImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();
  final KycService _kycService = KycService();

  bool _showFormManually = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kycStatusProvider.notifier).loadKycStatus();
    });
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          switch (type) {
            case 'front':
              _frontImage = File(image.path);
              break;
            case 'back':
              _backImage = File(image.path);
              break;
            case 'selfie':
              _selfieImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, l10n.kycError(e.toString()));
      }
    }
  }

  void _showImagePickerOptions(String type) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    // For selfies, always open camera directly
    if (type == 'selfie') {
      _pickImage(ImageSource.camera, type);
      return;
    }

    // For document images, show picker options
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bottomSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: theme.textPrimary),
              title: Text(l10n.kycTakePhoto,
                  style: TextStyle(color: theme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera, type);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: theme.textPrimary),
              title: Text(l10n.kycChooseGallery,
                  style: TextStyle(color: theme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery, type);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitKyc() async {
    final l10n = AppLocalizations.of(context);
    if (_documentType == null) {
      WaveToast.showError(context, l10n.kycSelectDocumentType);
      return;
    }

    if (_frontImage == null) {
      WaveToast.showError(context, l10n.kycUploadFront);
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await _kycService.submitKyc(
      documentType: _documentType!,
      frontImage: _frontImage!,
      backImage: _backImage,
      selfieImage: _selfieImage,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (response.success) {
        WaveToast.showSuccess(context, l10n.kycSuccess);
        ref.read(kycStatusProvider.notifier).loadKycStatus();
      } else {
        WaveToast.showError(context, response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycStatusProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: WaveAppBar(
        title: Text(l10n.kycTitle),
      ),
      body: kycState.isLoading && kycState.status == 'none'
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(kycStatusProvider.notifier).loadKycStatus();
              },
              child: _buildBody(kycState, l10n),
            ),
    );
  }

  Widget _buildBody(KycStatusState state, AppLocalizations l10n) {
    // Verified state
    if (state.isVerified || state.isApproved) {
      return _buildVerifiedState(state, l10n);
    }

    // Pending state
    if (state.isPending && !_showFormManually) {
      return _buildPendingState(state, l10n);
    }

    // Rejected state
    if (state.isRejected && !_showFormManually) {
      return _buildRejectedState(state, l10n);
    }

    // Not submitted state or manual form show - show form
    return _buildKycForm(state, l10n);
  }

  Widget _buildVerifiedState(KycStatusState state, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.emerald50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user,
                size: 60,
                color: AppColors.emerald600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.kycVerifiedTitle,
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.kycVerifiedSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.theme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            WaveButton(
              text: l10n.kycCreateListing,
              icon: Icons.add,
              onPressed: _onCreateListingFromKyc,
              variant: ButtonVariant.success,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreateListingFromKyc() async {
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateListingScreen()),
      );
    }
  }

  Widget _buildPendingState(KycStatusState state, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.accent50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pending_actions,
                size: 60,
                color: AppColors.accent600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.kycPendingTitle,
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.kycPendingSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary600,
              ),
              textAlign: TextAlign.center,
            ),
            if (state.submittedAt != null) ...[
              const SizedBox(height: 16),
              Text(
                l10n.kycSubmittedAt(state.submittedAt!),
                style: AppTextStyles.caption,
              ),
            ],
            const SizedBox(height: 32),
            WaveButton(
              text: l10n.kycRefreshStatus,
              icon: Icons.refresh,
              onPressed: () {
                ref.read(kycStatusProvider.notifier).loadKycStatus();
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedState(KycStatusState state, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 60,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.kycRejectedTitle,
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 12),
            if (state.rejectionReason != null) ...[
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.errorLight),
                ),
                child: Text(
                  l10n.kycRejectedReason(state.rejectionReason!),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              l10n.kycRejectedSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            WaveButton(
              text: l10n.kycResubmit,
              icon: Icons.upload_file,
              onPressed: () {
                setState(() {
                  _showFormManually = true;
                });
              },
              variant: ButtonVariant.danger,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycForm(KycStatusState state, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primary200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.kycInfoBanner,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Document type selection
          Text(
            l10n.kycDocumentType,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DocumentTypeChip(
                  icon: Icons.credit_card,
                  label: l10n.kycNationalId,
                  isSelected: _documentType == 'national_id',
                  onTap: () => setState(() => _documentType = 'national_id'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DocumentTypeChip(
                  icon: Icons.badge,
                  label: l10n.kycPassport,
                  isSelected: _documentType == 'passport',
                  onTap: () => setState(() => _documentType = 'passport'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Front image upload
          _buildImageUploadCard(
            icon: Icons.credit_card,
            title: l10n.kycFrontOfDocument,
            subtitle: l10n.kycFrontSubtitle,
            image: _frontImage,
            onTap: () => _showImagePickerOptions('front'),
            l10n: l10n,
          ),
          const SizedBox(height: 16),

          // Back image upload (only for National ID)
          if (_documentType == 'national_id') ...[
            _buildImageUploadCard(
              icon: Icons.credit_card,
              title: l10n.kycBackOfDocument,
              subtitle: l10n.kycBackSubtitle,
              image: _backImage,
              onTap: () => _showImagePickerOptions('back'),
              l10n: l10n,
            ),
            const SizedBox(height: 16),
          ],

          // Selfie upload
          _buildImageUploadCard(
            icon: Icons.person,
            title: l10n.kycSelfieWithDocument,
            subtitle: l10n.kycSelfieSubtitle,
            image: _selfieImage,
            onTap: () => _showImagePickerOptions('selfie'),
            l10n: l10n,
          ),
          const SizedBox(height: 32),

          // Submit button
          WaveButton(
            text: l10n.kycSubmitForVerification,
            icon: Icons.upload_file,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submitKyc,
            isFullWidth: true,
            variant: ButtonVariant.success,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildImageUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    File? image,
    required VoidCallback onTap,
    required AppLocalizations l10n,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: image != null ? AppColors.accent300 : AppColors.stone200,
          ),
        ),
        child: Row(
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.stone100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 28, color: ThemeColors(context).textMuted),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image != null ? l10n.kycTapToChange : subtitle,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Icon(
              image != null ? Icons.check_circle : Icons.add_circle_outline,
              color: image != null ? AppColors.accent600 : AppColors.stone400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Document Type Selection Chip
class _DocumentTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DocumentTypeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent50 : context.cardBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.accent400 : AppColors.stone200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.accent600 : ThemeColors(context).textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.accent700 : AppColors.primary600,
                fontWeight:           isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
