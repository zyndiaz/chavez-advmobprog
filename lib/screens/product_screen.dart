import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';
import '../services/cart_service.dart';
import '../services/product_filter.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isSearching = false;
  bool _isLoading = true;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final productService = ProductService();
    var products = <Product>[];
    try {
      products = await productService.getAllProducts();
    } catch (_) {}

    var cartItems = <CartProduct>[];
    try {
      final carts = await CartService().getCartsByUserId(1);
      if (carts.isNotEmpty) {
        cartItems = carts.first.products;
      }
    } catch (_) {}

    final productsById = {for (final product in products) product.id: product};
    final cartProducts = <Product>[];
    for (final item in cartItems) {
      final catalogProduct = productsById[item.id];
      if (catalogProduct != null) {
        cartProducts.add(catalogProduct);
        continue;
      }

      try {
        cartProducts.add(await productService.getProductById(item.id));
      } catch (_) {
        cartProducts.add(
          Product(
            id: item.id,
            title: item.title,
            description: 'Product from cart',
            category: 'general',
            price: item.price,
            discountPercentage: item.discountPercentage,
            rating: 0,
            stock: item.quantity,
            tags: const [],
            brand: '',
            sku: '',
            weight: 0,
            dimensions: ProductDimensions(width: 0, height: 0, depth: 0),
            warrantyInformation: '',
            shippingInformation: '',
            availabilityStatus: 'In Stock',
            reviews: const [],
            returnPolicy: '',
            minimumOrderQuantity: 1,
            meta: ProductMeta(
              createdAt: '',
              updatedAt: '',
              barcode: '',
              qrCode: '',
            ),
            images: item.thumbnail.isNotEmpty ? [item.thumbnail] : const [],
            thumbnail: item.thumbnail,
          ),
        );
      }
    }

    final catalog = mergeProductsForCatalog(
      products: products,
      cartProducts: cartProducts,
    );

    if (!mounted) return;
    setState(() {
      _allProducts = catalog;
      _filteredProducts = filterProducts(catalog, query: '', category: 'all');
      _isLoading = false;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _isSearching = query.isNotEmpty || _selectedCategory.isNotEmpty;
      _filteredProducts = filterProducts(
        _allProducts,
        query: query,
        category: _selectedCategory,
      );
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedCategory = '';
      _isSearching = false;
      _filteredProducts = _allProducts;
    });
    FocusScope.of(context).unfocus();
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterProducts(_searchController.text);
    });
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  Widget _buildImage(String imagePath) {
    final isRemote = imagePath.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: isRemote
          ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallbackImage(),
            )
          : Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallbackImage(),
            ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 40.sp,
              color: Colors.grey.shade500,
            ),
            SizedBox(height: 4.h),
            Text(
              'No Image',
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product);

    try {
      await CartService().addToCart(
        userId: 1,
        products: [
          {'id': product.id, 'quantity': 1},
        ],
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart sync failed. Local cart was updated.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!mounted) return;
    _showAddedToCartDialog(context);
  }

  void _showAddedToCartDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF1A237E),
                  size: 24.sp,
                ),
                SizedBox(width: 10.w),
                const CustomText(
                  text: 'Added to cart',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Icon(
                        Icons.search,
                        size: 24.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterProducts,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (_isSearching || _selectedCategory.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: _clearSearch,
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list, size: 24.sp),
                      onSelected: _filterByCategory,
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: '', child: Text('All Categories')),
                        PopupMenuItem(value: 'beauty', child: Text('Beauty')),
                        PopupMenuItem(value: 'apparel', child: Text('Apparel')),
                        PopupMenuItem(
                          value: 'motorcycle',
                          child: Text('Motorcycle'),
                        ),
                        PopupMenuItem(
                          value: 'smartphones',
                          child: Text('Smartphones'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),

            if (_selectedCategory.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Chip(
                      label: CustomText(
                        text: _selectedCategory.toUpperCase(),
                        fontSize: 12.sp,
                      ),
                      onDeleted: () {
                        _filterByCategory('');
                        _searchController.clear();
                        setState(() => _isSearching = false);
                      },
                    ),
                  ],
                ),
              ),

            if (_isSearching || _selectedCategory.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: CustomText(
                  text: '${_filteredProducts.length} products found',
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          CustomText(
                            text: 'No products found',
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      itemCount: _filteredProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return GestureDetector(
                          onTap: () => _showProductDetails(product),
                          child: Card(
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      _buildImage(product.thumbnail),
                                      if (product.stock == 0)
                                        Positioned(
                                          top: 8.h,
                                          left: 8.w,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 2.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              'Out of Stock',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.r),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: product.title,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText(
                                            text: _formatPrice(product.price),
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1A237E),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.add_shopping_cart,
                                              size: 20.sp,
                                              color: const Color.fromARGB(
                                                255,
                                                239,
                                                200,
                                                26,
                                              ),
                                            ),
                                            onPressed: product.stock > 0
                                                ? () => _addToCart(product)
                                                : null,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                height: 250.h,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: _buildImage(
                    product.images.isNotEmpty
                        ? product.images[0]
                        : product.thumbnail,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: product.title,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1A237E,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CustomText(
                              text: product.brand,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CustomText(
                              text: product.category,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      CustomText(
                        text: _formatPrice(product.price),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A237E),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: (product.stock > 0 ? Colors.green : Colors.red)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          product.stock > 0
                              ? '${product.stock} in stock'
                              : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: product.stock > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: 'Description',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A237E),
                      ),
                      SizedBox(height: 8.h),
                      CustomText(text: product.description, fontSize: 14.sp),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: 'Product Details',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A237E),
                      ),
                      SizedBox(height: 8.h),
                      _buildDetailRow('SKU', product.sku),
                      _buildDetailRow('Weight', '${product.weight} kg'),
                      _buildDetailRow('Warranty', product.warrantyInformation),
                      _buildDetailRow('Shipping', product.shippingInformation),
                      _buildDetailRow('Return Policy', product.returnPolicy),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: product.stock > 0
                              ? () {
                                  _addToCart(product);
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: const Color(0xFF1A237E),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: CustomText(
                            text: product.stock > 0
                                ? 'Add to Cart'
                                : 'Out of Stock',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: '$label:',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A237E),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: CustomText(text: value, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
