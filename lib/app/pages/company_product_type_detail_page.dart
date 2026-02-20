import 'dart:async';
import 'dart:convert';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/entities/product_type.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/pages/update_product_type_page.dart';
import 'package:enterprise/app/state/delete_product_type_controller.dart';
import 'package:enterprise/app/state/permissions.dart';
import 'package:enterprise/app/state/product_type_detail_controller.dart';
import 'package:enterprise/app/state/product_types_controller.dart';
import 'package:enterprise/app/state/selected_id_provider.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Company Product Type Detail Page
class CompanyProductTypeDetailPage extends ConsumerStatefulWidget {
  /// Creates a [CompanyProductTypeDetailPage].
  const CompanyProductTypeDetailPage({
    required this.companyId,
    required this.typeId,
    this.onClose,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the type.
  final String typeId;

  /// Optional callback for closing the panel (when used in split view).
  final VoidCallback? onClose;

  @override
  ConsumerState<CompanyProductTypeDetailPage> createState() =>
      _CompanyProductTypeDetailPageState();
}

class _CompanyProductTypeDetailPageState
    extends ConsumerState<CompanyProductTypeDetailPage> {
  bool _isDetailsUiExpanded = true;

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  String _formatJson(String? jsonString) {
    if (jsonString == null) return '-';
    try {
      final dynamic jsonObject = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } on Exception {
      return jsonString; // Return as-is if formatting fails
    }
  }

  void _handleEdit(
    BuildContext context,
    WidgetRef ref,
    ProductType type,
  ) {
    if (isMediumOrLargeScreen(context)) {
      // Show as sheet on larger screens
      unawaited(
        showFSheet<void>(
          useRootNavigator: true,
          context: context,
          side: FLayout.rtl,
          barrierDismissible: false,
          builder: (context) => UpdateProductTypePage(
            companyId: widget.companyId,
            showAsSheet: true,
            typeId: widget.typeId,
            initialName: type.name,
            initialDescription: type.description,
            initialDetailsUi: type.detailsUi ?? '{}',
            revision: type.revision ?? 0,
            onSuccess: () {
              ref
                ..invalidate(
                  productTypeDetailControllerProvider(
                    widget.companyId,
                    widget.typeId,
                  ),
                )
                ..invalidate(productTypesControllerProvider);
            },
          ),
        ),
      );
    } else {
      // Push as route on mobile screens
      unawaited(
        context
            .push(
              '/companies/${widget.companyId}/product-types/${widget.typeId}/edit',
            )
            .then((_) {
              // Refresh when returning from edit page
              ref
                ..invalidate(
                  productTypeDetailControllerProvider(
                    widget.companyId,
                    widget.typeId,
                  ),
                )
                ..invalidate(productTypesControllerProvider);
            }),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final shouldNavigate = widget.onClose == null;

    // Extract translations before async gap
    final successMessage = context.tr.typeDeletedSuccessfully;
    final failureMessage = context.tr.failedToDeleteType;

    final confirmed = await showFDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context, style, animation) => FDialog(
        style: style.call,
        animation: animation,
        title: Text(context.tr.deleteType),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(context.tr.deleteTypeConfirmation),
            Text(
              context.tr.deleteTypeWarning,
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
            child: Text(context.tr.delete),
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
        deleteProductTypeControllerProvider(
          widget.companyId,
          widget.typeId,
        ).notifier,
      );

      // Perform the deletion
      final (success, errorMessage) = await deleteNotifier.delete();

      if (success) {
        // Clear selection
        ref
                .read(
                  selectedIdProvider(SelectedIdType.productType).notifier,
                )
                .id =
            null;

        // Navigate back if not in split view
        if (shouldNavigate) {
          router.go('/companies/${widget.companyId}/product-types');
        } else {
          widget.onClose?.call();
        }

        // Invalidate controllers to refresh (after navigation/close)
        ref
          ..invalidate(
            productTypeDetailControllerProvider(
              widget.companyId,
              widget.typeId,
            ),
          )
          ..invalidate(productTypesControllerProvider);

        // Show success message after navigation (on the parent scaffold)
        // Use addPostFrameCallback to ensure navigation completes first
        WidgetsBinding.instance.addPostFrameCallback((_) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(successMessage),
              duration: const Duration(seconds: 3),
            ),
          );
        });
      } else {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                errorMessage ?? failureMessage,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeAsync = ref.watch(
      productTypeDetailControllerProvider(
        widget.companyId,
        widget.typeId,
      ),
    );
    final userRoleAsync = ref.watch(
      companyPermissionsProvider(widget.companyId),
    );

    final deleteAsync = ref.watch(
      deleteProductTypeControllerProvider(widget.companyId, widget.typeId),
    );

    // Check permissions for edit/delete buttons
    final canManage = userRoleAsync.maybeWhen(
      data: (role) => role is Owner || role is Manager,
      orElse: () => false,
    );

    // Get type for header actions
    final type = typeAsync.maybeWhen(
      data: (t) => t,
      orElse: () => null,
    );

    return FScaffold(
      header: AppHeader.nested(
        title: Text(context.tr.productTypeDetails),
        prefixes: [
          if (widget.onClose != null)
            FHeaderAction.x(
              onPress: widget.onClose,
            )
          else
            FHeaderAction.back(
              onPress: () => context.go(
                '/companies/${widget.companyId}/product-types',
              ),
            ),
        ],
        suffixes: [
          if (canManage && type != null) ...[
            FButton.icon(
              child: const Icon(FIcons.pencil),
              onPress: () => _handleEdit(context, ref, type),
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
            typeAsync,
            canManage,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ProductType?> typeAsync,
    bool canManage,
  ) {
    return typeAsync.when(
      data: (type) {
        if (type == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                const Icon(
                  Icons.type_specimen_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                Text(context.tr.typeNotFound),
                FButton(
                  style: FButtonStyle.outline(),
                  onPress: () => context.go(
                    '/companies/${widget.companyId}/product-types',
                  ),
                  child: Text(context.tr.backToTypes),
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
              // Type Information Section
              _buildTypeInformationSection(context, type),

              // Details UI Section
              _buildDetailsUiSection(context, type),

              // Metadata Section
              _buildMetadataSection(context, type),

              // Creator Information Section
              if (type.createdBy != null)
                _buildCreatorInformationSection(context, type),
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
            Text(context.tr.errorLoadingTypes),
            FButton(
              style: FButtonStyle.outline(),
              onPress: () {
                ref.invalidate(
                  productTypeDetailControllerProvider(
                    widget.companyId,
                    widget.typeId,
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

  Widget _buildTypeInformationSection(
    BuildContext context,
    ProductType type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.tr.typeInformation,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        FTileGroup(
          children: [
            FTile(
              title: Text(context.tr.typeName),
              details: Text(type.name),
            ),
            if (type.description != null)
              FTile(
                title: Text(context.tr.typeDescription),
                details: Text(type.description!),
              ),
            FTile(
              title: Text(context.tr.typeId),
              details: Text(
                type.id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            if (type.revision != null)
              FTile(
                title: Text(context.tr.revision),
                details: Text(type.revision.toString()),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsUiSection(BuildContext context, ProductType type) {
    final theme = context.theme;
    final formattedJson = _formatJson(type.detailsUi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDetailsUiExpanded = !_isDetailsUiExpanded;
            });
          },
          child: Row(
            children: [
              Text(
                context.tr.detailsUiSchema,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _isDetailsUiExpanded ? Icons.expand_less : Icons.expand_more,
                size: 24,
              ),
            ],
          ),
        ),
        if (_isDetailsUiExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colors.muted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colors.border,
              ),
            ),
            child: SelectableText(
              formattedJson,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, ProductType type) {
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
              details: Text(_formatDateTime(type.createdAt)),
            ),
            FTile(
              title: Text(context.tr.updatedAt),
              details: Text(_formatDateTime(type.updatedAt)),
            ),
            if (type.readAt != null)
              FTile(
                title: Text(context.tr.readAt),
                details: Text(_formatDateTime(type.readAt)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreatorInformationSection(
    BuildContext context,
    ProductType type,
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
              details: Text(type.createdBy?.name ?? '-'),
            ),
            FTile(
              title: Text(context.tr.email),
              details: Text(type.createdBy?.email ?? '-'),
            ),
            if (type.updatedBy != null) ...[
              FTile(
                title: Text(context.tr.updatedBy),
                details: Text(type.updatedBy?.name ?? '-'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
