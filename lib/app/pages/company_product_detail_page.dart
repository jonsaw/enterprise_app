import 'dart:async';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/entities/product.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/pages/update_product_page.dart';
import 'package:enterprise/app/state/delete_product_controller.dart';
import 'package:enterprise/app/state/permissions.dart';
import 'package:enterprise/app/state/product_detail_controller.dart';
import 'package:enterprise/app/state/products_controller.dart';
import 'package:enterprise/app/state/selected_id_provider.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Company Product Detail Page
class CompanyProductDetailPage extends ConsumerWidget {
  /// Creates a [CompanyProductDetailPage].
  const CompanyProductDetailPage({
    required this.companyId,
    required this.productId,
    this.onClose,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the product.
  final String productId;

  /// Optional callback for closing the panel (when used in split view).
  final VoidCallback? onClose;

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  void _handleEdit(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    if (isMediumOrLargeScreen(context)) {
      unawaited(
        showFSheet<void>(
          useRootNavigator: true,
          context: context,
          side: FLayout.rtl,
          barrierDismissible: false,
          builder: (context) => UpdateProductPage(
            companyId: companyId,
            productId: productId,
            showAsSheet: true,
            initialSku: product.sku,
            initialBrand: product.brand,
            initialModel: product.model,
            initialAffectsInventory: product.affectsInventory,
            revision: product.revision,
            onSuccess: () {
              ref
                ..invalidate(
                  productDetailControllerProvider(companyId, productId),
                )
                ..invalidate(productsControllerProvider);
            },
          ),
        ),
      );
    } else {
      unawaited(
        context
            .push(
              '/companies/$companyId/products/$productId/edit',
            )
            .then((_) {
              ref
                ..invalidate(
                  productDetailControllerProvider(companyId, productId),
                )
                ..invalidate(productsControllerProvider);
            }),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final localizations = context.tr;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final shouldNavigate = onClose == null;

    final confirmed = await showFDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context, style, animation) => FDialog(
        style: style,
        animation: animation,
        title: Text(context.tr.deleteProduct),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(context.tr.deleteProductConfirmation),
            Text(
              context.tr.deleteProductWarning,
              style: TextStyle(
                color: context.theme.colors.destructiveForeground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          FButton(
            variant: .destructive,
            onPress: () => Navigator.of(context, rootNavigator: true).pop(true),
            child: Text(context.tr.deleteProduct),
          ),
          FButton(
            variant: .outline,
            onPress: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: Text(context.tr.cancel),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final deleteNotifier = ref.read(
        deleteProductControllerProvider(companyId, productId).notifier,
      );

      final (success, errorMessage) = await deleteNotifier.delete();

      if (success) {
        ref
                .read(
                  selectedIdProvider(SelectedIdType.product).notifier,
                )
                .id =
            null;

        ref
          ..invalidate(
            productDetailControllerProvider(companyId, productId),
          )
          ..invalidate(productsControllerProvider);

        messenger.showSnackBar(
          SnackBar(
            content: Text(localizations.productDeletedSuccessfully),
            duration: const Duration(seconds: 3),
          ),
        );

        if (shouldNavigate) {
          router.go('/companies/$companyId/products');
        } else {
          onClose?.call();
        }
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              errorMessage ?? localizations.failedToDeleteProduct,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(
      productDetailControllerProvider(companyId, productId),
    );
    final userRoleAsync = ref.watch(
      companyPermissionsProvider(companyId),
    );

    final deleteAsync = ref.watch(
      deleteProductControllerProvider(companyId, productId),
    );

    final canManage = userRoleAsync.maybeWhen(
      data: (role) => role is Owner || role is Manager,
      orElse: () => false,
    );

    final product = productAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    return FScaffold(
      header: AppHeader.nested(
        title: Text(context.tr.productDetails),
        prefixes: [
          if (onClose != null)
            FHeaderAction.x(
              onPress: onClose,
            )
          else
            FHeaderAction.back(
              onPress: () => context.go(
                '/companies/$companyId/products',
              ),
            ),
        ],
        suffixes: [
          if (canManage && product != null) ...[
            FButton.icon(
              child: const Icon(FIcons.pencil),
              onPress: () => _handleEdit(context, ref, product),
            ),
            FButton.icon(
              onPress: deleteAsync.isLoading
                  ? null
                  : () => _showDeleteConfirmation(context, ref),
              child: const Icon(FIcons.trash2),
            ),
          ],
        ],
      ),
      child: SafeArea(
        top: false,
        left: false,
        child: Builder(
          builder: (context) => _buildContent(
            context,
            ref,
            productAsync,
            canManage,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Product?> productAsync,
    bool canManage,
  ) {
    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                Icon(
                  FIcons.package2,
                  size: 64,
                  color: context.theme.colors.mutedForeground,
                ),
                Text(context.tr.productNotFound),
                FButton(
                  variant: .outline,
                  onPress: () => context.go(
                    '/companies/$companyId/products',
                  ),
                  child: Text(context.tr.backToProducts),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              _buildProductInformationSection(context, product),
              _buildMetadataSection(context, product),
              if (product.createdBy != null)
                _buildCreatorInformationSection(context, product),
            ],
          ),
        );
      },
      loading: () => const Center(child: FCircularProgress()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Text(context.tr.errorLoadingProducts),
            FButton(
              variant: .outline,
              onPress: () {
                ref.invalidate(
                  productDetailControllerProvider(companyId, productId),
                );
              },
              child: Text(context.tr.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInformationSection(
    BuildContext context,
    Product product,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.productInformation,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.productSku),
              details: Text(product.sku),
            ),
            if (product.brand != null)
              FTile(
                title: Text(context.tr.productBrand),
                details: Text(product.brand!),
              ),
            if (product.model != null)
              FTile(
                title: Text(context.tr.productModel),
                details: Text(product.model!),
              ),
            FTile(
              title: Text(context.tr.affectsInventory),
              details: Text(
                product.affectsInventory ? context.tr.yes : context.tr.no,
              ),
            ),
            FTile(
              title: Text(context.tr.productId),
              details: Text(
                product.id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            FTile(
              title: Text(context.tr.revision),
              details: Text(product.revision.toString()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.metadata,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.createdAt),
              details: Text(_formatDateTime(product.createdAt)),
            ),
            FTile(
              title: Text(context.tr.updatedAt),
              details: Text(_formatDateTime(product.updatedAt)),
            ),
            if (product.readAt != null)
              FTile(
                title: Text(context.tr.readAt),
                details: Text(_formatDateTime(product.readAt)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreatorInformationSection(
    BuildContext context,
    Product product,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.creatorInformation,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.createdBy),
              details: Text(product.createdBy?.name ?? '-'),
            ),
            FTile(
              title: Text(context.tr.email),
              details: Text(product.createdBy?.email ?? '-'),
            ),
            if (product.updatedBy != null) ...[
              FTile(
                title: Text(context.tr.updatedBy),
                details: Text(product.updatedBy?.name ?? '-'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
