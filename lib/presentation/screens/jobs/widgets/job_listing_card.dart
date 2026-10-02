import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/listing.dart';

class JobListingCard extends StatelessWidget {
  final Listing job;
  const JobListingCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(job.description?.split('\n').first ?? 'Job'),
        subtitle: Text(job.address?.woreda ?? job.address?.region ?? ''),
        onTap: () => context.push('/jobs/${job.id}'),
      ),
    );
  }
}
