class ApiEndpoints {
  // Base URL configuration (Default to local/emulator environment)
  static String baseUrl = 'http://192.168.18.3:8000/api';

  // Auth Endpoints
  static const String login = '/auth/login/';
  static const String refresh = '/auth/refresh/';
  static const String me = '/auth/me/';

  // Dashboard Endpoints
  static const String dashboard = '/dashboard/';

  // Product Endpoints
  static const String products = '/products/';
  static String productDetail(int id) => '/products/$id/';
  static String productDeactivate(int id) => '/products/$id/deactivate/';

  // Category Endpoints
  static const String categories = '/categories/';
  static String categoryDetail(int id) => '/categories/$id/';

  // Inventory Endpoints
  static const String inventory = '/inventory/';
  static const String inventoryMovements = '/inventory/movements/';
  static const String stockAdjustments = '/inventory/adjustments/';

  // Sales Endpoints
  static const String sales = '/sales/';
  static String saleDetail(int id) => '/sales/$id/';
  static String saleVoid(int id) => '/sales/$id/void/';

  // Customer Endpoints
  static const String customers = '/customers/';
  static String customerDetail(int id) => '/customers/$id/';

  // Payment Method Endpoints
  static const String paymentMethods = '/payment-methods/';
  static String paymentMethodDetail(int id) => '/payment-methods/$id/';

  // User Endpoints
  static const String users = '/users/';
  static String userDetail(int id) => '/users/$id/';

  // Settings Endpoints
  static const String settings = '/settings/';
}
