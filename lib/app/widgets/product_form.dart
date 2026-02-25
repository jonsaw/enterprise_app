import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Form widget for creating or editing a product.
class ProductForm extends StatelessWidget {
  /// Creates a [ProductForm].
  const ProductForm({
    required this.formKey,
    required this.skuController,
    required this.brandController,
    required this.modelController,
    required this.isLoading,
    required this.isEditing,
    required this.onSubmit,
    required this.onCancel,
    required this.affectsInventory,
    required this.onAffectsInventoryChanged,
    super.key,
  });

  /// The form key for validation.
  final GlobalKey<FormState> formKey;

  /// Controller for the SKU field.
  final TextEditingController skuController;

  /// Controller for the brand field.
  final TextEditingController brandController;

  /// Controller for the model field.
  final TextEditingController modelController;

  /// Whether the form is in a loading state.
  final bool isLoading;

  /// Whether the form is in editing mode.
  final bool isEditing;

  /// Callback when the form is submitted.
  final Future<void> Function() onSubmit;

  /// Callback when the form is cancelled.
  final Future<void> Function() onCancel;

  /// Whether the product affects inventory.
  final bool affectsInventory;

  /// Callback when affects inventory changes.
  final ValueChanged<bool> onAffectsInventoryChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          // SKU field
          FTextFormField(
            control: .managed(controller: skuController),
            label: Text(context.tr.productSku),
            hint: context.tr.enterProductSku,
            enabled: !isLoading,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return context.tr.skuRequired;
              }
              return null;
            },
          ),

          // Brand field
          FTextFormField(
            control: .managed(controller: brandController),
            label: Text(context.tr.productBrand),
            hint: context.tr.enterProductBrand,
            enabled: !isLoading,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          // Model field
          FTextFormField(
            control: .managed(controller: modelController),
            label: Text(context.tr.productModel),
            hint: context.tr.enterProductModel,
            enabled: !isLoading,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          // Affects Inventory toggle
          FSwitch(
            label: Text(context.tr.affectsInventory),
            value: affectsInventory,
            onChange: isLoading ? null : onAffectsInventoryChanged,
          ),

          const SizedBox(height: 8),

          // Submit and cancel buttons - responsive layout
          Builder(
            builder: (context) {
              final isLargeScreen = isMediumOrLargeScreen(context);

              if (isLargeScreen) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    FButton(
                      variant: .outline,
                      onPress: isLoading ? null : onCancel,
                      child: Text(context.tr.cancel),
                    ),
                    FButton(
                      onPress: isLoading ? null : onSubmit,
                      child: Text(
                        isEditing ? context.tr.update : context.tr.create,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    FButton(
                      onPress: isLoading ? null : onSubmit,
                      child: Text(
                        isEditing ? context.tr.update : context.tr.create,
                      ),
                    ),
                    FButton(
                      variant: .outline,
                      onPress: isLoading ? null : onCancel,
                      child: Text(context.tr.cancel),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
