import 'dart:async';

import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/state/create_product_type_controller.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/app/widgets/product_type_form.dart';
import 'package:enterprise/app/widgets/unsaved_changes_scope.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Page for creating a new product type.
class CreateProductTypePage extends ConsumerStatefulWidget {
  /// Creates a [CreateProductTypePage].
  const CreateProductTypePage({
    required this.companyId,
    this.onSuccess,
    this.showAsSheet = false,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// Optional callback when type is created successfully.
  final VoidCallback? onSuccess;

  /// Whether this is being shown as a sheet (true) or page (false).
  final bool showAsSheet;

  @override
  ConsumerState<CreateProductTypePage> createState() =>
      _CreateProductTypePageState();
}

class _CreateProductTypePageState extends ConsumerState<CreateProductTypePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _detailsUiController = TextEditingController(
    text: '{"runtimeType": "column", "children": []}',
  );

  /// Check if form has unsaved changes
  bool get _hasChanges {
    final currentName = _nameController.text.trim();
    final currentDescription = _descriptionController.text.trim();
    final currentDetailsUi = _detailsUiController.text.trim();
    const defaultDetailsUi = '{"runtimeType": "column", "children": []}';

    return currentName.isNotEmpty ||
        currentDescription.isNotEmpty ||
        currentDetailsUi != defaultDetailsUi;
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

    final input = CreateProductTypeInput(
      name: name,
      description: description.isEmpty ? null : description,
      detailsUi: detailsUi,
    );

    final (success, errorMessage) = await ref
        .read(
          createProductTypeControllerProvider(widget.companyId).notifier,
        )
        .createType(input);

    if (!mounted) return;

    talker.info(
      'CreateProductTypePage: Type creation '
      'for ${input.name} '
      '${success ? 'succeeded' : 'failed: $errorMessage'}',
    );

    if (success) {
      // Pop first
      Navigator.of(context).pop();
      
      // Defer success callback and toast to next frame to avoid go_router race condition
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        // Show success toast
        showFToast(
          context: context,
          title: Text(context.tr.typeCreatedSuccessfully),
          duration: const Duration(seconds: 3),
        );
        
        // Call success callback after navigation fully completes
        widget.onSuccess?.call();
      });
    } else {
      // Show error toast
      showFToast(
        context: context,
        title: Text(context.tr.failedToCreateType),
        description: errorMessage != null ? Text(errorMessage) : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(
      createProductTypeControllerProvider(widget.companyId),
    );
    final isLoading = createState.isLoading;

    return UnsavedChangesScope(
      hasChanges: _hasChanges,
      child: FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.createType),
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
