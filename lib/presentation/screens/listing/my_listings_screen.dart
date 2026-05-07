import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/services/listing_service.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/listing_card.dart';
import '../listing/listing_detail_screen.dart';
import '../listing/create_listing_screen.dart';
import '../../../../l10n/app_localizations.dart';

/// My Listings Screen - Shows user's own listings
class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Listing> _myListings = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadMyListings();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMyListings(page: _currentPage + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMyListings({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final service = ListingService();
    final response = await service.getMyListings(page: page);

    if (mounted) {
      setState(() {
        if (response.success) {
          _myListings = page == 1
              ? response.listings
              : [..._myListings, ...response.listings];
          _currentPage = response.currentPage ?? page;
          _totalPages = response.totalPages ?? 1;
          _hasMore = _currentPage < _totalPages;
        } else {
          _errorMessage = response.message;
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profileMyListings),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateListingScreen()),
              );
              if (result == true && mounted) {
                _loadMyListings();
              }
            },
            tooltip: AppLocalizations.of(context).listingsCreate,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _myListings.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => const PropertyListingCard(isLoading: true),
      );
    }

    if (_errorMessage != null && _myListings.isEmpty) {
      return WaveMessageScreen.error(
        title: 'Error Loading Listings',
        subtitle: _errorMessage!,
        onRetry: () => _loadMyListings(),
      );
    }

    if (_myListings.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return WaveEmptyState(
        icon: Icons.home_outlined,
        title: l10n.listingsNoResults,
        subtitle: l10n.myListingsEmptySubtitle,
        actionLabel: l10n.listingsCreate,
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateListingScreen()),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadMyListings(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _myListings.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _myListings.length) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PropertyListingCard(isLoading: true),
            );
          }

          final listing = _myListings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PropertyListingCard(
              listing: listing,
              isFavorite: false,
              isTogglingFavorite: false,
              onFavorite: () {},
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(listingId: listing.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
