class AppRoutes {
  static const String home = '/';
  static const String searchQuery = '/search';
  static const String about = '/about';
  static const String drawer = '/drawer';
  static const String shippingPolicy = '/shipping-policy';
  static const String deleteAddress = '/delete-address';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordMain = '/forgot-password-reset';
  static const String privacyPolicy = '/privacy-policy';
  static const String contactUs = '/contact-us';
  static const String catalog = '/catalog';
  static const String sale = '/sale';
  static const String checkOut = '/checkout';
  static const String viewCart = '/view-cart';
  static const String myAccount = '/my-account';
  static const String viewDetails = '/view-details';
  static const String myOrder = '/my-order';
  static const String wishlist = '/my-wishlist';
  static const String collection = '/catalog/Collections';
  static const String logIn = '/log-in';
  static const String signIn = '/sign-in';
  static const String addAddress = '/add-address';
  static const String paymentResult = '/payment-result'; // New route
  static const String addToCart = '/cart/:id';
  static String cartDetails(int id) => '/cart/$id'; // for navigation

  static const String productDetailsPath = '/product/:id'; // for GoRouter
  static String productDetails(int id) => '/product/$id'; // for navigation
  static const String catIdProductViewPath = '/category/:id'; // for GoRouter
  static String catIdProductView(int id) => '/category/$id'; // for navigation

  static const String idCollectionViewPath = '/collection/:id'; // for GoRouter
  static String idCollectionView(int id) => '/collection/$id'; // for navigation


}
