import 'package:flutter/material.dart';
import 'package:my_flutter_app/models/product.dart';
import 'package:my_flutter_app/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? existingProduct;

  const AddProductScreen({super.key, this.existingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      nameController.text = widget.existingProduct!.name;
      brandController.text = widget.existingProduct!.brand;
      priceController.text = widget.existingProduct!.price.toString();
      quantityController.text = widget.existingProduct!.quantity.toString();
    }
  }

  Future<void> handleSubmit() async {
    final name = nameController.text.trim();
    final brand = brandController.text.trim();
    final priceText = priceController.text.trim();
    final quantityText = quantityController.text.trim();

    if (name.isEmpty || brand.isEmpty || priceText.isEmpty || quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    double? price = double.tryParse(priceText);
    int? quantity = int.tryParse(quantityText);

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price must be a positive number')),
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be a positive integer')),
      );
      return;
    }

    final product = Product(
      name: name,
      brand: brand,
      price: price,
      quantity: quantity,
    );

    setState(() => isLoading = true);

    try {
      if (widget.existingProduct != null) {
        await ApiService.updateProduct(widget.existingProduct!.id!, product);
      } else {
        await ApiService.addProduct(product);
      }
      Navigator.pop(context, true); // success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingProduct == null ? 'Add Product' : 'Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => handleSubmit(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : handleSubmit,
              child: Text(isLoading ? 'Saving...' : 'Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}
