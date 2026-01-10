import 'dart:async';

import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/state/update_product_category_controller.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/app/widgets/product_category_form.dart';
import 'package:enterprise/app/widgets/unsaved_changes_scope.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Page for editing a product category.
class UpdateProductCategoryPage extends ConsumerStatefulWidget {
  /// Creates a [UpdateProductCategoryPage].
  const UpdateProductCategoryPage({
    required this.companyId,
    required this.categoryId,
    required this.initialName,
    this.initialDescription,
    this.onSuccess,
    this.showAsSheet = false,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the category.
  final String categoryId;

  /// Initial name value.
  final String initialName;

  /// Initial description value.
  final String? initialDescription;

  /// Optional callback when category is updated successfully.
  final VoidCallback? onSuccess;

  /// Whether this is being shown as a sheet (true) or page (false).
  final bool showAsSheet;

  @override
  ConsumerState<UpdateProductCategoryPage> createState() =>
      _UpdateProductCategoryPageState();
}

class _UpdateProductCategoryPageState
    extends ConsumerState<UpdateProductCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  /// Check if form has unsaved changes
  bool get _hasChanges {
    final currentName = _nameController.text.trim();
    final currentDescription = _descriptionController.text.trim();
    final initialName = widget.initialName.trim();
    final initialDescription = widget.initialDescription?.trim() ?? '';

    return currentName != initialName ||
        currentDescription != initialDescription;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    final input = UpdateProductCategoryInput(
      name: name,
      description: description.isEmpty ? null : description,
    );

    final (success, errorMessage) = await ref
        .read(
          updateProductCategoryControllerProvider(
            widget.companyId,
            widget.categoryId,
          ).notifier,
        )
        .updateCategory(input);

    if (!mounted) return;

    talker.info(
      'UpdateProductCategoryPage: Category update '
      'for ${input.name} '
      '${success ? 'succeeded' : 'failed: $errorMessage'}',
    );

    if (success) {
      // Show success toast
      showFToast(
        context: context,
        title: Text(context.tr.categoryUpdatedSuccessfully),
        duration: const Duration(seconds: 3),
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      // Show error toast
      showFToast(
        context: context,
        title: Text(context.tr.failedToUpdateCategory),
        description: errorMessage != null ? Text(errorMessage) : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(
      updateProductCategoryControllerProvider(
        widget.companyId,
        widget.categoryId,
      ),
    );
    final isLoading = updateState.isLoading;

    return UnsavedChangesScope(
      hasChanges: _hasChanges,
      child: FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.editCategory),
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
            child: ProductCategoryForm(
              formKey: _formKey,
              nameController: _nameController,
              descriptionController: _descriptionController,
              isLoading: isLoading,
              isEditing: true,
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
