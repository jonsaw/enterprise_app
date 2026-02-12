import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_type.freezed.dart';

/// Represents a product type entity.
@freezed
abstract class ProductType with _$ProductType {
  /// Creates a [ProductType] instance.
  const factory ProductType({
    required String id,
    required String name,
    String? detailsUi,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    String? createdById,
    String? updatedById,
    int? revision,
    User? createdBy,
    User? updatedBy,
  }) = _ProductType;

  const ProductType._();

  /// Creates a [ProductType] from GraphQL list data.
  factory ProductType.fromGraphQL(
    GListProductTypesPaginatedData_listProductTypesPaginated_items data,
  ) {
    return ProductType(
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

  /// Creates a [ProductType] from GraphQL detail query data.
  factory ProductType.fromGGetProductTypeData(
    GGetProductTypeData_productType data,
  ) {
    return ProductType(
      id: data.id.value,
      name: data.name,
      description: data.description,
      detailsUi: data.detailsUi, // Already a JSON string from custom serializer
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
