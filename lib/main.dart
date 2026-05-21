import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/product_provider.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تحميل المنتجات من Cache (للـ offline)
  final productProvider = ProductProvider();
  await productProvider.loadProductsFromCache();

  runApp(
    MyApp(productProvider: productProvider),
  );
}

class MyApp extends StatelessWidget {
  final ProductProvider productProvider;

  const MyApp({
    super.key,
    required this.productProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => productProvider),
      ],
      child: MaterialApp(
        title: 'Furniture E-Commerce',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF151515),
          primaryColor: const Color(0xFFEEEEEE),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFEEEEEE),
            secondary: Color(0xFFC73659),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFC73659)),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          // ✅ عند تسجيل الدخول: الاشتراك في المنتجات والمفضلة من Firestore
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final productProvider = Provider.of<ProductProvider>(context, listen: false);
            final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
            
            productProvider.subscribeToProducts();
            favoriteProvider.subscribeToFavorites();
            
            print('✅ User logged in, subscribed to Firestore streams');
          });
          
          return const MainScreen();
        }
        
        // ✅ عند تسجيل الخروج: إلغاء الاشتراك
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final productProvider = Provider.of<ProductProvider>(context, listen: false);
          final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
          
          productProvider.unsubscribeFromProducts();
          favoriteProvider.unsubscribeFromFavorites();
          
          print('✅ User logged out, unsubscribed from Firestore');
        });
        
        return const WelcomeScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const FavoriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF151515),
        selectedItemColor: const Color(0xFFEEEEEE),
        unselectedItemColor: const Color(0xFFC73659),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.favorite),
                if (favoriteProvider.favoriteCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFA91D3A),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        favoriteProvider.favoriteCount.toString(),
                        style: const TextStyle(
                          color: Color(0xFFEEEEEE),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                if (cartProvider.totalItems > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFA91D3A),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartProvider.totalItems.toString(),
                        style: const TextStyle(
                          color: Color(0xFFEEEEEE),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
