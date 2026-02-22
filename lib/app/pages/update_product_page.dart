import 'dart:async';

import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/state/update_product_controller.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/app/widgets/product_form.dart';
import 'package:enterprise/app/widgets/unsaved_changes_scope.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Page for editing a product.
class UpdateProductPage extends ConsumerStatefulWidget {
  /// Creates a [UpdateProductPage].
  const UpdateProductPage({
    required this.companyId,
    required this.productId,
    required this.initialSku,
    required this.initialAffectsInventory,
    required this.revision,
    this.initialBrand,
    this.initialModel,
    this.onSuccess,
    this.showAsSheet = false,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the product.
  final String productId;

  /// Initial SKU value.
  final String initialSku;

  /// Initial brand value.
  final String? initialBrand;

  /// Initial model value.
  final String? initialModel;

  /// Initial affects inventory value.
  final bool initialAffectsInventory;

  /// Revision for optimistic concurrency.
  final int revision;

  /// Optional callback when product is updated successfully.
  final VoidCallback? onSuccess;

  /// Whether this is being shown as a sheet (true) or page (false).
  final bool showAsSheet;

  @override
  ConsumerState<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends ConsumerState<UpdateProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late bool _affectsInventory;

  /// Check if form has unsaved changes
  bool get _hasChanges {
    final currentSku = _skuController.text.trim();
    final currentBrand = _brandController.text.trim();
    final currentModel = _modelController.text.trim();
    final initialSku = widget.initialSku.trim();
    final initialBrand = widget.initialBrand?.trim() ?? '';
    final initialModel = widget.initialModel?.trim() ?? '';

    return currentSku != initialSku ||
        currentBrand != initialBrand ||
        currentModel != initialModel ||
        _affectsInventory != widget.initialAffectsInventory;
  }

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController(text: widget.initialSku);
    _brandController = TextEditingController(text: widget.initialBrand);
    _modelController = TextEditingController(text: widget.initialModel);
    _affectsInventory = widget.initialAffectsInventory;
  }

  @override
  void dispose() {
    _skuController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sku = _skuController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();

    final (success, errorMessage) = await ref
        .read(
          updateProductControllerProvider(
            widget.companyId,
            widget.productId,
          ).notifier,
        )
        .updateProduct(
          sku: sku,
          brand: brand.isEmpty ? null : brand,
          model: model.isEmpty ? null : model,
          // TODO(jonsaw): Add description and detailsData form fields.
          description: '{}',
          detailsData: '{}',
          affectsInventory: _affectsInventory,
          revision: widget.revision,
        );

    if (!mounted) return;

    talker.info(
      'UpdateProductPage: Product update '
      'for $sku '
      '${success ? 'succeeded' : 'failed: $errorMessage'}',
    );

    if (success) {
      showFToast(
        context: context,
        title: Text(context.tr.productUpdatedSuccessfully),
        duration: const Duration(seconds: 3),
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      showFToast(
        context: context,
        title: Text(context.tr.failedToUpdateProduct),
        description: errorMessage != null ? Text(errorMessage) : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(
      updateProductControllerProvider(
        widget.companyId,
        widget.productId,
      ),
    );
    final isLoading = updateState.isLoading;

    return UnsavedChangesScope(
      hasChanges: _hasChanges,
      child: FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.editProduct),
          prefixes: [
            FHeaderAction(
              icon: Icon(widget.showAsSheet ? FIcons.x : FIcons.arrowLeft),
              onPress: () async {
                final shouldPop = await UnsavedChangesScope.handleClose(
                  context,
                  hasChanges: _hasChanges,
                );
                if (shouldPop && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          left: false,
          child: SingleChildScrollView(
            child: ProductForm(
              formKey: _formKey,
              skuController: _skuController,
              brandController: _brandController,
              modelController: _modelController,
              isLoading: isLoading,
              isEditing: true,
              affectsInventory: _affectsInventory,
              onAffectsInventoryChanged: (value) {
                setState(() {
                  _affectsInventory = value;
                });
              },
              onSubmit: _handleSubmit,
              onCancel: () async {
                final shouldPop = await UnsavedChangesScope.handleClose(
                  context,
                  hasChanges: _hasChanges,
                );
                if (shouldPop && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
