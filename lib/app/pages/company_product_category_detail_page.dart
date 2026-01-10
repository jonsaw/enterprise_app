import 'dart:async';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/entities/product_category.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/pages/update_product_category_page.dart';
import 'package:enterprise/app/state/delete_product_category_controller.dart';
import 'package:enterprise/app/state/permissions.dart';
import 'package:enterprise/app/state/product_categories_controller.dart';
import 'package:enterprise/app/state/product_category_detail_controller.dart';
import 'package:enterprise/app/state/selected_id_provider.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Company Product Category Detail Page
class CompanyProductCategoryDetailPage extends ConsumerWidget {
  /// Creates a [CompanyProductCategoryDetailPage].
  const CompanyProductCategoryDetailPage({
    required this.companyId,
    required this.categoryId,
    this.onClose,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the category.
  final String categoryId;

  /// Optional callback for closing the panel (when used in split view).
  final VoidCallback? onClose;

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  void _handleEdit(
    BuildContext context,
    WidgetRef ref,
    ProductCategory category,
  ) {
    if (isMediumOrLargeScreen(context)) {
      // Show as sheet on larger screens
      unawaited(
        showFSheet<void>(
          useRootNavigator: true,
          context: context,
          side: FLayout.rtl,
          barrierDismissible: false,
          builder: (context) => UpdateProductCategoryPage(
            companyId: companyId,
            showAsSheet: true,
            categoryId: categoryId,
            initialName: category.name,
            initialDescription: category.description,
            onSuccess: () {
              ref
                ..invalidate(
                  productCategoryDetailControllerProvider(
                    companyId,
                    categoryId,
                  ),
                )
                ..invalidate(productCategoriesControllerProvider);
            },
          ),
        ),
      );
    } else {
      // Push as route on mobile screens
      unawaited(
        context
            .push(
              '/companies/$companyId/product-categories/$categoryId/edit',
            )
            .then((_) {
              // Refresh when returning from edit page
              ref
                ..invalidate(
                  productCategoryDetailControllerProvider(
                    companyId,
                    categoryId,
                  ),
                )
                ..invalidate(productCategoriesControllerProvider);
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
        style: style.call,
        animation: animation,
        title: Text(context.tr.deleteCategory),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(context.tr.deleteCategoryConfirmation),
            Text(
              context.tr.deleteCategoryWarning,
              style: TextStyle(
                color: context.theme.colors.destructiveForeground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () => Navigator.of(context, rootNavigator: true).pop(true),
            child: Text(context.tr.deleteCategory),
          ),
          FButton(
            style: FButtonStyle.outline(),
            onPress: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: Text(context.tr.cancel),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // Read the notifier (not the provider state)
      final deleteNotifier = ref.read(
        deleteProductCategoryControllerProvider(companyId, categoryId).notifier,
      );

      // Perform the deletion
      final (success, errorMessage) = await deleteNotifier.delete();

      if (success) {
        // Clear selection
        ref
                .read(
                  selectedIdProvider(SelectedIdType.productCategory).notifier,
                )
                .id =
            null;

        // Invalidate controllers to refresh (after deletion completes)
        ref
          ..invalidate(
            productCategoryDetailControllerProvider(companyId, categoryId),
          )
          ..invalidate(productCategoriesControllerProvider);

        // Show success message
        messenger.showSnackBar(
          SnackBar(
            content: Text(localizations.categoryDeletedSuccessfully),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back if not in split view
        if (shouldNavigate) {
          router.go('/companies/$companyId/product-categories');
        } else {
          onClose?.call();
        }
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              errorMessage ?? localizations.failedToDeleteCategory,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(
      productCategoryDetailControllerProvider(
        companyId,
        categoryId,
      ),
    );
    final userRoleAsync = ref.watch(
      companyPermissionsProvider(companyId),
    );

    final deleteAsync = ref.watch(
      deleteProductCategoryControllerProvider(companyId, categoryId),
    );

    // Check permissions for edit/delete buttons
    final canManage = userRoleAsync.maybeWhen(
      data: (role) => role is Owner || role is Manager,
      orElse: () => false,
    );

    // Get category for header actions
    final category = categoryAsync.maybeWhen(
      data: (cat) => cat,
      orElse: () => null,
    );

    return FScaffold(
      header: AppHeader.nested(
        title: Text(context.tr.categoryDetails),
        prefixes: [
          if (onClose != null)
            FHeaderAction.x(
              onPress: onClose,
            )
          else
            FHeaderAction.back(
              onPress: () => context.go(
                '/companies/$companyId/product-categories',
              ),
            ),
        ],
        suffixes: [
          if (canManage && category != null) ...[
            FButton.icon(
              child: const Icon(FIcons.pencil),
              onPress: () => _handleEdit(context, ref, category),
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
            categoryAsync,
            canManage,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ProductCategory?> categoryAsync,
    bool canManage,
  ) {
    return categoryAsync.when(
      data: (category) {
        if (category == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                Text(context.tr.categoryNotFound),
                FButton(
                  style: FButtonStyle.outline(),
                  onPress: () => context.go(
                    '/companies/$companyId/product-categories',
                  ),
                  child: Text(context.tr.backToCategories),
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
              // Category Information Section
              _buildCategoryInformationSection(context, category),

              // Metadata Section
              _buildMetadataSection(context, category),

              // Creator Information Section
              if (category.createdBy != null)
                _buildCreatorInformationSection(context, category),
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
            Text(context.tr.errorLoadingCategories),
            FButton(
              style: FButtonStyle.outline(),
              onPress: () {
                ref.invalidate(
                  productCategoryDetailControllerProvider(
                    companyId,
                    categoryId,
                  ),
                );
              },
              child: Text(context.tr.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInformationSection(
    BuildContext context,
    ProductCategory category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.categoryInformation,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.categoryName),
              details: Text(category.name),
            ),
            if (category.description != null)
              FTile(
                title: Text(context.tr.categoryDescription),
                details: Text(category.description!),
              ),
            FTile(
              title: Text(context.tr.categoryId),
              details: Text(
                category.id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            if (category.revision != null)
              FTile(
                title: Text(context.tr.revision),
                details: Text(category.revision.toString()),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, ProductCategory category) {
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
              details: Text(_formatDateTime(category.createdAt)),
            ),
            FTile(
              title: Text(context.tr.updatedAt),
              details: Text(_formatDateTime(category.updatedAt)),
            ),
            if (category.readAt != null)
              FTile(
                title: Text(context.tr.readAt),
                details: Text(_formatDateTime(category.readAt)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreatorInformationSection(
    BuildContext context,
    ProductCategory category,
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
              details: Text(category.createdBy?.name ?? '-'),
            ),
            FTile(
              title: Text(context.tr.email),
              details: Text(category.createdBy?.email ?? '-'),
            ),
            if (category.updatedBy != null) ...[
              FTile(
                title: Text(context.tr.updatedBy),
                details: Text(category.updatedBy?.name ?? '-'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
