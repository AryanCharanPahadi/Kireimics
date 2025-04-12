class AppRoutes {
  static const String home = '/';
  static const String about = '/about';
  static const String shippingPolicy = '/shipping-policy';
  static const String privacyPolicy = '/privacy-policy';
  static const String contactUs = '/contact-us';
  static const String catalog = '/catalog';
  static const String sale = '/sale';
  static const String checkOut = '/checkout';
  static const String myAccount = '/my-account';
  static const String myOrder = '/my-order';
  static const String wishlist = '/my-wishlist';
  static const String collection = '/catalog/Collections';
  static const String logIn = '/log-in';
  static const String signIn = '/sign-in';
  static const String addAddress = '/add-address';
  static const String addToCart = '/cart/:id';
  static String cartDetails(int id) => '/cart/$id'; // for navigation

  static const String productDetailsPath = '/product/:id'; // for GoRouter
  static String productDetails(int id) => '/product/$id'; // for navigation
}
