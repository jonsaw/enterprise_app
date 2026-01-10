import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_category.freezed.dart';

/// Represents a product category entity.
@freezed
abstract class ProductCategory with _$ProductCategory {
  /// Creates a [ProductCategory] instance.
  const factory ProductCategory({
    required String id,
    required String name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    String? createdById,
    String? updatedById,
    int? revision,
    User? createdBy,
    User? updatedBy,
  }) = _ProductCategory;

  const ProductCategory._();

  /// Creates a [ProductCategory] from GraphQL list data.
  factory ProductCategory.fromGraphQL(
    GListProductCategoriesPaginatedData_listProductCategoriesPaginated_items
    data,
  ) {
    return ProductCategory(
      id: data.id.value,
      name: data.name,
      description: data.description,
      createdAt: DateTime.tryParse(data.createdAt.value),
      updatedAt: DateTime.tryParse(data.updatedAt.value),
      readAt: DateTime.tryParse(data.readAt.value),
      createdById: data.createdById.value,
      updatedById: data.updatedById?.value,
      revision: data.revision,
      createdBy: data.createdBy != null
          ? User(
              id: data.createdBy!.id.value,
              name: data.createdBy!.name,
              email: data.createdBy!.email,
            )
          : null,
      updatedBy: data.updatedBy != null
          ? User(
              id: data.updatedBy!.id.value,
              name: data.updatedBy!.name,
              email: data.updatedBy!.email,
            )
          : null,
    );
  }

  /// Creates a [ProductCategory] from GraphQL detail query data.
  factory ProductCategory.fromGGetProductCategoryData(
    GGetProductCategoryData_productCategory data,
  ) {
    return ProductCategory(
      id: data.id.value,
      name: data.name,
      description: data.description,
      createdAt: DateTime.tryParse(data.createdAt.value),
      updatedAt: DateTime.tryParse(data.updatedAt.value),
      readAt: DateTime.tryParse(data.readAt.value),
      createdById: data.createdById.value,
      updatedById: data.updatedById?.value,
      revision: data.revision,
      createdBy: data.createdBy != null
          ? User(
              id: data.createdBy!.id.value,
              name: data.createdBy!.name,
              email: data.createdBy!.email,
            )
          : null,
      updatedBy: data.updatedBy != null
          ? User(
              id: data.updatedBy!.id.value,
              name: data.updatedBy!.name,
              email: data.updatedBy!.email,
            )
          : null,
    );
  }
}
