import '../models/product.dart';

String _normalizeText(String value) => value.trim().toLowerCase();

List<Product> mergeProductsForCatalog({
  required List<Product> products,
  required List<Product> cartProducts,
}) {
  final byId = <int, Product>{
    for (final product in products) product.id: product,
  };
  final ordered = <Product>[];
  final addedIds = <int>{};

  for (final product in cartProducts) {
    if (addedIds.add(product.id)) {
      ordered.add(byId[product.id] ?? product);
    }
  }

  for (final product in products) {
    if (addedIds.add(product.id)) {
      ordered.add(product);
    }
  }

  return ordered;
}

List<Product> filterProducts(
  List<Product> products, {
  required String query,
  required String category,
}) {
  final search = _normalizeText(query);
  final selectedCategory = _normalizeText(category);

  return products.where((product) {
    final title = _normalizeText(product.title);
    final brand = _normalizeText(product.brand);
    final productCategory = _normalizeText(product.category);
    final tags = product.tags.map(_normalizeText).join(' ');

    final matchesSearch =
        search.isEmpty ||
        title.contains(search) ||
        brand.contains(search) ||
        productCategory.contains(search) ||
        tags.contains(search);

    if (!matchesSearch) {
      return false;
    }

    if (selectedCategory.isEmpty || selectedCategory == 'all') {
      return true;
    }

    final categoryMatches =
        productCategory == selectedCategory ||
        productCategory.contains(selectedCategory) ||
        tags.contains(selectedCategory);

    if (categoryMatches) {
      return true;
    }

    final categoryAliases = {
      'apparel': {
        'apparel',
        'mens-shirts',
        'mens-shoes',
        'womens-dresses',
        'womens-bags',
        'tops',
        'shoes',
      },
      'accessories': {
        'accessories',
        'motorcycle',
        'sports-accessories',
        'smartphones',
        'electronics',
      },
    };

    return categoryAliases[selectedCategory]?.contains(productCategory) ??
        false;
  }).toList();
}
