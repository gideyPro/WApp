import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/car_providers.dart';
import '../../widgets/listing_card.dart';
import 'car_strings.dart';

class CarListScreen extends ConsumerStatefulWidget {
  const CarListScreen({super.key});

  @override
  ConsumerState<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends ConsumerState<CarListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(carListingsProvider.notifier).loadListings();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final state = ref.read(carListingsProvider);
      if (state.hasMore && !state.isLoadingMore) {
        ref.read(carListingsProvider.notifier).loadListings(page: state.currentPage + 1);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carListingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(
        title: const Text(CarStrings.navCars),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.listings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage!, style: const TextStyle(color: AppColors.stone500)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(carListingsProvider.notifier).loadListings(),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(carListingsProvider.notifier).loadListings();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.listings.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      final listing = state.listings[index];
                      return PropertyListingCard(
                        listing: listing,
                        onTap: () => context.push('/cars/${listing.id}'),
                      );
                    },
                  ),
                ),
    );
  }
}
