import 'dart:async';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/pages/company_user_detail_page.dart';
import 'package:enterprise/app/state/company_users_controller.dart';
import 'package:enterprise/app/widgets/page_app_bar.dart';
import 'package:enterprise/app/widgets/resizable_split_view.dart';
import 'package:enterprise/app/widgets/selectable_tile.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_users_page.g.dart';

/// Notifier for managing the selected user ID in the company users page.
@riverpod
class SelectedUserId extends _$SelectedUserId {
  @override
  String? build() => null;

  /// Update the selected user ID.
  set userId(String? userId) {
    state = userId;
  }
}

/// Company Users Page
class CompanyUsersPage extends ConsumerStatefulWidget {
  /// Creates a [CompanyUsersPage].
  const CompanyUsersPage({required this.companyId, super.key});

  /// The ID of the company.
  final String companyId;

  @override
  ConsumerState<CompanyUsersPage> createState() => _CompanyUsersPageState();
}

class _CompanyUsersPageState extends ConsumerState<CompanyUsersPage> {
  int _currentPage = 1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  static const int _pageSize = 20;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
        _currentPage = 1; // Reset to first page on search
      });
    });
  }

  void _onNextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _onPreviousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }

  void _onUserTap(String userId) {
    if (isLargeScreen(context)) {
      ref.read(selectedUserIdProvider.notifier).userId = userId;
    } else {
      unawaited(context.push('/companies/${widget.companyId}/users/$userId'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(
      companyUsersControllerProvider(
        widget.companyId,
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      ),
    );
    final selectedUserId = ref.watch(selectedUserIdProvider);
    final theme = context.theme;

    final usersList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageAppBar(
          title: context.tr.users,
        ),

        // Search bar
        FTextField(
          controller: _searchController,
          hint: context.tr.searchUsers,
          onChange: _onSearchChanged,
        ),

        const SizedBox(height: 16),

        // Content area
        Expanded(
          child: usersAsync.when(
            data: (paginatedUsers) {
              if (paginatedUsers.items.isEmpty) {
                return _buildNoticeContainer(
                  context,
                  Text(
                    context.tr.noUsersFound,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  // Users list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FTileGroup.builder(
                        count: paginatedUsers.items.length,
                        tileBuilder: (context, index) {
                          final companyUser = paginatedUsers.items[index];
                          final user = companyUser.user;
                          final isSelected =
                              companyUser.user?.id ==
                              ref.watch(selectedUserIdProvider);
                          return SelectableTile(
                            title: Text(user?.name ?? context.tr.unknownUser),
                            subtitle: user?.email != null
                                ? Text(user!.email)
                                : null,
                            suffix: _buildRoleBadge(
                              context,
                              companyUser.role,
                            ),
                            onPress: () => _onUserTap(user?.id ?? ''),
                            selected: isSelected,
                          );
                        },
                      ),
                    ),
                  ),

                  // Pagination controls
                  if (paginatedUsers.totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        FButton(
                          style: FButtonStyle.outline(),
                          onPress: paginatedUsers.hasPreviousPage
                              ? _onPreviousPage
                              : null,
                          child: Text(context.tr.previous),
                        ),
                        Text(
                          '${context.tr.page} $_currentPage ${context.tr.ofPage} ${paginatedUsers.totalPages}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        FButton(
                          style: FButtonStyle.outline(),
                          onPress: paginatedUsers.hasNextPage
                              ? _onNextPage
                              : null,
                          child: Text(context.tr.next),
                        ),
                      ],
                    ),
                ],
              );
            },
            loading: () => _buildNoticeContainer(
              context,
              const FCircularProgress(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Text(
                    context.tr.errorLoadingUsers,
                    style: const TextStyle(fontSize: 16),
                  ),
                  FButton(
                    style: FButtonStyle.outline(),
                    onPress: () {
                      ref.invalidate(
                        companyUsersControllerProvider(
                          widget.companyId,
                          page: _currentPage,
                          pageSize: _pageSize,
                          search: _searchQuery.isEmpty ? null : _searchQuery,
                        ),
                      );
                    },
                    child: Text(context.tr.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    // On large screens, use resizable layout
    if (isLargeScreen(context)) {
      return ResizableSplitView(
        initialLeftExtentRatio: screenWidth >= 1024 ? 0.3 : 0.4,
        leftPanel: usersList,
        rightPanel: selectedUserId != null
            ? CompanyUserDetailPage(
                companyId: widget.companyId,
                userId: selectedUserId,
                onClose: () {
                  ref.read(selectedUserIdProvider.notifier).userId = null;
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 64,
                      color: theme.colors.border,
                    ),
                    Text(
                      context.tr.selectUserToViewDetails,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
      );
    }

    return usersList;
  }

  Widget _buildRoleBadge(BuildContext context, UserRole role) {
    switch (role) {
      case Owner():
        return FBadge(
          style: FBadgeStyle.primary(),
          child: Text(context.tr.owner),
        );
      case Manager():
        return FBadge(
          style: FBadgeStyle.secondary(),
          child: Text(context.tr.manager),
        );
      case UserMember():
        return FBadge(
          style: FBadgeStyle.outline(),
          child: Text(context.tr.user),
        );
      case None():
        return FBadge(
          style: FBadgeStyle.outline(),
          child: Text(context.tr.none),
        );
    }
  }

  Widget _buildNoticeContainer(BuildContext context, Widget notice) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colors.border,
              ),
            ),
            child: Center(child: notice),
          ),
        ),
      ],
    );
  }
}
