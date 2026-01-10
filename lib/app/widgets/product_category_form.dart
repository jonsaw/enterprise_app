import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Form widget for creating or editing a product category.
class ProductCategoryForm extends StatelessWidget {
  /// Creates a [ProductCategoryForm].
  const ProductCategoryForm({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.isLoading,
    required this.isEditing,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  /// The form key for validation.
  final GlobalKey<FormState> formKey;

  /// Controller for the name field.
  final TextEditingController nameController;

  /// Controller for the description field.
  final TextEditingController descriptionController;

  /// Whether the form is in a loading state.
  final bool isLoading;

  /// Whether the form is in editing mode.
  final bool isEditing;

  /// Callback when the form is submitted.
  final VoidCallback onSubmit;

  /// Callback when the form is cancelled.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          // Name field
          FTextFormField(
            control: .managed(controller: nameController),
            label: Text(context.tr.categoryName),
            hint: context.tr.enterCategoryName,
            enabled: !isLoading,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return context.tr.nameRequired;
              }
              if (trimmed.length < 2) {
                return context.tr.nameTooShort;
              }
              return null;
            },
          ),

          // Description field
          FTextFormField(
            control: .managed(controller: descriptionController),
            label: Text(context.tr.categoryDescription),
            hint: context.tr.enterCategoryDescription,
            enabled: !isLoading,
            maxLines: 3,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          const SizedBox(height: 8),

          // Submit and cancel buttons - responsive layout
          Builder(
            builder: (context) {
              final isLargeScreen = isMediumOrLargeScreen(context);

              if (isLargeScreen) {
                // Tablet/Desktop: [Cancel] [Submit] aligned right
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    FButton(
                      style: FButtonStyle.outline(),
                      onPress: isLoading ? null : onCancel,
                      child: Text(context.tr.cancel),
                    ),
                    FButton(
                      style: FButtonStyle.primary(),
                      onPress: isLoading ? null : onSubmit,
                      child: Text(
                        isEditing ? context.tr.update : context.tr.create,
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile: Full-width buttons stacked
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    FButton(
                      style: FButtonStyle.primary(),
                      onPress: isLoading ? null : onSubmit,
                      child: Text(
                        isEditing ? context.tr.update : context.tr.create,
                      ),
                    ),
                    FButton(
                      style: FButtonStyle.outline(),
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
