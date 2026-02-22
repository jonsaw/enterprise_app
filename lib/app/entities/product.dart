import 'package:api_management/api_management.dart';
import 'package:enterprise/app/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

/// Represents a product entity.
@freezed
abstract class Product with _$Product {
  /// Creates a [Product] instance.
  const factory Product({
    required String id,
    required String companyId,
    required String sku,
    required String description,
    required String detailsData,
    required bool affectsInventory,
    required int revision,
    String? brand,
    String? model,
    String? categoryId,
    String? typeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    String? createdById,
    String? updatedById,
    User? createdBy,
    User? updatedBy,
  }) = _Product;

  const Product._();

  /// Creates a [Product] from GraphQL list data.
  factory Product.fromGraphQL(
    GListProductsPaginatedData_listProductsPaginated_items data,
  ) {
    return Product._fromFields(
      id: data.id.value,
      companyId: data.companyId.value,
      sku: data.sku,
      brand: data.brand,
      model: data.model,
      categoryId: data.categoryId?.value,
      typeId: data.typeId?.value,
      description: data.description,
      detailsData: data.detailsData,
      affectsInventory: data.affectsInventory,
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

  /// Creates a [Product] from GraphQL detail query data.
  factory Product.fromGGetProductData(
    GGetProductData_product data,
  ) {
    return Product._fromFields(
      id: data.id.value,
      companyId: data.companyId.value,
      sku: data.sku,
      brand: data.brand,
      model: data.model,
      categoryId: data.categoryId?.value,
      typeId: data.typeId?.value,
      description: data.description,
      detailsData: data.detailsData,
      affectsInventory: data.affectsInventory,
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

  factory Product._fromFields({
    required String id,
    required String companyId,
    required String sku,
    required String description,
    required String detailsData,
    required bool affectsInventory,
    required int revision,
    required String createdById,
    String? brand,
    String? model,
    String? categoryId,
    String? typeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    String? updatedById,
    User? createdBy,
    User? updatedBy,
  }) {
    return Product(
      id: id,
      companyId: companyId,
      sku: sku,
      brand: brand,
      model: model,
      categoryId: categoryId,
      typeId: typeId,
      description: description,
      detailsData: detailsData,
      affectsInventory: affectsInventory,
      createdAt: createdAt,
      updatedAt: updatedAt,
      readAt: readAt,
      createdById: createdById,
      updatedById: updatedById,
      revision: revision,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}
