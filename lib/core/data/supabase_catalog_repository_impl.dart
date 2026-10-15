import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

/// Phase 3: live Supabase-backed catalog, selected by
/// `catalogRepositoryProvider` (catalog_repository_impl.dart) instead of
/// `MockCatalogRepository` when Env.dataSource != 'mock'. Column aliases
/// map snake_case Postgres columns onto the camelCase fields the freezed
/// fromJson expects.
class SupabaseCatalogRepository implements CatalogRepository {
  final SupabaseClient client;

  SupabaseCatalogRepository(this.client);

  @override
  Future<List<Category>> fetchCategories() async {
    final rows = await client
        .from('categories')
        .select(
          'id, name, image, colorHex:color_hex, borderColorHex:border_color_hex',
        )
        .order('sort_order');

    return rows.map((row) => Category.fromJson(row)).toList();
  }

  @override
  Future<List<Product>> fetchProducts() async {
    final rows = await client
        .from('products')
        .select('''
          id, name, image, categoryId:category_id,
          variants:product_variants(id, label, pricePaise:price_paise, mrpPaise:mrp_paise)
        ''')
        .eq('is_active', true);

    return rows.map((row) => Product.fromJson(row)).toList();
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    final row = await client
        .from('products')
        .select('''
          id, name, image, categoryId:category_id,
          variants:product_variants(id, label, pricePaise:price_paise, mrpPaise:mrp_paise)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (row == null) return null;

    return Product.fromJson(row);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return [];

    final rows = await client
        .from('products')
        .select('''
          id, name, image, categoryId:category_id,
          variants:product_variants(id, label, pricePaise:price_paise, mrpPaise:mrp_paise)
        ''')
        .eq('is_active', true)
        .textSearch(
          'search_vector',
          normalized,
          config: 'english',
          type: TextSearchType.websearch,
        );

    return rows.map((row) => Product.fromJson(row)).toList();
  }
}
