import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/services/kyc_service.dart';
import '../../../../data/services/listing_media_manager.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../widgets/common/wave_common_widgets.dart';

enum _KycStep { phone, otp, documents }

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
  KycService get _kycService => ref.read(kycServiceProvider);
  final List<String> _persistedPaths = [];

  bool _showFormManually = false;

  // Phone & OTP state
  final TextEditingController _phoneController = TextEditingController();
  CountryCode _selectedCountry = Countries.defaultCountry;
  _KycStep _kycStep = _KycStep.phone;
  bool _otpLoading = false;
  bool _otpVerifyLoading = false;
  String _otpError = '';
  String _otpDestination = 'phone';
  int _resendCooldown = 0;
  Timer? _resendTimer;
  final TextEditingController _otpController = TextEditingController();

  String get _fullPhone => '${_selectedCountry.code}${_phoneController.text.trim()}';

  void _cleanPersistedFiles() {
    for (final path in _persistedPaths) {
      final file = File(path);
      if (file.existsSync()) {
        file.delete();
      }
    }
    _persistedPaths.clear();
  }

  @override
  void dispose() {
    _cleanPersistedFiles();
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

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
      );

      if (image != null) {
        final persisted = await ListingMediaManager.persistFile(image);
        _persistedPaths.add(persisted.path);
        setState(() {
          switch (type) {
            case 'front':
              _frontImage = File(persisted.path);
              break;
            case 'back':
              _backImage = File(persisted.path);
              break;
            case 'selfie':
              _selfieImage = File(persisted.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.kycError(e.toString())), backgroundColor: AppColors.error));
      }
    }
  }

  void _showImagePickerOptions(String type) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    if (type == 'selfie') {
      _pickImage(ImageSource.camera, type);
      return;
    }

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

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _otpError = 'Please enter your phone number');
      return;
    }
    if (phone.length < 7) {
      setState(() => _otpError = 'Phone number must be at least 7 digits');
      return;
    }

    setState(() {
      _otpLoading = true;
      _otpError = '';
    });

    final response = await _kycService.sendOtp(
      phoneNumber: phone,
      countryCode: _selectedCountry.code,
    );

    if (mounted) {
      setState(() {
        _otpLoading = false;
        if (response.success) {
          _kycStep = _KycStep.otp;
          _otpDestination = response.destination ?? 'phone';
          _startResendCooldown();
        } else {
          _otpError = response.message;
        }
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    setState(() {
      _otpVerifyLoading = true;
      _otpError = '';
    });

    final response = await _kycService.verifyOtp(
      phoneNumber: _phoneController.text.trim(),
      countryCode: _selectedCountry.code,
      otpCode: otp,
    );

    if (mounted) {
      setState(() {
        _otpVerifyLoading = false;
        if (response.success) {
          _kycStep = _KycStep.documents;
          _resendTimer?.cancel();
        } else {
          _otpError = response.message;
        }
      });
    }
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          timer.cancel();
          _resendTimer = null;
        }
      });
    });
  }

  void _changeNumber() {
    setState(() {
      _kycStep = _KycStep.phone;
      _otpError = '';
      _otpController.clear();
    });
  }

  Future<void> _submitKyc() async {
    final l10n = AppLocalizations.of(context);
    if (_documentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.kycSelectDocumentType), backgroundColor: AppColors.error));
      return;
    }

    if (_frontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.kycUploadFront), backgroundColor: AppColors.error));
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
        _cleanPersistedFiles();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.kycSuccess), backgroundColor: AppColors.success));
        ref.read(kycStatusProvider.notifier).loadKycStatus();
        ref.read(profileProvider.notifier).loadProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message), backgroundColor: AppColors.error));
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
    if (state.hasError) {
      return _buildErrorState(state, l10n);
    }

    if (state.isVerified || state.isApproved) {
      return _buildVerifiedState(state, l10n);
    }

    if (state.isPending && !_showFormManually) {
      return _buildPendingState(state, l10n);
    }

    if (state.isRejected && !_showFormManually) {
      return _buildRejectedState(state, l10n);
    }

    final profile = ref.watch(profileProvider);
    final needsPhone = profile.user?.phoneNumber?.isEmpty ?? true;

    // If user already has a phone, skip to documents
    if (!needsPhone && _kycStep != _KycStep.documents) {
      _kycStep = _KycStep.documents;
    }

    return _buildMultiStepForm(state, l10n, needsPhone);
  }

  Widget _buildMultiStepForm(KycStatusState state, AppLocalizations l10n, bool needsPhone) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (needsPhone) ...[
            _buildPhoneStep(l10n),
            if (_kycStep == _KycStep.otp)
              _buildOtpStep(l10n),
            const SizedBox(height: 24),
          ],

          if (_kycStep == _KycStep.documents || !needsPhone)
            _buildDocumentsStep(state, l10n),
        ],
      ),
    );
  }

  Widget _buildPhoneStep(AppLocalizations l10n) {
    if (_kycStep == _KycStep.otp || _kycStep == _KycStep.documents) return const SizedBox.shrink();

    return LiquidGlass(
      borderRadius: 4,
      blur: 20,
      variant: LiquidGlassVariant.regular,
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_android_rounded, size: 18, color: AppColors.primary600),
              const SizedBox(width: 8),
              Text(
                'Verify Your Phone',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'We need to verify your phone number before proceeding',
            style: AppTextStyles.caption.copyWith(color: context.textMuted),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: context.theme.isDark
                  ? AppColors.primary900
                  : AppColors.primary50.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: context.theme.isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.primary200,
              ),
            ),
            child: Row(
              children: [
                CountrySelectorDropdown(
                  selectedCountry: _selectedCountry,
                  onCountrySelected: (country) {
                    setState(() => _selectedCountry = country);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: _selectedCountry.example,
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: context.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary),
                    onChanged: (_) {
                      if (_otpError.isNotEmpty) setState(() => _otpError = '');
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_otpError.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _otpError,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 16),
          WaveButton(
            text: 'Send Verification Code',
            icon: Icons.send_rounded,
            isLoading: _otpLoading,
            onPressed: _otpLoading ? null : _sendOtp,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(AppLocalizations l10n) {
    return LiquidGlass(
      borderRadius: 4,
      blur: 20,
      variant: LiquidGlassVariant.regular,
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sent info
          Row(
            children: [
              Icon(
                _otpDestination == 'phone' ? Icons.phone_android_rounded : Icons.email_rounded,
                size: 16,
                color: AppColors.primary600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _otpDestination == 'phone'
                          ? 'Code sent via SMS to'
                          : 'Code sent to your email',
                      style: AppTextStyles.caption.copyWith(color: context.textMuted),
                    ),
                    Text(
                      _fullPhone,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // OTP Input
          TextField(
            controller: _otpController,
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: AppTextStyles.headline2.copyWith(
                color: context.textMuted,
                letterSpacing: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: context.theme.isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: context.theme.isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.primary600),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.headline2.copyWith(
              color: context.textPrimary,
              letterSpacing: 8,
              fontFamily: 'monospace',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            autofillHints: const [AutofillHints.oneTimeCode],
            onChanged: (val) {
              if (_otpError.isNotEmpty) setState(() => _otpError = '');
              if (val.length == 6) _verifyOtp();
            },
          ),

          if (_otpError.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _otpError,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],

          const SizedBox(height: 16),
          WaveButton(
            text: 'Verify & Continue',
            icon: Icons.verified_rounded,
            isLoading: _otpVerifyLoading,
            onPressed: _otpVerifyLoading ? null : _verifyOtp,
            isFullWidth: true,
            variant: ButtonVariant.success,
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _changeNumber,
                icon: const Icon(Icons.edit, size: 16),
                label: Text(
                  'Change number',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: _resendCooldown > 0 ? null : _sendOtp,
                child: Text(
                  _resendCooldown > 0
                      ? 'Resend in ${_resendCooldown}s'
                      : 'Resend code',
                  style: AppTextStyles.caption.copyWith(
                    color: _resendCooldown > 0
                        ? context.textMuted
                        : AppColors.primary600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(KycStatusState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        LiquidGlass(
          borderRadius: 4,
          blur: 20,
          variant: LiquidGlassVariant.regular,
          padding: AppSpacing.paddingLg,
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
    );
  }

  Widget _buildErrorState(KycStatusState state, AppLocalizations l10n) {
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
                color: context.theme.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.signal_wifi_off_rounded,
                size: 60,
                color: context.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.kycConnectionErrorTitle,
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? l10n.kycConnectionErrorSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.theme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            WaveButton(
              text: l10n.kycRetry,
              icon: Icons.refresh,
              onPressed: () {
                ref.read(kycStatusProvider.notifier).loadKycStatus();
              },
              variant: ButtonVariant.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
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
      context.push('/listings/create');
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
              LiquidGlass(
                borderRadius: 4,
                blur: 16,
                variant: LiquidGlassVariant.regular,
                tint: AppColors.error,
                padding: AppSpacing.paddingLg,
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

  Widget _buildImageUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    File? image,
    required VoidCallback onTap,
    required AppLocalizations l10n,
  }) {
    return LiquidGlass(
      borderRadius: 4,
      blur: 20,
      variant: LiquidGlassVariant.regular,
      interactive: true,
      onTap: onTap,
      padding: AppSpacing.paddingLg,
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
