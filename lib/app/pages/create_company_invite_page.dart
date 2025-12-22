import 'dart:async';

import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/state/create_company_invite_controller.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Page for creating a new company invite.
class CreateCompanyInvitePage extends ConsumerStatefulWidget {
  /// Creates a [CreateCompanyInvitePage].
  const CreateCompanyInvitePage({
    required this.companyId,
    this.onSuccess,
    this.showAsSheet = false,
    super.key,
  });

  /// The ID of the company.
  final String companyId;

  /// Optional callback when invite is created successfully.
  final VoidCallback? onSuccess;

  /// Whether this is being shown as a sheet (true) or page (false).
  final bool showAsSheet;

  @override
  ConsumerState<CreateCompanyInvitePage> createState() =>
      _CreateCompanyInvitePageState();
}

class _CreateCompanyInvitePageState
    extends ConsumerState<CreateCompanyInvitePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRole _selectedRole = const UserMember();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final input = CreateCompanyInviteInput(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _selectedRole,
      companyId: widget.companyId,
    );

    final (success, errorMessage) = await ref
        .read(createCompanyInviteControllerProvider.notifier)
        .createInvite(input);

    if (!mounted) return;

    if (success) {
      // Show success toast
      showFToast(
        context: context,
        title: Text(context.tr.inviteCreatedSuccessfully),
        duration: const Duration(seconds: 3),
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      // Show error toast
      showFToast(
        context: context,
        title: Text(context.tr.failedToCreateInvite),
        description: errorMessage != null ? Text(errorMessage) : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createCompanyInviteControllerProvider);
    final isLoading = createState.isLoading;

    return FScaffold(
      header: FHeader.nested(
        title: Text(context.tr.createInvite),
        prefixes: [
          FHeaderAction(
            icon: Icon(widget.showAsSheet ? FIcons.x : FIcons.chevronLeft),
            onPress: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              // Name field
              FTextFormField(
                controller: _nameController,
                label: Text(context.tr.name),
                hint: context.tr.enterInviteeName,
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

              // Email field
              FTextFormField(
                controller: _emailController,
                label: Text(context.tr.email),
                hint: context.tr.enterInviteeEmail,
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return context.tr.emailRequired;
                  }
                  // Basic email validation
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(trimmed)) {
                    return context.tr.emailInvalid;
                  }
                  return null;
                },
              ),

              // Role selection
              FSelect<UserRole>.rich(
                enabled: !isLoading,
                label: Text(context.tr.role),
                hint: context.tr.selectRole,
                format: (role) => switch (role) {
                  Owner() => context.tr.owner,
                  Manager() => context.tr.manager,
                  UserMember() => context.tr.user,
                  None() => context.tr.none,
                },
                initialValue: _selectedRole,
                onChange: (UserRole? role) {
                  if (role != null) {
                    setState(() {
                      _selectedRole = role;
                    });
                  }
                },
                children: [
                  FSelectItem<UserRole>(
                    title: Text(context.tr.user),
                    value: const UserMember(),
                  ),
                  FSelectItem<UserRole>(
                    title: Text(context.tr.manager),
                    value: const Manager(),
                  ),
                  FSelectItem<UserRole>(
                    title: Text(context.tr.owner),
                    value: const Owner(),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Submit button
              Builder(
                builder: (context) => FButton(
                  style: FButtonStyle.primary(),
                  onPress: isLoading ? null : () => _handleSubmit(context),
                  child: Text(
                    isLoading ? context.tr.creating : context.tr.createInvite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
