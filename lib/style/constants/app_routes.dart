/// Routes nommées de l'application
class AppRoutes {
  AppRoutes._();

  static const String home            = '/';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String boutique        = '/boutique';
  static const String productDetail   = '/product-detail';
  static const String cart            = '/cart';
  static const String orders          = '/orders';
  static const String profile         = '/profile';
  static const String about           = '/about';
  static const String contact         = '/contact';
  static const String cgv             = '/cgv';
  static const String cgu             = '/cgu';

  // Vendeur
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerProducts  = '/seller/products';
  static const String sellerOrders    = '/seller/orders';

  // Admin
  static const String adminDashboard  = '/admin/dashboard';
  static const String adminUsers      = '/admin/users';
  static const String adminProducts   = '/admin/products';
  static const String adminOrders     = '/admin/orders';
}