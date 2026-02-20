import 'dart:convert';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Form widget for creating or editing a product type.
class ProductTypeForm extends StatelessWidget {
  /// Creates a [ProductTypeForm].
  const ProductTypeForm({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.detailsUiController,
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

  /// Controller for the details UI JSON field.
  final TextEditingController detailsUiController;

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
            label: Text(context.tr.typeName),
            hint: context.tr.enterTypeName,
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
            label: Text(context.tr.typeDescription),
            hint: context.tr.enterTypeDescription,
            enabled: !isLoading,
            maxLines: 3,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          // Details UI JSON field
          FTextFormField(
            control: .managed(controller: detailsUiController),
            label: Text(context.tr.detailsUiSchemaJson),
            hint: context.tr.enterDetailsUiSchema,
            enabled: !isLoading,
            maxLines: 10,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return context.tr.detailsUiSchemaRequired;
              }

              // Validate JSON format and structure
              try {
                final json = jsonDecode(trimmed);

                if (json is! Map<String, dynamic>) {
                  return context.tr.jsonMustBeObject;
                }
                if (!json.containsKey('runtimeType')) {
                  return context.tr.jsonMustContainRuntimeType;
                }
              } on FormatException catch (e) {
                return '${context.tr.invalidJson}: ${e.message}';
              }

              return null;
            },
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
