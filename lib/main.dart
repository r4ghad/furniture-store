import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/cart_repository.dart';
import 'repositories/theme_repository.dart';
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

  // Initialize SQLite database for shopping cart
  final cartRepository = CartRepository();
  await cartRepository.initDb();

  // Initialize Theme preference
  final themeRepository = ThemeRepository();
  final initialThemeMode = await themeRepository.loadThemeMode();

  // تحميل المنتجات من Cache (للـ offline)
  final productProvider = ProductProvider();
  await productProvider.loadProductsFromCache();

  runApp(
    MyApp(
      productProvider: productProvider,
      cartRepository: cartRepository,
      themeRepository: themeRepository,
      initialThemeMode: initialThemeMode,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ProductProvider productProvider;
  final CartRepository cartRepository;
  final ThemeRepository themeRepository;
  final String initialThemeMode;

  const MyApp({
    super.key,
    required this.productProvider,
    required this.cartRepository,
    required this.themeRepository,
    required this.initialThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(themeRepository, initialMode: initialThemeMode)),
        ChangeNotifierProvider(create: (_) => CartProvider(cartRepository)),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => productProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Furniture E-Commerce',
            themeMode: themeProvider.themeMode,
            // Premium Day Theme (Light Theme) matching the app identity
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F0EB), // warm off-white background
              primaryColor: const Color(0xFF151515), // charcoal text
              cardColor: Colors.white,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF151515),
                secondary: Color(0xFFC73659), // branded crimson
                surface: Colors.white,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF5F0EB),
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF151515)),
                titleTextStyle: TextStyle(
                  color: Color(0xFF151515),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF151515),
                unselectedItemColor: Color(0xFFC73659),
              ),
            ),
            // Premium Night Theme (Dark Theme)
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF151515),
              primaryColor: const Color(0xFFEEEEEE),
              cardColor: const Color(0xFF1E1E1E),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFEEEEEE),
                secondary: Color(0xFFC73659),
                surface: Color(0xFF151515),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF151515),
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFFEEEEEE)),
                titleTextStyle: TextStyle(
                  color: Color(0xFFEEEEEE),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF151515),
                selectedItemColor: Color(0xFFEEEEEE),
                unselectedItemColor: Color(0xFFC73659),
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: const AuthGate(),
          );
        },
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
            final cartProvider = Provider.of<CartProvider>(context, listen: false);
            
            productProvider.subscribeToProducts();
            favoriteProvider.subscribeToFavorites();
            cartProvider.loadCartForUser(user.uid);
            
            print('✅ User logged in, subscribed to Firestore streams & loaded SQLite cart');
          });
          
          return const MainScreen();
        }
        
        // ✅ عند تسجيل الخروج: إلغاء الاشتراك
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final productProvider = Provider.of<ProductProvider>(context, listen: false);
          final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          
          productProvider.unsubscribeFromProducts();
          favoriteProvider.unsubscribeFromFavorites();
          cartProvider.clearCartOnLogout();
          
          print('✅ User logged out, unsubscribed from Firestore & cleared SQLite cart');
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
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
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
