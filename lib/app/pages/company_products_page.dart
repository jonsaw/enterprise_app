import 'dart:async';

import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/pages/company_product_detail_page.dart';
import 'package:enterprise/app/pages/create_product_page.dart';
import 'package:enterprise/app/state/permissions.dart';
import 'package:enterprise/app/state/products_controller.dart';
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

/// Company Products Page
class CompanyProductsPage extends ConsumerStatefulWidget {
  /// Creates a [CompanyProductsPage].
  const CompanyProductsPage({required this.companyId, super.key});

  /// The ID of the company.
  final String companyId;

  @override
  ConsumerState<CompanyProductsPage> createState() =>
      _CompanyProductsPageState();
}

class _CompanyProductsPageState extends ConsumerState<CompanyProductsPage> {
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
        _currentPage = 1;
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

  void _onProductTap(String productId) {
    ref.read(selectedIdProvider(SelectedIdType.product).notifier).id =
        productId;
    if (!isMediumOrLargeScreen(context)) {
      context.go(
        '/companies/${widget.companyId}/products/$productId',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(
      productsControllerProvider(
        widget.companyId,
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      ),
    );
    final selectedProductId = ref.watch(
      selectedIdProvider(SelectedIdType.product),
    );
    final userRoleAsync = ref.watch(
      companyPermissionsProvider(widget.companyId),
    );
    final theme = context.theme;

    final productsList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        FTextField(
          control: .managed(
            controller: _searchController,
            onChange: _onSearchChanged,
          ),
          hint: context.tr.searchProducts,
        ),

        const SizedBox(height: 16),

        // Content area
        Expanded(
          child: productsAsync.when(
            data: (paginatedProducts) {
              if (paginatedProducts.items.isEmpty) {
                return _buildNoticeContainer(
                  context,
                  Text(
                    context.tr.noProductsFound,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  // Products list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FTileGroup.builder(
                        count: paginatedProducts.items.length,
                        tileBuilder: (context, index) {
                          final product = paginatedProducts.items[index];
                          final isSelected =
                              product.id ==
                              ref.watch(
                                selectedIdProvider(SelectedIdType.product),
                              );
                          final subtitle = [
                            if (product.brand != null) product.brand!,
                            if (product.model != null) product.model!,
                          ].join(' ');
                          return SelectableTile(
                            title: Text(product.sku),
                            subtitle: subtitle.isNotEmpty
                                ? Text(subtitle)
                                : null,
                            onPress: () => _onProductTap(product.id),
                            selected: isSelected,
                          );
                        },
                      ),
                    ),
                  ),

                  // Pagination controls
                  if (paginatedProducts.totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        FButton(
                          variant: .outline,
                          onPress: paginatedProducts.hasPreviousPage
                              ? _onPreviousPage
                              : null,
                          child: Text(context.tr.previous),
                        ),
                        Text(
                          '${context.tr.page} $_currentPage ${context.tr.ofPage} ${paginatedProducts.totalPages}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        FButton(
                          variant: .outline,
                          onPress: paginatedProducts.hasNextPage
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
                    context.tr.errorLoadingProducts,
                    style: const TextStyle(fontSize: 16),
                  ),
                  FButton(
                    variant: .outline,
                    onPress: () {
                      ref.invalidate(
                        productsControllerProvider(
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
            title: Text(context.tr.productsList),
            prefixes: [
              if (isMediumScreen(context))
                AppSidebarIconButton(companyId: widget.companyId),
            ],
            suffixes: [
              if (canManage)
                FButton.icon(
                  variant: .ghost,
                  onPress: () {
                    unawaited(
                      showFSheet<void>(
                        useRootNavigator: true,
                        context: context,
                        side: FLayout.rtl,
                        barrierDismissible: false,
                        builder: (context) => CreateProductPage(
                          companyId: widget.companyId,
                          showAsSheet: true,
                          onSuccess: () {
                            ref.invalidate(productsControllerProvider);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Icon(FIcons.plus),
                ),
            ],
          ),
          child: SafeArea(
            right: false,
            bottom: false,
            child: productsList,
          ),
        ),
        rightPanel: selectedProductId != null
            ? CompanyProductDetailPage(
                companyId: widget.companyId,
                productId: selectedProductId,
                onClose: () {
                  ref
                          .read(
                            selectedIdProvider(
                              SelectedIdType.product,
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
                        FIcons.package2,
                        size: 64,
                        color: theme.colors.mutedForeground,
                      ),
                      Text(
                        context.tr.selectProductToViewDetails,
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
        title: Text(context.tr.productsList),
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
                        '/companies/${widget.companyId}/products/create',
                      )
                      .then((_) {
                        ref.invalidate(productsControllerProvider);
                      }),
                );
              },
              child: const Icon(FIcons.plus),
            ),
        ],
      ),
      child: SafeArea(top: false, left: false, child: productsList),
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
              borderRadius: const BorderRadius.all(Radius.circular(8)),
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
