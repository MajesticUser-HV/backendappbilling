import 'package:flutter/material.dart';
import 'package:my_flutter_app/services/api_service.dart';

class CalculateTotalScreen extends StatefulWidget {
  const CalculateTotalScreen({super.key});

  @override
  State<CalculateTotalScreen> createState() => _CalculateTotalScreenState();
}

class _CalculateTotalScreenState extends State<CalculateTotalScreen> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();

  double? totalPrice;
  bool isLoading = false;
  String? error;

  Future<void> calculateTotal() async {
    final name = nameController.text.trim();
    final qtyText = quantityController.text.trim();
    if (name.isEmpty || qtyText.isEmpty) {
      setState(() {
        error = 'Please enter both product name and quantity';
        totalPrice = null;
      });
      return;
    }

    int? quantity = int.tryParse(qtyText);
    if (quantity == null || quantity <= 0) {
      setState(() {
        error = 'Quantity must be a positive integer';
        totalPrice = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
      totalPrice = null;
    });

    try {
      double total = await ApiService.calculateTotal(name, quantity);
      setState(() {
        totalPrice = total;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to calculate total: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculate Total')),
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
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => calculateTotal(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : calculateTotal,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Calculate Total'),
            ),
            const SizedBox(height: 20),
            if (totalPrice != null)
              Text(
                'Total Price: ₹${totalPrice!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
