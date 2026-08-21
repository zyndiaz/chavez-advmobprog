import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// models
import '../models/product.dart';

// widgets
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
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _allProducts = _getFruitProducts();
    _filteredProducts = _allProducts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================
  // FRUIT PRODUCTS WITH LOCAL IMAGES
  // Images should be in assets/images/
  // ============================================
  List<Product> _getFruitProducts() {
    return [
      // TROPICAL FRUITS
      Product(
        id: 1,
        title: 'Fresh Mangoes (1kg)',
        description: 'Sweet and juicy Philippine mangoes, perfect for desserts',
        category: 'tropical',
        price: 250.00,
        discountPercentage: 0,
        rating: 0,
        stock: 50,
        tags: ['mango', 'tropical'],
        brand: 'FreshFruits PH',
        sku: 'MANGO-001',
        weight: 1.0,
        dimensions: ProductDimensions(width: 10, height: 15, depth: 8),
        warrantyInformation: 'Freshness guaranteed for 3 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-01-01',
          updatedAt: '2024-01-01',
          barcode: '123456789',
          qrCode: 'QR123456',
        ),
        images: ['assets/images/mango.jpg'],
        thumbnail: 'assets/images/mango.jpg',
      ),
      Product(
        id: 2,
        title: 'Fresh Bananas (1kg)',
        description: 'Sweet and ripe Cavendish bananas, rich in potassium',
        category: 'tropical',
        price: 120.00,
        discountPercentage: 0,
        rating: 0,
        stock: 80,
        tags: ['banana', 'tropical'],
        brand: 'FreshFruits PH',
        sku: 'BANANA-001',
        weight: 1.0,
        dimensions: ProductDimensions(width: 8, height: 20, depth: 6),
        warrantyInformation: 'Freshness guaranteed for 2 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-01-15',
          updatedAt: '2024-01-15',
          barcode: '987654321',
          qrCode: 'QR987654',
        ),
        images: ['assets/images/banana.jpg'],
        thumbnail: 'assets/images/banana.jpg',
      ),
      Product(
        id: 3,
        title: 'Fresh Pineapple (1pc)',
        description: 'Sweet and tangy Philippine pineapples, perfect for juice',
        category: 'tropical',
        price: 180.00,
        discountPercentage: 0,
        rating: 0,
        stock: 35,
        tags: ['pineapple', 'tropical'],
        brand: 'FreshFruits PH',
        sku: 'PINEAPPLE-001',
        weight: 1.5,
        dimensions: ProductDimensions(width: 12, height: 18, depth: 10),
        warrantyInformation: 'Freshness guaranteed for 4 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-02-01',
          updatedAt: '2024-02-01',
          barcode: '456789123',
          qrCode: 'QR456789',
        ),
        images: ['assets/images/pineapple.jpg'],
        thumbnail: 'assets/images/pineapple.jpg',
      ),
      Product(
        id: 4,
        title: 'Fresh Papaya (1kg)',
        description: 'Sweet and orange papaya, rich in vitamin C',
        category: 'tropical',
        price: 150.00,
        discountPercentage: 0,
        rating: 0,
        stock: 45,
        tags: ['papaya', 'tropical'],
        brand: 'FreshFruits PH',
        sku: 'PAPAYA-001',
        weight: 1.0,
        dimensions: ProductDimensions(width: 10, height: 15, depth: 8),
        warrantyInformation: 'Freshness guaranteed for 3 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-02-15',
          updatedAt: '2024-02-15',
          barcode: '789123456',
          qrCode: 'QR789123',
        ),
        images: ['assets/images/papaya.jpg'],
        thumbnail: 'assets/images/papaya.jpg',
      ),

      // CITRUS FRUITS
      Product(
        id: 5,
        title: 'Fresh Oranges (1kg)',
        description: 'Sweet and juicy oranges, rich in vitamin C',
        category: 'citrus',
        price: 200.00,
        discountPercentage: 0,
        rating: 0,
        stock: 60,
        tags: ['orange', 'citrus'],
        brand: 'FreshFruits PH',
        sku: 'ORANGE-001',
        weight: 1.0,
        dimensions: ProductDimensions(width: 8, height: 8, depth: 8),
        warrantyInformation: 'Freshness guaranteed for 5 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-03-01',
          updatedAt: '2024-03-01',
          barcode: '321654987',
          qrCode: 'QR321654',
        ),
        images: ['assets/images/orange.jpg'],
        thumbnail: 'assets/images/orange.jpg',
      ),
      Product(
        id: 6,
        title: 'Fresh Calamansi (500g)',
        description: 'Small but mighty Philippine citrus, perfect for juice',
        category: 'citrus',
        price: 80.00,
        discountPercentage: 0,
        rating: 0,
        stock: 70,
        tags: ['calamansi', 'citrus'],
        brand: 'FreshFruits PH',
        sku: 'CALAMANSI-001',
        weight: 0.5,
        dimensions: ProductDimensions(width: 5, height: 5, depth: 5),
        warrantyInformation: 'Freshness guaranteed for 3 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-03-15',
          updatedAt: '2024-03-15',
          barcode: '654987321',
          qrCode: 'QR654987',
        ),
        images: ['assets/images/calamansi.jpg'],
        thumbnail: 'assets/images/calamansi.jpg',
      ),

      // BERRIES
      Product(
        id: 7,
        title: 'Fresh Strawberries (250g)',
        description: 'Sweet and fragrant strawberries, perfect for desserts',
        category: 'berries',
        price: 280.00,
        discountPercentage: 0,
        rating: 0,
        stock: 25,
        tags: ['strawberry', 'berries'],
        brand: 'FreshFruits PH',
        sku: 'STRAWBERRY-001',
        weight: 0.25,
        dimensions: ProductDimensions(width: 5, height: 8, depth: 5),
        warrantyInformation: 'Freshness guaranteed for 2 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'Low Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-04-01',
          updatedAt: '2024-04-01',
          barcode: '159753486',
          qrCode: 'QR159753',
        ),
        images: ['assets/images/strawberry.jpg'],
        thumbnail: 'assets/images/strawberry.jpg',
      ),

      // MELONS
      Product(
        id: 8,
        title: 'Fresh Watermelon (1pc)',
        description: 'Sweet and refreshing watermelon, perfect for summer',
        category: 'melons',
        price: 350.00,
        discountPercentage: 0,
        rating: 0,
        stock: 20,
        tags: ['watermelon', 'melon'],
        brand: 'FreshFruits PH',
        sku: 'WATERMELON-001',
        weight: 3.0,
        dimensions: ProductDimensions(width: 20, height: 25, depth: 20),
        warrantyInformation: 'Freshness guaranteed for 5 days',
        shippingInformation: 'Ships in 2-3 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-04-15',
          updatedAt: '2024-04-15',
          barcode: '357951486',
          qrCode: 'QR357951',
        ),
        images: ['assets/images/watermelon.jpg'],
        thumbnail: 'assets/images/watermelon.jpg',
      ),
      Product(
        id: 9,
        title: 'Fresh Cantaloupe (1pc)',
        description: 'Sweet and orange melon with amazing flavor',
        category: 'melons',
        price: 220.00,
        discountPercentage: 0,
        rating: 0,
        stock: 30,
        tags: ['cantaloupe', 'melon'],
        brand: 'FreshFruits PH',
        sku: 'CANTALOUPE-001',
        weight: 1.5,
        dimensions: ProductDimensions(width: 15, height: 15, depth: 15),
        warrantyInformation: 'Freshness guaranteed for 4 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-05-01',
          updatedAt: '2024-05-01',
          barcode: '852741963',
          qrCode: 'QR852741',
        ),
        images: ['assets/images/cantaloupe.jpg'],
        thumbnail: 'assets/images/cantaloupe.jpg',
      ),

      // OTHER FRUITS
      Product(
        id: 10,
        title: 'Fresh Apples (1kg)',
        description: 'Crisp and sweet apples, perfect for eating or pies',
        category: 'other',
        price: 180.00,
        discountPercentage: 0,
        rating: 0,
        stock: 55,
        tags: ['apple', 'crisp'],
        brand: 'FreshFruits PH',
        sku: 'APPLE-001',
        weight: 1.0,
        dimensions: ProductDimensions(width: 8, height: 8, depth: 8),
        warrantyInformation: 'Freshness guaranteed for 5 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-05-15',
          updatedAt: '2024-05-15',
          barcode: '963258741',
          qrCode: 'QR963258',
        ),
        images: ['assets/images/apple.jpg'],
        thumbnail: 'assets/images/apple.jpg',
      ),
      Product(
        id: 11,
        title: 'Fresh Avocado (500g)',
        description: 'Creamy and nutritious avocados, perfect for salads',
        category: 'other',
        price: 160.00,
        discountPercentage: 0,
        rating: 0,
        stock: 40,
        tags: ['avocado', 'healthy'],
        brand: 'FreshFruits PH',
        sku: 'AVOCADO-001',
        weight: 0.5,
        dimensions: ProductDimensions(width: 6, height: 10, depth: 6),
        warrantyInformation: 'Freshness guaranteed for 3 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-06-01',
          updatedAt: '2024-06-01',
          barcode: '147258369',
          qrCode: 'QR147258',
        ),
        images: ['assets/images/avocado.jpg'],
        thumbnail: 'assets/images/avocado.jpg',
      ),
      Product(
        id: 12,
        title: 'Fresh Dragon Fruit (1pc)',
        description: 'Vibrant and sweet dragon fruit, packed with antioxidants',
        category: 'other',
        price: 200.00,
        discountPercentage: 0,
        rating: 0,
        stock: 25,
        tags: ['dragon fruit', 'exotic'],
        brand: 'FreshFruits PH',
        sku: 'DRAGONFRUIT-001',
        weight: 0.5,
        dimensions: ProductDimensions(width: 8, height: 10, depth: 8),
        warrantyInformation: 'Freshness guaranteed for 3 days',
        shippingInformation: 'Ships in 1-2 days',
        availabilityStatus: 'In Stock',
        reviews: [],
        returnPolicy: '24 hours return',
        minimumOrderQuantity: 1,
        meta: ProductMeta(
          createdAt: '2024-06-15',
          updatedAt: '2024-06-15',
          barcode: '369258147',
          qrCode: 'QR369258',
        ),
        images: ['assets/images/dragonfruit.jpg'],
        thumbnail: 'assets/images/dragonfruit.jpg',
      ),
    ];
  }

  void _filterProducts(String query) {
    setState(() {
      _isSearching = query.isNotEmpty || _selectedCategory.isNotEmpty;
      if (query.isEmpty && _selectedCategory.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final title = product.title.toLowerCase();
          final category = product.category.toLowerCase();
          final searchQuery = query.toLowerCase();
          
          bool matchesSearch = searchQuery.isEmpty ||
              title.contains(searchQuery) ||
              category.contains(searchQuery);
              
          bool matchesCategory = _selectedCategory.isEmpty ||
              category == _selectedCategory.toLowerCase();
              
          return matchesSearch && matchesCategory;
        }).toList();
      }
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
    return '₱${price.toStringAsFixed(2)}';
  }

  Widget _buildImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Icon(
        Icons.image_not_supported,
        size: 40.sp,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: Icon(Icons.search, size: 24.sp),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterProducts,
                      decoration: InputDecoration(
                        hintText: 'Search fruits...',
                        hintStyle: TextStyle(fontSize: 14.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
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
                      PopupMenuItem(value: 'tropical', child: Text('Tropical Fruits')),
                      PopupMenuItem(value: 'citrus', child: Text('Citrus Fruits')),
                      PopupMenuItem(value: 'berries', child: Text('Berries')),
                      PopupMenuItem(value: 'melons', child: Text('Melons')),
                      PopupMenuItem(value: 'other', child: Text('Other Fruits')),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            
            // Active filters
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
            
            // Results count
            if (_isSearching || _selectedCategory.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: CustomText(
                  text: '${_filteredProducts.length} products found',
                  fontSize: 14.sp,
                ),
              ),
            
            // Product Grid
            Expanded(
              child: GridView.builder(
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
                                        borderRadius: BorderRadius.circular(4.r),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: product.title,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                CustomText(
                                  text: _formatPrice(product.price),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
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

  // ============================================
  // PRODUCT DETAILS
  // ============================================
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
              // Drag handle
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
              // Product Image
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
                  child: _buildImage(product.images.isNotEmpty 
                      ? product.images[0] 
                      : product.thumbnail),
                ),
              ),
              SizedBox(height: 16.h),
              // Product Info
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
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CustomText(
                              text: product.brand,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CustomText(
                              text: product.category,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Price
                      CustomText(
                        text: _formatPrice(product.price),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),
                      // Stock status
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: (product.stock > 0 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          product.stock > 0 ? '${product.stock} in stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: product.stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: 'Description',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: product.description,
                        fontSize: 14.sp,
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: 'Product Details',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
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
                          onPressed: product.stock > 0 ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
          CustomText(text: '$label:', fontSize: 14.sp, fontWeight: FontWeight.w500),
          SizedBox(width: 8.w),
          Expanded(child: CustomText(text: value, fontSize: 14.sp)),
        ],
      ),
    );
  }
}