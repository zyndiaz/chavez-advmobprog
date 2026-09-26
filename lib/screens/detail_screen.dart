import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product? product;
  final CartProduct? cartItem;

  const ProductDetailScreen({super.key, this.product, this.cartItem});

  Product get _resolvedProduct {
    if (product != null) {
      return product!;
    }

    final item = cartItem!;
    return Product(
      id: item.id,
      title: item.title,
      description: 'This item is from your cart and can be reviewed in detail.',
      category: 'accessories',
      price: item.price,
      discountPercentage: item.discountPercentage,
      rating: 0,
      stock: item.quantity > 0 ? item.quantity * 10 : 1,
      tags: const ['cart', 'featured'],
      brand: 'NU Merchandise',
      sku: 'CART-${item.id}',
      weight: 0,
      dimensions: ProductDimensions(width: 0, height: 0, depth: 0),
      warrantyInformation: 'Standard return and warranty terms apply.',
      shippingInformation: 'Ships in 1-2 days',
      availabilityStatus: 'In Stock',
      reviews: const [],
      returnPolicy: '14 days return policy',
      minimumOrderQuantity: 1,
      meta: ProductMeta(createdAt: '', updatedAt: '', barcode: '', qrCode: ''),
      images: item.thumbnail.isNotEmpty ? [item.thumbnail] : const [],
      thumbnail: item.thumbnail,
    );
  }

  Widget _buildImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: imagePath.startsWith('assets/')
          ? Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.network(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image_not_supported,
                  size: 40.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
    );
  }

  Future<void> _addToCart(BuildContext context, Product product) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product);

    try {
      await CartService().addToCart(
        userId: 1,
        products: [
          {'id': product.id, 'quantity': 1},
        ],
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added to cart'),
            backgroundColor: Color(0xFF1A237E),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cart sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _resolvedProduct;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Product Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 260.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: _buildImage(
                    product.images.isNotEmpty
                        ? product.images.first
                        : product.thumbnail,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              CustomText(
                text: product.title,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A237E),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: CustomText(
                  text: product.brand,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A237E),
                ),
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: '₱${product.price.toStringAsFixed(2)}',
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A237E),
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: product.description,
                fontSize: 15.sp,
                color: Colors.grey.shade800,
              ),
              SizedBox(height: 20.h),
              _buildDetailRow('Category', product.category),
              _buildDetailRow('Stock', '${product.stock} available'),
              _buildDetailRow('Warranty', product.warrantyInformation),
              _buildDetailRow('Shipping', product.shippingInformation),
              _buildDetailRow('Return Policy', product.returnPolicy),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addToCart(context, product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: const Color(0xFF1A237E),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const CustomText(
                    text: 'Add to Cart',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
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
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: CustomText(
              text: '$label:',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 14.sp,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
