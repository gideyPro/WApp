import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/services/kyc_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../listing/create_listing_screen.dart';
import '../../../../l10n/app_localizations.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.kycError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions(String type) {
    final l10n = AppLocalizations.of(context);
    // For selfies, always open camera directly
    if (type == 'selfie') {
      _pickImage(ImageSource.camera, type);
      return;
    }

    // For document images, show picker options
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'), // Generic enough
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'), // Generic enough
              onTap: () {
                Navigator.pop(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.kycSelectDocumentType),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_frontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.kycUploadFront),
          backgroundColor: AppColors.error,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.kycSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(kycStatusProvider.notifier).loadKycStatus();
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
    final kycState = ref.watch(kycStatusProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
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
              decoration: BoxDecoration(
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
                color: AppColors.navy600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            WaveButton(
              text: l10n.kycCreateListing,
              icon: Icons.add,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const CreateListingScreen()),
                );
              },
              variant: ButtonVariant.success,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
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
              decoration: BoxDecoration(
                color: AppColors.wave50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pending_actions,
                size: 60,
                color: AppColors.wave600,
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
                color: AppColors.navy600,
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
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                size: 60,
                color: Colors.red[600],
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  l10n.kycRejectedReason(state.rejectionReason!),
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              l10n.kycRejectedSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.navy600,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navy50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.navy200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.navy600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.kycInfoBanner,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.navy700,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null ? AppColors.wave300 : AppColors.zinc200,
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
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 28, color: AppColors.zinc400),
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
              color: image != null ? AppColors.wave600 : AppColors.zinc400,
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
          color: isSelected ? AppColors.wave50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.wave400 : AppColors.zinc200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.wave600 : AppColors.zinc500,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.wave700 : AppColors.navy600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
