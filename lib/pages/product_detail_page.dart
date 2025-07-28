import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugasakhir_mobile/models/produk_model.dart';
import 'package:tugasakhir_mobile/services/cart_service.dart';
import 'package:tugasakhir_mobile/services/wishlist_service.dart';

class ProductDetailPage extends StatefulWidget {
  final ProdukModel product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();
  final PageController _thumbnailController = PageController();

  // Format currency
  final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Daftar warna yang tersedia
  final List<Color> _availableColors = [
    Colors.grey,
    Colors.green,
    Colors.brown,
    Colors.red,
    Colors.blue,
  ];

  // Daftar nama warna
  final Map<Color, String> _colorNames = {
    Colors.grey: 'Grey',
    Colors.green: 'Green',
    Colors.brown: 'Brown',
    Colors.red: 'Red',
    Colors.blue: 'Blue',
  };

  // Warna yang dipilih (default: grey)
  Color _selectedColor = Colors.grey;

  // Status apakah item sudah ditambahkan ke cart
  bool _showAddedToSavedMessage = false;
  bool _isInWishlist = false;

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final isInWishlist = await _wishlistService.isInWishlist(widget.product.id);
    setState(() {
      _isInWishlist = isInWishlist;
    });
  }

  // Handle adding/removing from wishlist
  Future<void> _toggleWishlist() async {
    bool success;

    if (_isInWishlist) {
      // Remove from wishlist
      success = await _wishlistService.removeFromWishlist(widget.product.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from wishlist')),
        );
      }
    } else {
      // Add to wishlist
      success = await _wishlistService.addToWishlist(widget.product);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to wishlist')),
        );
      }
    }

    // Update wishlist status
    if (success) {
      setState(() {
        _isInWishlist = !_isInWishlist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            Column(
              children: [
                // App Bar
                _buildAppBar(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        _buildProductImage(),

                        // Thumbnail Carousel
                        _buildThumbnailCarousel(),

                        // Product info
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name and Wishlist button
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.product.namaProduk,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _toggleWishlist,
                                    icon: Icon(
                                      _isInWishlist
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _isInWishlist ? Colors.red : null,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Price and Rating
                              Row(
                                children: [
                                  Text(
                                    _currencyFormat
                                        .format(widget.product.getHargaAsInt()),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '4.5',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(40 Review)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Product Description
                              const Text(
                                'Product Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'JBL Charge 3 is the ultimate, high-powered portable Bluetooth speaker with powerful stereo sound and a power bank all in one package. The Charge 3 takes the party everywhere, poolside or in the rain, thanks to the waterproof design, durable fabric and rugged housing.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Color Selection
                              const Text(
                                'Select Color: Black',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Color options
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: _availableColors.map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = color;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedColor == color
                                              ? Colors.blue
                                              : Colors.grey[300]!,
                                          width:
                                              _selectedColor == color ? 2 : 1,
                                        ),
                                      ),
                                      child: _selectedColor == color
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            )
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 80), // Space for button
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Add to Cart Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Added to Saved Message
            if (_showAddedToSavedMessage)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Item Added to Saved',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _showAddedToSavedMessage = false;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 300,
      width: double.infinity,
      child: widget.product.gambarProduk != null &&
              widget.product.gambarProduk!.isNotEmpty
          ? Image.network(
              widget.product.getImageUrl() ?? '',
              fit: BoxFit.contain,
            )
          : Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
            ),
    );
  }

  Widget _buildThumbnailCarousel() {
    // Simulasikan 5 thumbnail dari gambar yang sama
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index;
                _thumbnailController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentImageIndex == index
                      ? Colors.blue
                      : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: widget.product.gambarProduk != null &&
                        widget.product.gambarProduk!.isNotEmpty
                    ? Image.network(
                        widget.product.getImageUrl() ?? '',
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Menambahkan produk ke cart
  void _addToCart() async {
    final colorName = _colorNames[_selectedColor] ?? 'Grey';
    final success = await _cartService.addToCart(widget.product, colorName);

    if (success && mounted) {
      setState(() {
        _showAddedToSavedMessage = true;
      });

      // Sembunyikan pesan setelah 3 detik
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showAddedToSavedMessage = false;
          });
        }
      });
    }
  }
}
