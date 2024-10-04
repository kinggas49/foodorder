import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History', style : TextStyle(color : Colors.brown)),
        backgroundColor:  Colors.orange.shade50,
        elevation: 0,
      ),
      backgroundColor: Colors.orange.shade100,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator
          }

          if (!snapshot.hasData) return Center(child: Text('No orders found'));

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var items = order['items'] as List;

              return OrderItem(
                date: order['date'].toDate(),
                items: items,
                totalOrder: order['totalOrder'],
                status: order['status'],
                currencyFormat: currencyFormat,
              );
            },
          );
        },
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final DateTime date;
  final List items;
  final double totalOrder;
  final String status;
  final NumberFormat currencyFormat;

  OrderItem({
    required this.date,
    required this.items,
    required this.totalOrder,
    required this.status,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(color: Colors.brown, width: 1),
            ),
            color: Colors.white.withOpacity(0.7),
            elevation: 0,
            margin: EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                  child: Container(
                    padding: EdgeInsets.all(8.0), // Add padding if needed
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      border: Border.all(
                        color: Colors.brown,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text('${DateFormat('dd-MM-yyyy, HH:mm').format(date)}'),
                  ),
                ),
                  SizedBox(height: 8),
                  ...items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.orange.shade100),
                              image: DecorationImage(
                                image: NetworkImage(item['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: TextStyle(fontSize: 16)),
                                Text('x ${item['quantity']}', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Spacer(),
                      ElevatedButton(
                        onPressed: null,
                        child: Text(currencyFormat.format(totalOrder)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 36), // Adjust size as needed
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (status == 'Sudah Siap' || status == 'Sedang disiapkan')
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Sudah Siap' ? Colors.orange.shade100 : const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  ),
                  border : Border.all(color : Colors.brown, width : 1)
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
