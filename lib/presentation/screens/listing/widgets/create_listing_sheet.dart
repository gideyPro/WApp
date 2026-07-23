import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

Future<bool?> showCreateListingSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final completer = Completer<bool?>();
  showModalBottomSheet(
    context: context,
    backgroundColor: context.sheetBg,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.home_work_outlined, color: context.theme.textSecondary),
            title: Text(l10n.listingSummaryProperty, style: TextStyle(color: context.theme.textPrimary)),
            onTap: () async {
              Navigator.pop(ctx);
              completer.complete(await context.push<bool>('/listings/create'));
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_car_outlined, color: context.theme.textSecondary),
            title: Text(l10n.listingCar, style: TextStyle(color: context.theme.textPrimary)),
            onTap: () async {
              Navigator.pop(ctx);
              completer.complete(await context.push<bool>('/cars/create'));
            },
          ),
        ],
      ),
    ),
  );
  return completer.future;
}
