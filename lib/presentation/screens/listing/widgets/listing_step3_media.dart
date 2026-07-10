import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/listing_media_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_card.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../widgets/common/wave_liquid_glass.dart';

class ListingStep3Media extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  final List<String> stepErrors;
  final bool isMediaLocked;
  const ListingStep3Media({super.key, required this.formData, required this.onUpdate, this.stepErrors = const [], this.isMediaLocked = false});

  @override
  State<ListingStep3Media> createState() => _ListingStep3MediaState();
}

class _ListingStep3MediaState extends State<ListingStep3Media> {
  final _picker = ImagePicker();

  static const int _maxImageBytes = 10 * 1024 * 1024;
  static const int _maxVideoBytes = 100 * 1024 * 1024;

  Future<bool> _isFileValid(XFile file, {bool isVideo = false}) async {
    final size = await file.length();
    final limit = isVideo ? _maxVideoBytes : _maxImageBytes;
    if (size > limit) {
      final label = isVideo ? 'video' : 'image';
      final limitMb = isVideo ? '100MB' : '10MB';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label exceeds $limitMb limit. Please choose a smaller file.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _pickImages(bool isSitePlan) async {
    if (isSitePlan) {
      final file = await _picker.pickImage(
          imageQuality: 85, maxWidth: 1920, source: ImageSource.gallery);
      if (file != null && await _isFileValid(file)) {
        final persisted = await ListingMediaManager.persistFile(file);
        widget.onUpdate(widget.formData.copyWith(sitePlan: persisted));
      }
    } else {
      final files =
          await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1920);
      if (files.isNotEmpty) {
        final valid = <XFile>[];
        for (final f in files) {
          if (await _isFileValid(f)) valid.add(f);
        }
        if (valid.isNotEmpty) {
          final persisted = await ListingMediaManager.persistFiles(valid);
          widget.onUpdate(widget.formData
              .copyWith(images: [...widget.formData.images, ...persisted]));
        }
      }
    }
  }

  Future<void> _pickSingleFile(String type) async {
    final XFile? file;
    final bool isVideo = type == 'video';
    if (isVideo) {
      file = await _picker.pickVideo(
          source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
    } else {
      file = await _picker.pickImage(
          imageQuality: 85, maxWidth: 1920, source: ImageSource.gallery);
    }

    if (file != null && await _isFileValid(file, isVideo: isVideo)) {
      final persisted = await ListingMediaManager.persistFile(file);
      switch (type) {
        case 'sitePlan':
          widget.onUpdate(widget.formData.copyWith(sitePlan: persisted));
          break;
        case 'ownership':
          widget.onUpdate(widget.formData.copyWith(ownershipProof: persisted));
          break;
        case 'video':
          widget.onUpdate(widget.formData.copyWith(videoFile: persisted));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMediaLocked) {
      return _buildMediaLocked();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          _buildImagesSection(),
          const SizedBox(height: 16),
          _buildSitePlanSection(),
          const SizedBox(height: 16),
          if (widget.formData.holdingType == 'Cooperative')
            _buildOwnershipSection(),
          if (widget.formData.holdingType == 'Cooperative')
            const SizedBox(height: 16),
          _buildVideoSection(),
        ],
      ),
    );
  }

  Widget _buildMediaLocked() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: context.theme.textMuted),
              const SizedBox(height: 16),
              Text(
                l10n.listingMediaLockedTitle,
                style: AppTextStyles.title.copyWith(
                  color: context.theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.listingMediaLockedDesc,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.theme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaSection({required String title, required Widget child}) {
    return WaveCard(
      useLiquidGlass: true,
      isGlass: false,
      showShadow: false,
      showBorder: true,
      borderRadius: AppSpacing.borderRadiusMd,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.theme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _uploadZone({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return LiquidGlass(
      borderRadius: AppSpacing.borderRadiusMd,
      blur: 20,
      interactive: true,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 36, color: context.theme.iconSecondary),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textPrimary)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
          ],
        ],
      ),
    );
  }

  Widget _filePreviewCard({
    required String fileName,
    required String? subtitle,
    required IconData icon,
    required Widget? thumbnail,
    required VoidCallback onRemove,
    required VoidCallback onPreview,
  }) {
    return LiquidGlass(
      borderRadius: AppSpacing.borderRadiusMd,
      blur: 20,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 64,
                height: 64,
                child: thumbnail,
              ),
            )
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.theme.iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 28, color: context.theme.iconSecondary),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
                ],
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onPreview,
                  child: Text('Tap to preview', style: AppTextStyles.caption.copyWith(color: context.theme.primary, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, {String? url, File? file}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: url != null
                  ? Image.network(url, fit: BoxFit.contain)
                  : Image.file(file!, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 24, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(BuildContext context, String filePath) {
    context.push('/video-preview', extra: filePath);
  }

  Widget _buildImagesSection() {
    final l10n = AppLocalizations.of(context);
    final newImages = widget.formData.images;
    final existingImages = widget.formData.existingImages;
    final totalCount = existingImages.length -
        widget.formData.removedImageIds.length +
        newImages.length;

    return _mediaSection(
      title: l10n.listingImages,
      child: Column(
        children: [
          _uploadZone(
            icon: Icons.add_photo_alternate_outlined,
            label: l10n.listingTapToAdd,
            subtitle: 'JPEG, PNG, WebP',
            onTap: () => _pickImages(false),
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 108,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...existingImages
                      .where((img) =>
                          !widget.formData.removedImageIds.contains(img.id))
                      .map((img) => _ImageThumb(
                            url: img.imageUrl,
                            onRemove: () {
                              final removedIds =
                                  List<int>.from(widget.formData.removedImageIds)
                                    ..add(img.id);
                              widget.onUpdate(widget.formData
                                  .copyWith(removedImageIds: removedIds));
                            },
                          )),
                  ...newImages.map((file) => _ImageThumb(
                        file: File(file.path),
                        onRemove: () {
                          final updated = List<XFile>.from(newImages)
                            ..remove(file);
                          widget.onUpdate(widget.formData
                              .copyWith(images: updated));
                        },
                      )),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: LiquidGlass(
                      borderRadius: AppSpacing.borderRadiusMd,
                      blur: 20,
                      interactive: true,
                      onTap: () => _pickImages(false),
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add,
                              size: 28, color: context.theme.iconSecondary),
                          const SizedBox(height: 4),
                          Text('Add',
                              style: AppTextStyles.caption
                                  .copyWith(color: context.theme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.listingImagesSelected(totalCount),
                style: AppTextStyles.caption
                    .copyWith(color: context.theme.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSitePlanSection() {
    final l10n = AppLocalizations.of(context);
    final hasExisting = widget.formData.existingSitePlanUrl != null &&
        widget.formData.sitePlan == null &&
        !widget.formData.removeExistingSitePlan;
    final pickedFile = widget.formData.sitePlan;

    return _mediaSection(
      title: l10n.listingSitePlans,
      child: Column(
        children: [
          if (hasExisting)
            _existingSitePlanCard(),
          if (pickedFile != null) ...[
            _filePreviewCard(
              fileName: pickedFile.name,
              subtitle: _formatFileSize(pickedFile.path),
              icon: Icons.image,
              thumbnail: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(File(pickedFile.path),
                    width: 64, height: 64, fit: BoxFit.cover),
              ),
              onRemove: () =>
                  widget.onUpdate(widget.formData.copyWith(sitePlan: null)),
              onPreview: () => _showImagePreview(context,
                  file: File(pickedFile.path)),
            ),
            const SizedBox(height: 12),
          ],
          if (!hasExisting && pickedFile == null)
            _uploadZone(
              icon: Icons.map_outlined,
              label: l10n.listingTapToAdd,
              subtitle: 'Site plan image',
              onTap: () => _pickSingleFile('sitePlan'),
            )
          else
            _buildChangeButton('sitePlan', pickedFile),
        ],
      ),
    );
  }

  Widget _existingSitePlanCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _filePreviewCard(
        fileName: widget.formData.existingSitePlanUrl!.split('/').last,
        subtitle: 'Existing site plan',
        icon: Icons.image,
        thumbnail: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(widget.formData.existingSitePlanUrl!,
              width: 64, height: 64, fit: BoxFit.cover),
        ),
        onRemove: () => widget.onUpdate(
            widget.formData.copyWith(removeExistingSitePlan: true)),
        onPreview: () => _showImagePreview(context,
            url: widget.formData.existingSitePlanUrl),
      ),
    );
  }

  Widget _buildOwnershipSection() {
    final l10n = AppLocalizations.of(context);
    final hasExisting = widget.formData.existingOwnershipProofUrl != null &&
        widget.formData.ownershipProof == null;
    final pickedFile = widget.formData.ownershipProof;

    return _mediaSection(
      title: l10n.listingOwnershipProof,
      child: Column(
        children: [
          if (hasExisting) ...[
            LiquidGlass(
              borderRadius: 8,
              blur: 20,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.description_outlined,
                      size: 18, color: context.theme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.listingExistingFile(
                          widget.formData.existingOwnershipProofUrl!
                              .split('/')
                              .last),
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (pickedFile != null) ...[
            _filePreviewCard(
              fileName: pickedFile.name,
              subtitle: _formatFileSize(pickedFile.path),
              icon: Icons.image,
              thumbnail: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(File(pickedFile.path),
                    width: 64, height: 64, fit: BoxFit.cover),
              ),
              onRemove: () => widget.onUpdate(
                  widget.formData.copyWith(ownershipProof: null)),
              onPreview: () => _showImagePreview(context,
                  file: File(pickedFile.path)),
            ),
            const SizedBox(height: 12),
          ],
          if (!hasExisting && pickedFile == null)
            _uploadZone(
              icon: Icons.verified_outlined,
              label: l10n.listingTapToAdd,
              subtitle: 'Ownership document',
              onTap: () => _pickSingleFile('ownership'),
            )
          else
            _buildChangeButton('ownership', pickedFile),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    final l10n = AppLocalizations.of(context);
    final hasExisting = widget.formData.existingVideoUrl != null &&
        widget.formData.videoFile == null &&
        !widget.formData.deleteVideo;
    final pickedFile = widget.formData.videoFile;

    return _mediaSection(
      title: '${l10n.listingsVideoTour} *',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${l10n.listingVideoMaxSize} — Required',
              style: AppTextStyles.caption
                  .copyWith(color: context.theme.textMuted)),
          const SizedBox(height: 8),
          if (hasExisting)
            _existingVideoCard(),
          if (pickedFile != null) ...[
            _videoPreviewCard(pickedFile),
            const SizedBox(height: 12),
          ],
          if (!hasExisting && pickedFile == null)
            _uploadZone(
              icon: Icons.videocam_outlined,
              label: l10n.listingTapToAdd,
              subtitle: 'MP4, max 5 minutes',
              onTap: () => _pickSingleFile('video'),
            )
          else
            _buildChangeButton('video', pickedFile),
        ],
      ),
    );
  }

  Widget _existingVideoCard() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlass(
        borderRadius: AppSpacing.borderRadiusMd,
        blur: 20,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.theme.iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.videocam,
                  size: 28, color: context.theme.iconSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.listingExistingFile(
                        widget.formData.existingVideoUrl!.split('/').last),
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text('Existing video',
                      style: AppTextStyles.caption
                          .copyWith(color: context.theme.textMuted)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => widget.onUpdate(
                  widget.formData.copyWith(deleteVideo: true)),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, size: 16, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoPreviewCard(XFile file) {
    return LiquidGlass(
      borderRadius: AppSpacing.borderRadiusMd,
      blur: 20,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.theme.iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.play_circle_fill,
                    size: 32, color: AppColors.primary900),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.name,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(_formatFileSize(file.path),
                        style: AppTextStyles.caption
                            .copyWith(color: context.theme.textMuted)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onUpdate(
                    widget.formData.copyWith(videoFile: null)),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _playVideo(context, file.path),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Play Preview'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.theme.primary,
                side: BorderSide(color: context.theme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(String type, XFile? currentFile) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _pickSingleFile(type),
        icon: const Icon(Icons.swap_horiz, size: 18),
        label: Text(currentFile != null
            ? l10n.listingChangeFile(currentFile.name)
            : l10n.listingBrowseFile),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.theme.textSecondary,
          side: BorderSide(color: context.theme.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _formatFileSize(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) return '';
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return '';
    }
  }
}

class _ImageThumb extends StatelessWidget {
  final String? url;
  final File? file;
  final VoidCallback onRemove;

  const _ImageThumb({this.url, this.file, required this.onRemove});

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: url != null
                  ? Image.network(url!, fit: BoxFit.contain)
                  : Image.file(file!, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 24, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _showPreview(context),
        child: Stack(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: LiquidGlass(
                borderRadius: 10,
                blur: 12,
                child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: url != null
                    ? Image.network(url!,
                        width: 100, height: 100, fit: BoxFit.cover)
                    : Image.file(file!,
                        width: 100, height: 100, fit: BoxFit.cover),
              ),
            ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerPreviewScreen extends StatefulWidget {
  final String filePath;
  const VideoPlayerPreviewScreen({super.key, required this.filePath});

  @override
  State<VideoPlayerPreviewScreen> createState() => _VideoPlayerPreviewScreenState();
}

class _VideoPlayerPreviewScreenState extends State<VideoPlayerPreviewScreen> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.file(File(widget.filePath));
    await _controller!.initialize();
    _controller!.play();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: _initialized
            ? GestureDetector(
                onTap: () {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                  setState(() {});
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    if (!_controller!.value.isPlaying)
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: const Icon(Icons.play_arrow,
                            size: 56, color: Colors.white),
                      ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
