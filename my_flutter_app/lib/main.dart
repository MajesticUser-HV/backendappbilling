import 'package:flutter/material.dart';
import 'package:my_flutter_app/models/product.dart';
import 'package:my_flutter_app/screens/add_product_screen.dart';
import 'package:my_flutter_app/screens/calculate_screen.dart';
import 'package:my_flutter_app/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    futureProducts = ApiService.fetchProducts();
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await ApiService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
      setState(() {
        _refreshProducts();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _navigateToAddEdit(Product? product) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(existingProduct: product),
      ),
    );
    if (result == true) {
      setState(() {
        _refreshProducts();
      });
    }
  }

  void _navigateToCalculate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalculateTotalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Calculate Total',
            onPressed: _navigateToCalculate,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading products: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];
              return ListTile(
                title: Text('${product.name} (${product.brand})'),
                subtitle: Text('Price: ₹${product.price.toStringAsFixed(2)}, Qty: ${product.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit Product',
                      onPressed: () => _navigateToAddEdit(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Product',
                      onPressed: () => _deleteProduct(product.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Product',
        onPressed: () => _navigateToAddEdit(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
