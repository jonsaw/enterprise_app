import 'dart:async';

import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/state/update_product_type_controller.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/app/widgets/product_type_form.dart';
import 'package:enterprise/app/widgets/unsaved_changes_scope.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Page for editing a product type.
class UpdateProductTypePage extends ConsumerStatefulWidget {
  /// Creates a [UpdateProductTypePage].
  const UpdateProductTypePage({
    required this.companyId,
    required this.typeId,
    required this.initialName,
    required this.initialDetailsUi,
    required this.revision,
    this.initialDescription,
    this.onSuccess,
    this.showAsSheet = false,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the type.
  final String typeId;

  /// Initial name value.
  final String initialName;

  /// Initial description value.
  final String? initialDescription;

  /// Initial details UI value.
  final String initialDetailsUi;

  /// The current revision number for optimistic concurrency.
  final int revision;

  /// Optional callback when type is updated successfully.
  final VoidCallback? onSuccess;

  /// Whether this is being shown as a sheet (true) or page (false).
  final bool showAsSheet;

  @override
  ConsumerState<UpdateProductTypePage> createState() =>
      _UpdateProductTypePageState();
}

class _UpdateProductTypePageState extends ConsumerState<UpdateProductTypePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _detailsUiController;

  /// Check if form has unsaved changes
  bool get _hasChanges {
    final currentName = _nameController.text.trim();
    final currentDescription = _descriptionController.text.trim();
    final currentDetailsUi = _detailsUiController.text.trim();
    final initialName = widget.initialName.trim();
    final initialDescription = widget.initialDescription?.trim() ?? '';
    final initialDetailsUi = widget.initialDetailsUi.trim();

    return currentName != initialName ||
        currentDescription != initialDescription ||
        currentDetailsUi != initialDetailsUi;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _detailsUiController = TextEditingController(
      text: widget.initialDetailsUi,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _detailsUiController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final detailsUi = _detailsUiController.text.trim();

    final input = UpdateProductTypeInput(
      name: name,
      description: description.isEmpty ? null : description,
      detailsUi: detailsUi,
      revision: widget.revision,
    );

    final (success, errorMessage) = await ref
        .read(
          updateProductTypeControllerProvider(
            widget.companyId,
            widget.typeId,
          ).notifier,
        )
        .updateType(input);

    if (!mounted) return;

    talker.info(
      'UpdateProductTypePage: Type update '
      'for ${input.name} '
      '${success ? 'succeeded' : 'failed: $errorMessage'}',
    );

    if (success) {
      // Show success toast
      showFToast(
        context: context,
        title: Text(context.tr.typeUpdatedSuccessfully),
        duration: const Duration(seconds: 3),
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      // Show error toast
      showFToast(
        context: context,
        title: Text(context.tr.failedToUpdateType),
        description: errorMessage != null ? Text(errorMessage) : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(
      updateProductTypeControllerProvider(
        widget.companyId,
        widget.typeId,
      ),
    );
    final isLoading = updateState.isLoading;

    return UnsavedChangesScope(
      hasChanges: _hasChanges,
      child: FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.editType),
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
            child: ProductTypeForm(
              formKey: _formKey,
              nameController: _nameController,
              descriptionController: _descriptionController,
              detailsUiController: _detailsUiController,
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
