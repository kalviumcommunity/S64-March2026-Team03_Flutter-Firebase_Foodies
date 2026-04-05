import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _productsCollection = 'products';

  /// Fetch a real-time stream of all products.
  Stream<List<Product>> getProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc.id, doc.data())).toList();
    });
  }

  /// Optional: Seed some initial product data to Firestore if none exists.
  /// Helpful for demonstration since this is a new collection.
  Future<void> seedInitialProducts() async {
    QuerySnapshot existing = await _db.collection(_productsCollection).limit(1).get();
    if (existing.docs.isEmpty) {
      List<Map<String, dynamic>> products = [
        {
          'name': 'Almarai Orange Juice 100% Pure',
          'quantity': '1L',
          'price': 300.00,
          'category': 'Grocery',
          'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=300',
          'description': 'Pure and healthy orange juice with no added sugar.',
          'stock': 50,
        },
        {
          'name': 'Strawberry Flavour Milk',
          'quantity': '200ML',
          'price': 75.00,
          'category': 'Dairy',
          'image': 'https://images.unsplash.com/photo-1563636619-e9143ef3082a?w=300',
          'description': 'Creamy milk infused with natural strawberry flavor.',
          'stock': 100,
        },
        {
          'name': 'Organic Brown Bread Slice',
          'quantity': '400g',
          'price': 60.00,
          'category': 'Bakery',
          'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300',
          'description': 'Whole grain brown bread for a healthy breakfast.',
          'stock': 30,
        },
        {
          'name': 'Fresh Organic Bananas',
          'quantity': '1 Dozen',
          'price': 80.00,
          'category': 'Grocery',
          'image': 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=300',
          'description': 'Naturally sweetened organic bananas from local farms.',
          'stock': 20,
        },
      ];

      for (var prod in products) {
        await _db.collection(_productsCollection).add(prod);
      }
    }
  }
}
