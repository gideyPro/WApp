import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/listing_service.dart';
import '../../widgets/common/wave_button.dart';
import '../../../../l10n/app_localizations.dart';

class EditListingScreen extends StatefulWidget {
  final Listing listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _pageController = PageController();
  late ListingFormData _formData;
  int _currentStep = 0;
  bool _isSubmitting = false;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formData = ListingFormData(
      type: widget.listing.propertyType == PropertyType.house ? 'house' : 'land',
      description: widget.listing.description ?? widget.listing.specificLocation ?? '',
      priceFixed: widget.listing.priceFixed,
      totalSquareMeters: widget.listing.totalSquareMeters,
    );
    _titleController.text = widget.listing.specificLocation ?? '';
    _priceController.text = widget.listing.priceFixed?.toString() ?? '';
    _areaController.text = widget.listing.totalSquareMeters?.toString() ?? '';
    _descriptionController.text = widget.listing.description ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateFormData(ListingFormData data) {
    setState(() => _formData = data);
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _goToStep(_currentStep + 1);
    } else {
      _submitListing();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  Future<void> _submitListing() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    
    try {
      final service = ListingService();
      final data = <String, dynamic>{
        'description': _formData.description,
        if (_formData.priceFixed != null) 'price_fixed': _formData.priceFixed.toString(),
        if (_formData.totalSquareMeters != null) 'total_square_meters': _formData.totalSquareMeters.toString(),
      };
      
      await service.updateListing(widget.listing.id, data);
      
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteListing() async {
    final l10n = AppLocalizations.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isSubmitting = true);

    try {
      final service = ListingService();
      await service.deleteListing(widget.listing.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.zinc50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.navy900 : Colors.white,
        title: Text(l10n.listingEditTitle),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: _deleteListing),
        ],
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(isDark),
                _buildStep2(isDark),
                _buildStep3(isDark),
                _buildStep4(isDark),
              ],
            ),
          ),
          _buildNavButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final l10n = AppLocalizations.of(context);
    final steps = [l10n.listingStepBasics, l10n.listingStepDetails, l10n.listingStepMedia, l10n.listingStepReview];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / 4,
              backgroundColor: AppColors.zinc200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.wave500),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) {
              final isCompleted = i < currentStep;
              final isCurrent = i == currentStep;
              return Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.wave500 : isCurrent ? AppColors.navy950 : AppColors.zinc300,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text('${i + 1}', style: TextStyle(fontSize: 12, color: isCurrent ? Colors.white : AppColors.zinc600)),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingPropertyType, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _typeTile(l10n.listingHouse, Icons.home, 'house', isDark)),
              const SizedBox(width: 12),
              Expanded(child: _typeTile(l10n.listingLand, Icons.landscape, 'land', isDark)),
            ],
          ),
          const SizedBox(height: 24),
          TextField(controller: _titleController, decoration: InputDecoration(labelText: l10n.listingTitle),
            onChanged: (v) => _updateFormData(_formData.copyWith(specificLocation: v))),
          const SizedBox(height: 16),
          TextField(controller: _priceController, decoration: InputDecoration(labelText: l10n.listingPrice, prefixText: 'ETB '),
            keyboardType: TextInputType.number,
            onChanged: (v) => _updateFormData(_formData.copyWith(priceFixed: double.tryParse(v)))),
          const SizedBox(height: 16),
          TextField(controller: _areaController, decoration: InputDecoration(labelText: l10n.listingArea, suffixText: 'sqm'),
            keyboardType: TextInputType.number,
            onChanged: (v) => _updateFormData(_formData.copyWith(totalSquareMeters: double.tryParse(v)))),
          const SizedBox(height: 16),
          TextField(controller: _descriptionController, decoration: InputDecoration(labelText: l10n.listingDescriptionLabel), maxLines: 4,
            onChanged: (v) => _updateFormData(_formData.copyWith(description: v))),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingHoldingType, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('Free Hold'), selected: _formData.holdingType == 'Free Hold', onSelected: (v) => _updateFormData(_formData.copyWith(holdingType: 'Free Hold'))),
            ChoiceChip(label: const Text('Lease Hold'), selected: _formData.holdingType == 'Lease Hold', onSelected: (v) => _updateFormData(_formData.copyWith(holdingType: 'Lease Hold'))),
          ]),
          const SizedBox(height: 24),
          Text(l10n.listingListingType, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('Sale'), selected: _formData.listingType == 'sale', onSelected: (v) => _updateFormData(_formData.copyWith(listingType: 'sale'))),
            ChoiceChip(label: const Text('Rental'), selected: _formData.listingType == 'rental', onSelected: (v) => _updateFormData(_formData.copyWith(listingType: 'rental'))),
          ]),
          const SizedBox(height: 24),
          Text(l10n.listingUseType, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('Residential'), selected: _formData.useType == 'Residential', onSelected: (v) => _updateFormData(_formData.copyWith(useType: 'Residential'))),
            ChoiceChip(label: const Text('Commercial'), selected: _formData.useType == 'Commercial', onSelected: (v) => _updateFormData(_formData.copyWith(useType: 'Commercial'))),
            ChoiceChip(label: const Text('Investment'), selected: _formData.useType == 'Investment', onSelected: (v) => _updateFormData(_formData.copyWith(useType: 'Investment'))),
          ]),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: isDark ? AppColors.navy800 : AppColors.navy50, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(Icons.photo_library, size: 48, color: AppColors.navy400),
            const SizedBox(height: 12),
            const Text('Images cannot be changed', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingReviewTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _reviewRow(l10n.listingPropertyType, _formData.type == 'house' ? l10n.listingHouse : l10n.listingLand, isDark),
          _reviewRow(l10n.listingTitle, _formData.specificLocation ?? '-', isDark),
          _reviewRow(l10n.listingPrice, _formData.priceFixed != null ? '${_formData.priceFixed} ETB' : '-', isDark),
          _reviewRow(l10n.listingArea, _formData.totalSquareMeters != null ? '${_formData.totalSquareMeters} sqm' : '-', isDark),
        ],
      ),
    );
  }

  Widget _buildNavButtons(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy900 : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) TextButton(onPressed: _prevStep, child: const Text('Back')),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(child: WaveButton(text: _currentStep == 3 ? 'Update' : 'Next', isLoading: _isSubmitting, onPressed: _isSubmitting ? null : _nextStep)),
        ],
      ),
    );
  }

  Widget _reviewRow(String title, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy900 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.navy800 : AppColors.zinc200),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: AppColors.zinc500))),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _typeTile(String label, IconData icon, String value, bool isDark) {
    final isSelected = _formData.type == value;
    return GestureDetector(
      onTap: () => _updateFormData(_formData.copyWith(type: value)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy950 : (isDark ? AppColors.navy900 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.navy950 : AppColors.zinc300, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.navy600),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.navy800)),
          ],
        ),
      ),
    );
  }
}