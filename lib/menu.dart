import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'login_screen.dart';
import 'cart_model.dart';

class CustomCacheManager extends CacheManager {
  static const key = "customCacheKey";

  static CustomCacheManager? _instance; // Make _instance nullable

  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._(); // Initialize only if _instance is null
    return _instance!;
  }

  CustomCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 7), // Cache for 7 days
            maxNrOfCacheObjects: 200, // Max number of cached images
          ),
        );
}

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MenuPageContent();
  }
}

class MenuPageContent extends StatelessWidget {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 245, 213, 157),
        appBar: AppBar(
          backgroundColor: Colors.orange.shade50,
          title: Text("Our Menu's", style: GoogleFonts.plusJakartaSans()),
          centerTitle: true,
          bottom: TabBar(
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: Colors.orange, width: 2),
              insets: EdgeInsets.symmetric(horizontal: 50),
            ),
            tabs: [
              Tab(
                icon: Image.asset(
                  'assets/coffee.png',
                  height: 30,
                ),
                text: "Beverages",
              ),
              Tab(
                icon: Image.asset(
                  'assets/meals.png',
                  height: 30,
                ),
                text: "Meals",
              ),
            ],
          ),
          actions: [
            Consumer<CartModel>(
              builder: (context, cart, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.pushNamed(context, '/order_summary');
                      },
                    ),
                    if (cart.totalItems > 0)
                      Positioned(
                        right: 11,
                        top: 11,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 245, 213, 157),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.totalItems}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                );
              },
            )
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Color.fromARGB(255, 245, 213, 157),
            child: ListView(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.brown),
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? "default_image_placeholder"),
                            ),
                            SizedBox(height: 10),
                            Text(
                              FirebaseAuth.instance.currentUser?.displayName ?? "Guest",
                              style: TextStyle(color: Color.fromARGB(255, 123, 89, 52), fontSize: 20),
                            ),
                            Text(
                              FirebaseAuth.instance.currentUser?.email ?? "",
                              style: TextStyle(color: Color.fromARGB(255, 123, 89, 52), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildDrawerItem(context, Icons.shopping_cart, "Menu", '/menu'),
                _buildDrawerItem(context, Icons.receipt, "Order Summary", '/order_summary'),
                _buildDrawerItem(context, Icons.history, "Order History", '/order_page'),
                _buildDrawerItem(context, Icons.logout, "Sign Out", '', signOut: true),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                MenuList(category: 'Beverages'),
                MenuList(category: 'Meals'),
              ],
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Consumer<CartModel>(
                builder: (context, cart, child) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/order_summary');
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 253, 253, 253),
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                          color: Color.fromARGB(255, 123, 89, 52),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${cart.totalItems} items', style: TextStyle(color: Colors.brown)),
                          Text(currencyFormat.format(cart.totalPrice), style: TextStyle(color: Colors.brown)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route, {bool signOut = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.brown, width: 1),
        ),
        child: ListTile(
          leading: Icon(icon, color: Color.fromARGB(255, 123, 89, 52)),
          title: Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 123, 89, 52),
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            if (signOut) {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            } else {
              Navigator.pushNamed(context, route);
            }
          },
        ),
      ),
    );
  }
}

class MenuList extends StatefulWidget {
  final String category;

  MenuList({required this.category});

  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> with AutomaticKeepAliveClientMixin {
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure state persistence
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              fillColor: Colors.white,
              filled: true,
              prefixIcon: Icon(Icons.search, color: Colors.orange.shade300),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Color.fromARGB(150, 123, 89, 52), width: 1.5),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(widget.category).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              var items = snapshot.data!.docs.where((item) {
                return item['name'].toString().toLowerCase().contains(_searchText) ||
                    item['price'].toString().contains(_searchText);
              }).toList();

              int emptyCardsCount = (items.length % 2 == 0) ? 1 : 2;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: items.length + emptyCardsCount,
                itemBuilder: (context, index) {
                  if (index >= items.length) {
                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.all(8),
                      color: Color.fromARGB(255, 245, 213, 157),
                      child: Container(),
                    );
                  } else {
                    var item = items[index];
                    return MenuItemCard(item: item);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final QueryDocumentSnapshot item;
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context, listen: false);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(color: Color.fromARGB(255, 123, 89, 52), width: 1),
      ),
      color: const Color.fromARGB(255, 252, 252, 252),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: item['image'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()), // Show loading indicator
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  cacheKey: item.id, // Use item's id as cache key
                  cacheManager: CustomCacheManager(), // Use custom cache manager
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(item['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(currencyFormat.format(item['price']), style: TextStyle(fontSize: 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        cart.removeItem(item.id);
                      },
                    ),
                    Consumer<CartModel>(
                      builder: (context, cart, child) {
                        return Text(cart.getItemQuantity(item.id).toString());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        cart.addItem(item.id, item['name'], item['price'], item['image']);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
