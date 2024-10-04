import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminOrderPage extends StatefulWidget {
  @override
  _AdminOrderPageState createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage> {
  // Map to track the state of each order's finish button
  Map<String, bool> _orderFinishState = {};

  void _handleFinishPressed(String orderId, DocumentReference orderRef) async {
    if (_orderFinishState[orderId] == true) {
      return; // Button already pressed, do nothing
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(orderRef);
      transaction.update(freshSnap.reference, {'status': 'Sudah Siap'});
    });

    setState(() {
      _orderFinishState[orderId] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text(
          'Admin Order Management',
          style: GoogleFonts.plusJakartaSans(),
        ),
        backgroundColor: Colors.orange.shade100,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('date', descending: true) // Sort by date in descending order
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var items = order['items'] as List;
              String orderId = order.id;

              // Initialize the state for the order if it doesn't exist
              if (!_orderFinishState.containsKey(orderId)) {
                _orderFinishState[orderId] = order['status'] == 'Sudah Siap';
              }

              bool isPressed = _orderFinishState[orderId] ?? false;

              return Card(
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
                      if (order['date'] != null)
                        Text(
                          'Tanggal dan jam: ${DateFormat('dd-MM-yyyy, HH:mm').format(order['date'].toDate())}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(
                        height: 8,
                        child: Divider(color: Color.fromARGB(255, 255, 224, 178)),
                      ),
                      const SizedBox(height: 8),
                      if (order['customerName'] != null)
                        Text(
                          'Customer: ${order['customerName']?? 'null'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        
                      
                      const SizedBox(height: 8),
                      ...items.map((item) {
                        return item != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'],
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'x ${item['quantity']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            : Container();
                      }).toList(),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Total Harga: ${currencyFormat.format(order['totalOrder'])}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade100,
                              foregroundColor: Colors.brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isPressed ? null : () => _handleFinishPressed(orderId, order.reference),
                            child: Text('Finish'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPressed ? Colors.transparent : Colors.orange.shade100,
                              foregroundColor: isPressed ? Colors.brown.withOpacity(0.5) : Colors.brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: BorderSide(color: Colors.brown, width: isPressed ? 2.0 : 0.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
