import 'dart:async';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/pages/company_product_type_detail_page.dart';
import 'package:enterprise/app/pages/create_product_type_page.dart';
import 'package:enterprise/app/state/permissions.dart';
import 'package:enterprise/app/state/product_types_controller.dart';
import 'package:enterprise/app/state/selected_id_provider.dart';
import 'package:enterprise/app/state/split_view_size_provider.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/app/widgets/app_sidebar.dart';
import 'package:enterprise/app/widgets/resizable_split_view.dart';
import 'package:enterprise/app/widgets/selectable_tile.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

/// Company Product Types Page
class CompanyProductTypesPage extends ConsumerStatefulWidget {
  /// Creates a [CompanyProductTypesPage].
  const CompanyProductTypesPage({required this.companyId, super.key});

  /// The ID of the company.
  final String companyId;

  @override
  ConsumerState<CompanyProductTypesPage> createState() =>
      _CompanyProductTypesPageState();
}

class _CompanyProductTypesPageState
    extends ConsumerState<CompanyProductTypesPage> {
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

  void _onSearchChanged(TextEditingValue value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.text;
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

  void _onTypeTap(String typeId) {
    ref.read(selectedIdProvider(SelectedIdType.productType).notifier).id =
        typeId;
    if (!isMediumOrLargeScreen(context)) {
      // On small screens, push the detail route
      context.go(
        '/companies/${widget.companyId}/product-types/$typeId',
      );
    }
    // On medium/large screens, just update the selected ID (split view handles it)
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(
      productTypesControllerProvider(
        widget.companyId,
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      ),
    );
    final selectedTypeId = ref.watch(
      selectedIdProvider(SelectedIdType.productType),
    );
    final userRoleAsync = ref.watch(
      companyPermissionsProvider(widget.companyId),
    );
    final theme = context.theme;

    final typesList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        FTextField(
          control: .managed(
            controller: _searchController,
            onChange: _onSearchChanged,
          ),
          hint: context.tr.searchTypes,
        ),

        const SizedBox(height: 16),

        // Content area
        Expanded(
          child: typesAsync.when(
            data: (paginatedTypes) {
              if (paginatedTypes.items.isEmpty) {
                return _buildNoticeContainer(
                  context,
                  Text(
                    context.tr.noTypesFound,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  // Types list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FTileGroup.builder(
                        count: paginatedTypes.items.length,
                        tileBuilder: (context, index) {
                          final type = paginatedTypes.items[index];
                          final isSelected =
                              type.id ==
                              ref.watch(
                                selectedIdProvider(
                                  SelectedIdType.productType,
                                ),
                              );
                          return SelectableTile(
                            title: Text(type.name),
                            subtitle: type.description != null
                                ? Text(type.description!)
                                : null,
                            onPress: () => _onTypeTap(type.id),
                            selected: isSelected,
                          );
                        },
                      ),
                    ),
                  ),

                  // Pagination controls
                  if (paginatedTypes.totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        FButton(
                          variant: .outline,
                          onPress: paginatedTypes.hasPreviousPage
                              ? _onPreviousPage
                              : null,
                          child: Text(context.tr.previous),
                        ),
                        Text(
                          '${context.tr.page} $_currentPage ${context.tr.ofPage} ${paginatedTypes.totalPages}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        FButton(
                          variant: .outline,
                          onPress: paginatedTypes.hasNextPage
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
                    context.tr.errorLoadingTypes,
                    style: const TextStyle(fontSize: 16),
                  ),
                  FButton(
                    variant: .outline,
                    onPress: () {
                      ref.invalidate(
                        productTypesControllerProvider(
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

    // Check permissions for create button
    final canManage = userRoleAsync.maybeWhen(
      data: (role) => role is Owner || role is Manager,
      orElse: () => false,
    );

    // On large screens, use resizable layout
    if (isMediumOrLargeScreen(context)) {
      return ResizableSplitView(
        sizeGroup: companyPagesGroup,
        leftPanel: FScaffold(
          header: AppHeader(
            safeAreaRight: false,
            title: Text(context.tr.types),
            prefixes: [
              if (isMediumScreen(context))
                AppSidebarIconButton(companyId: widget.companyId),
            ],
            suffixes: [
              if (canManage)
                FButton.icon(
                  variant: .ghost,
                  onPress: () {
                    if (isMediumOrLargeScreen(context)) {
                      // Show as sheet on larger screens
                      unawaited(
                        showFSheet<void>(
                          useRootNavigator: true,
                          context: context,
                          side: FLayout.rtl,
                          barrierDismissible: false,
                          builder: (context) => CreateProductTypePage(
                            companyId: widget.companyId,
                            showAsSheet: true,
                            onSuccess: () {
                              ref.invalidate(
                                productTypesControllerProvider,
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      // Push as route on mobile screens
                      unawaited(
                        context
                            .push(
                              '/companies/${widget.companyId}/product-types/create',
                            )
                            .then((_) {
                              // Refresh the list when returning from create page
                              ref.invalidate(
                                productTypesControllerProvider,
                              );
                            }),
                      );
                    }
                  },
                  child: const Icon(FIcons.plus),
                ),
            ],
          ),
          child: SafeArea(
            right: false,
            bottom: false,
            child: typesList,
          ),
        ),
        rightPanel: selectedTypeId != null
            ? CompanyProductTypeDetailPage(
                companyId: widget.companyId,
                typeId: selectedTypeId,
                onClose: () {
                  ref
                          .read(
                            selectedIdProvider(
                              SelectedIdType.productType,
                            ).notifier,
                          )
                          .id =
                      null;
                },
              )
            : FScaffold(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Icon(
                        Icons.type_specimen_outlined,
                        size: 64,
                        color: theme.colors.mutedForeground,
                      ),
                      Text(
                        context.tr.selectTypeToViewDetails,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    return FScaffold(
      header: AppHeader(
        title: Text(context.tr.productTypes),
        prefixes: [
          if (isSmallScreen(context))
            AppSidebarIconButton(
              companyId: widget.companyId,
            ),
        ],
        suffixes: [
          if (canManage)
            FButton.icon(
              onPress: () {
                unawaited(
                  context
                      .push(
                        '/companies/${widget.companyId}/product-types/create',
                      )
                      .then((_) {
                        // Refresh the list when returning from create page
                        ref.invalidate(productTypesControllerProvider);
                      }),
                );
              },
              child: const Icon(FIcons.plus),
            ),
        ],
      ),
      child: SafeArea(top: false, left: false, child: typesList),
    );
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
