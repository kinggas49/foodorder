import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'cart_model.dart';
import 'order_page.dart';

class OrderSummaryPage extends StatelessWidget {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  OrderSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 213, 157),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade50,
        title: const Text("Total Order"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: cart.items.values.map((item) => CartItemTile(item: item)).toList(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.orange.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${cart.totalItems} items'),
            ElevatedButton(
              onPressed: () async {
                await _showCustomerNameDialog(context, cart);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 245, 213, 157),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side : BorderSide(color: Colors.brown)

                )
              ),
              child: Text(
                currencyFormat.format(cart.totalPrice) + ' - Place Order',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomerNameDialog(BuildContext context, CartModel cart) async {
    final TextEditingController _nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.brown),
          ),
          title: const Text('Masukkan Nama',style :TextStyle(color: Colors.brown)),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Name', hintStyle: TextStyle(color:Colors.brown)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.brown),),
            ),
            TextButton(
  onPressed: () async {
    if (_nameController.text.isNotEmpty) {
      await _storeOrderData(context, cart, _nameController.text);
      cart.clearCart();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OrderPage())); // Replace current route with OrderPage
    }
  },
  child: const Text('OK',style: TextStyle(color: Colors.brown)),
),
          ],
          backgroundColor: const Color.fromARGB(255, 245, 213, 157),
        );
      },
    );
  }

  Future<void> _storeOrderData(BuildContext context, CartModel cart, String customerName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final orderData = {
      'email': user.email,
      'customerName': customerName,
      'date': Timestamp.now(),
      'totalOrder': cart.totalPrice,
      'status': 'Sedang disiapkan',
      'items': cart.items.values.map((item) => {
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'image': item.image,
      }).toList(),
    };

    // Add the order to Firestore and get the document reference
    final orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);

    // Update the order with the generated document ID
    await orderRef.update({'id': orderRef.id});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order has been successfully placed')),
      );

      cart.clearCart();

      // Navigate to the orders page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderPage()),
      );
    }
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context, listen: false);
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(color: Colors.brown, width: 1),
      ),
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: Colors.brown, width: 0.5),
                    image: DecorationImage(
                      image: NetworkImage(item.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(currencyFormat.format(item.price), style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.brown, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          cart.decrementItem(item.id);
                        },
                        icon: const Icon(Icons.remove, size: 16),
                        color: Colors.brown,
                        padding: const EdgeInsets.all(0), // Adjust padding to fit the container
                        constraints: const BoxConstraints(),
                      ),
                      Text('${item.quantity}', style: const TextStyle(color: Colors.brown, fontSize: 16)),
                      IconButton(
                        onPressed: () {
                          cart.incrementItem(item.id);
                        },
                        icon: const Icon(Icons.add, size: 16),
                        color: Colors.brown,
                        padding: const EdgeInsets.all(0), // Adjust padding to fit the container
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Text('Total: ${currencyFormat.format(item.quantity * item.price)}', style: const TextStyle(color: Colors.brown, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
