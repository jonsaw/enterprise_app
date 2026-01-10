import 'dart:async';

import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/state/create_product_category_controller.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/app/widgets/product_category_form.dart';
import 'package:enterprise/app/widgets/unsaved_changes_scope.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Page for creating a new product category.
class CreateProductCategoryPage extends ConsumerStatefulWidget {
  /// Creates a [CreateProductCategoryPage].
  const CreateProductCategoryPage({
    required this.companyId,
    this.onSuccess,
    this.showAsSheet = false,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// Optional callback when category is created successfully.
  final VoidCallback? onSuccess;

  /// Whether this is being shown as a sheet (true) or page (false).
  final bool showAsSheet;

  @override
  ConsumerState<CreateProductCategoryPage> createState() =>
      _CreateProductCategoryPageState();
}

class _CreateProductCategoryPageState
    extends ConsumerState<CreateProductCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// Check if form has unsaved changes
  bool get _hasChanges {
    final currentName = _nameController.text.trim();
    final currentDescription = _descriptionController.text.trim();

    return currentName.isNotEmpty || currentDescription.isNotEmpty;
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

    final input = CreateProductCategoryInput(
      name: name,
      description: description.isEmpty ? null : description,
    );

    final (success, errorMessage) = await ref
        .read(
          createProductCategoryControllerProvider(widget.companyId).notifier,
        )
        .createCategory(input);

    if (!mounted) return;

    talker.info(
      'CreateProductCategoryPage: Category creation '
      'for ${input.name} '
      '${success ? 'succeeded' : 'failed: $errorMessage'}',
    );

    if (success) {
      // Show success toast
      showFToast(
        context: context,
        title: Text(context.tr.categoryCreatedSuccessfully),
        duration: const Duration(seconds: 3),
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      // Show error toast
      showFToast(
        context: context,
        title: Text(context.tr.failedToCreateCategory),
        description: errorMessage != null ? Text(errorMessage) : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(
      createProductCategoryControllerProvider(widget.companyId),
    );
    final isLoading = createState.isLoading;

    return UnsavedChangesScope(
      hasChanges: _hasChanges,
      child: FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.createCategory),
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
              isEditing: false,
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
