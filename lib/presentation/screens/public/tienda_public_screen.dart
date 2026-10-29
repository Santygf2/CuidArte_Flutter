import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/shop_provider.dart';
import '../../widgets/error_retry.dart';
import '../shop/cart_screen.dart';
import '../../widgets/cuidarte_footer.dart';

class TiendaPublicScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const TiendaPublicScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final shopProv = context.watch<ShopProvider>();
    final products = shopProv.filteredProducts;
    if (!shopProv.hasLoaded && !shopProv.isLoading) {
      Future.microtask(shopProv.loadProducts);
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. HERO HEADER
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA), Color(0xFF27BEF5)],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: isDesktop ? 70.0 : 45.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Text(
                      'Tienda de Suministros Médicos',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 40 : 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Dispositivos biomédicos, suministros y productos de cuidado para el bienestar integral.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 16 : 14.5,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. FILTERS & SEARCH BAR
          Container(
            color: const Color(0xFFF7F8FC),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48.0 : 20.0,
              vertical: 36.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    // Search & Cart Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (val) => shopProv.setSearchQuery(val),
                              style: GoogleFonts.poppins(fontSize: 14.5),
                              decoration: InputDecoration(
                                hintText: 'Buscar producto...',
                                hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Cart floating button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CartScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                              decoration: BoxDecoration(
                                gradient: AppColors.brandGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                                  if (shopProv.cartCount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${shopProv.cartCount}',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: shopProv.categories.map((category) {
                          final isSelected = shopProv.selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onSelected: (_) => shopProv.setCategory(category),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Products Grid
                    if (shopProv.isLoading && shopProv.products.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (shopProv.errorMessage != null &&
                        shopProv.products.isEmpty)
                      ErrorRetry(
                        message: shopProv.errorMessage!,
                        onRetry: shopProv.loadProducts,
                      )
                    else if (products.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'No se encontraron productos con ese filtro.',
                          style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 16),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 4;
                          if (constraints.maxWidth < 650) {
                            crossAxisCount = 1;
                          } else if (constraints.maxWidth < 950) {
                            crossAxisCount = 2;
                          } else if (constraints.maxWidth < 1150) {
                            crossAxisCount = 3;
                          }

                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: products.map((product) {
                              double itemWidth;
                              if (crossAxisCount == 1) {
                                itemWidth = constraints.maxWidth;
                              } else {
                                itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount;
                              }

                              return SizedBox(
                                width: itemWidth,
                                child: _buildProductCard(context, product),
                              );
                            }).toList(),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 3. FOOTER
          CuidArteFooter(onNavigateTab: onNavigateTab),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Container(
              height: 180,
              color: const Color(0xFFF9FAFB),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.medication_outlined, size: 48, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.formatCurrency(product.price),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 14),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      context.read<ShopProvider>().addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} agregado al carrito'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Agregar al Carrito',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
