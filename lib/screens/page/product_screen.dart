import 'package:flutter/material.dart';
import '../../models/product.dart';

import '../../data/mockdata.dart' as data;
import '../widgets/card_widget.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController searchController = TextEditingController();
  final List<Product> products = data.products;
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = List<Product>.from(products);
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List<Product>.from(products);
      } else {
        filteredProducts = products
            .where((p) => (p.name ?? '').toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(child: Text('Không tìm thấy sản phẩm'))
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return CardItemList(p: product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
