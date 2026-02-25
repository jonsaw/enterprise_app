import 'dart:async';

import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/state/create_product_controller.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/app/widgets/product_form.dart';
import 'package:enterprise/app/widgets/unsaved_changes_scope.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Page for creating a new product.
class CreateProductPage extends ConsumerStatefulWidget {
  /// Creates a [CreateProductPage].
  const CreateProductPage({
    required this.companyId,
    this.onSuccess,
    this.showAsSheet = false,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// Optional callback when product is created successfully.
  final VoidCallback? onSuccess;

  /// Whether this is being shown as a sheet (true) or page (false).
  final bool showAsSheet;

  @override
  ConsumerState<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends ConsumerState<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  bool _affectsInventory = false;

  bool get _hasChanges {
    final currentSku = _skuController.text.trim();
    final currentBrand = _brandController.text.trim();
    final currentModel = _modelController.text.trim();

    return currentSku.isNotEmpty ||
        currentBrand.isNotEmpty ||
        currentModel.isNotEmpty ||
        _affectsInventory;
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
          createProductControllerProvider(widget.companyId).notifier,
        )
        .createProduct(
          sku: sku,
          brand: brand.isEmpty ? null : brand,
          model: model.isEmpty ? null : model,
          // TODO(jonsaw): Add description and detailsData form fields.
          description: '{}',
          detailsData: '{}',
          affectsInventory: _affectsInventory,
        );

    if (!mounted) return;

    talker.info(
      'CreateProductPage: Product creation '
      'for $sku '
      '${success ? 'succeeded' : 'failed: $errorMessage'}',
    );

    if (success) {
      showFToast(
        context: context,
        title: Text(context.tr.productCreatedSuccessfully),
        duration: const Duration(seconds: 3),
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      showFToast(
        context: context,
        title: Text(context.tr.failedToCreateProduct),
        description: errorMessage != null ? Text(errorMessage) : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(
      createProductControllerProvider(widget.companyId),
    );
    final isLoading = createState.isLoading;

    return UnsavedChangesScope(
      hasChanges: _hasChanges,
      child: FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.createProduct),
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
              isEditing: false,
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
