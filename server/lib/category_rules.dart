import 'store/json_store.dart';

final List<MapEntry<RegExp, String>> defaultCategoryRules = [
  // Grocery
  MapEntry(RegExp(r'TRADER JOE', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'WHOLE FOODS', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'SAFEWAY', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'KROGER', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'ALDI', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'PUBLIX', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'SPROUTS', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'H-E-B', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'WEGMANS', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'FOOD LION', caseSensitive: false), 'Grocery'),
  MapEntry(RegExp(r'PIGGLY WIGGLY', caseSensitive: false), 'Grocery'),

  // Superstore
  MapEntry(RegExp(r'WAL-?MART', caseSensitive: false), 'Superstore'),
  MapEntry(RegExp(r'SUPERCENTER', caseSensitive: false), 'Superstore'),
  MapEntry(RegExp(r'FRED-?MEYER', caseSensitive: false), 'Superstore'),
  MapEntry(RegExp(r'TARGET', caseSensitive: false), 'Superstore'),
  MapEntry(RegExp(r'COSTCO', caseSensitive: false), 'Superstore'),
  MapEntry(RegExp(r"SAM'?S CLUB", caseSensitive: false), 'Superstore'),

  // Restaurant / Dining
  MapEntry(RegExp(r'MCDONALD', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'COFFEE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'CAFE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'CHIPOTLE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'CHICK-FIL-A', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'DUNKIN', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'SUBWAY', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'PANERA', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'TACO BELL', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r"WENDY'?S", caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'BURGER KING', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'DOORDASH', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'UBER EATS', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'GRUBHUB', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'^TST\*', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'^SNACK\*', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'STARBUCKS', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'RAISING CANE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r"DAVE'?S?\s*HOT\s*CHICKEN", caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'PIZZA', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'TAQUERIA', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'SUSHI', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'\bTHAI\b', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'\bDELI\b', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'BAGEL', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'ICE CREAM', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'GELATO', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'NOODLE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'WAFFLE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'KITCHEN', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'BAR & GRILL', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'ROASTER', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'\bMATCHA\b', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'JAMBA JUICE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'\bBOBA\b', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'DONUT', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'ARAMARK', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'CHICKEN', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r"MONTY'?S RED SAUCE", caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'PHIN CAPH', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'FLEMINGS?\d', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'A DOPO', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'COOL BEANS', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'OLD CITY JAVA', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'WATCHHOUSE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'JIANG NAN', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'LA CABRA', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'VAN LEEUWEN', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r"VINNIE'?S", caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'LOS TACOS', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'OOH LALA', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'YUM TRA', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'CHICHA SAN CHEN', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'SUPER TASTE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'BRENZ', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'AROMA INDIAN', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'SQ \*REGULAR NYC', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'SQ \*NO PREFERENCE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'SQ \*JACKS\b', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'RUBYS EAST VILLAGE', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'LIBERTY BAGELS', caseSensitive: false), 'Dining'),
  MapEntry(RegExp(r'PIZZER', caseSensitive: false), 'Dining'),

  // Gas / Fuel
  MapEntry(RegExp(r'SHELL OIL', caseSensitive: false), 'Gas'),
  MapEntry(RegExp(r'CHEVRON', caseSensitive: false), 'Gas'),
  MapEntry(RegExp(r'EXXONMOBIL', caseSensitive: false), 'Gas'),
  MapEntry(RegExp(r'BP #', caseSensitive: false), 'Gas'),
  MapEntry(RegExp(r'CIRCLE K', caseSensitive: false), 'Gas'),
  MapEntry(RegExp(r'WAWA', caseSensitive: false), 'Gas'),
  MapEntry(RegExp(r'SPEEDWAY', caseSensitive: false), 'Gas'),
  MapEntry(RegExp(r'7-ELEVEN', caseSensitive: false), 'Gas'),
  MapEntry(RegExp(r'BUC-?EE', caseSensitive: false), 'Gas'),

  // Rideshare / Transit
  MapEntry(RegExp(r'UBER(?! EATS)', caseSensitive: false), 'Transit'),
  MapEntry(RegExp(r'LYFT', caseSensitive: false), 'Transit'),
  MapEntry(RegExp(r'PARKING', caseSensitive: false), 'Transit'),

  // Subscriptions / Streaming
  MapEntry(RegExp(r'NETFLIX', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'GYM', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'SPOTIFY', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'HULU', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'DISNEY\+', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'APPLE\.COM', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'AMAZON PRIME', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'HBO MAX', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'YOUTUBE PREMIUM', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'CLAUDE\.AI', caseSensitive: false), 'Subscription'),
  MapEntry(RegExp(r'WMT PLUS', caseSensitive: false), 'Subscription'),

  // Shopping
  MapEntry(RegExp(r'AMAZON\.COM', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'AMZN', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'BEST BUY', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'HOME DEPOT', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r"LOWE'?S", caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'IKEA', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'VOLSHOP', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'GOODWILL', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'OFFICE DEPOT', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'NORDSTROM', caseSensitive: false), 'Shopping'),
  MapEntry(RegExp(r'SAMS PARTY', caseSensitive: false), 'Shopping'),

  // Utilities
  MapEntry(RegExp(r'COMCAST', caseSensitive: false), 'Utilities'),
  MapEntry(RegExp(r'XFINITY', caseSensitive: false), 'Utilities'),
  MapEntry(RegExp(r'AT&?T', caseSensitive: false), 'Utilities'),
  MapEntry(RegExp(r'VERIZON', caseSensitive: false), 'Utilities'),
  MapEntry(RegExp(r'T-MOBILE', caseSensitive: false), 'Utilities'),
  MapEntry(RegExp(r'ELECTRIC', caseSensitive: false), 'Utilities'),
  MapEntry(RegExp(r'WATER BILL', caseSensitive: false), 'Utilities'),
  MapEntry(RegExp(r'GAS BILL', caseSensitive: false), 'Utilities'),

  // Medical
  MapEntry(RegExp(r'CVS', caseSensitive: false), 'Medical'),
  MapEntry(RegExp(r'WALGREENS', caseSensitive: false), 'Medical'),
  MapEntry(RegExp(r'PHARMACY', caseSensitive: false), 'Medical'),
  MapEntry(RegExp(r'DOCTOR', caseSensitive: false), 'Medical'),
  MapEntry(RegExp(r'DENTIST', caseSensitive: false), 'Medical'),
  MapEntry(RegExp(r'HOSPITAL', caseSensitive: false), 'Medical'),
  MapEntry(RegExp(r'URGENT CARE', caseSensitive: false), 'Medical'),
  MapEntry(RegExp(r'OPTOMETRY', caseSensitive: false), 'Medical'),

  // Loan Payments
  MapEntry(RegExp(r'LOAN PAYMENT', caseSensitive: false), 'Loan'),
  MapEntry(RegExp(r'MORTGAGE', caseSensitive: false), 'Loan'),
  MapEntry(RegExp(r'AUTO LOAN', caseSensitive: false), 'Loan'),
  MapEntry(RegExp(r'STUDENT LOAN', caseSensitive: false), 'Loan'),

  // Travel
  MapEntry(RegExp(r'AIRLINE', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'DELTA AIR', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'UNITED AIR', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'SOUTHWEST', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'AIRBNB', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'HOTEL', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'MARRIOTT', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'HILTON', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'AMERICAN 00\d', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'ALLEGIANT|ALLEGNT', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'\bAA KIOSK', caseSensitive: false), 'Travel'),
  MapEntry(RegExp(r'HOMEWOOD SUITES', caseSensitive: false), 'Travel'),

  // Transfer / Payment
  MapEntry(RegExp(r'VENMO', caseSensitive: false), 'Transfer'),
  MapEntry(RegExp(r'ONLINE ACH PAYMENT', caseSensitive: false), 'Transfer'),
  MapEntry(RegExp(r'REWARD', caseSensitive: false), 'Transfer'),
  MapEntry(RegExp(r'PYMT', caseSensitive: false), 'Transfer'),
  MapEntry(RegExp(r'ZELLE', caseSensitive: false), 'Transfer'),
  MapEntry(RegExp(r'PAYPAL', caseSensitive: false), 'Transfer'),
  MapEntry(RegExp(r'CASH APP', caseSensitive: false), 'Transfer'),

  // Entertainment
  MapEntry(RegExp(r'TEBEX', caseSensitive: false), 'Entertainment'),
  MapEntry(RegExp(r'MODERN WARRIORS', caseSensitive: false), 'Entertainment'),
  MapEntry(RegExp(r'CLIMBING', caseSensitive: false), 'Entertainment'),
  MapEntry(RegExp(r'PORTLANDROCK', caseSensitive: false), 'Entertainment'),
  MapEntry(RegExp(r'MUSEUM', caseSensitive: false), 'Entertainment'),
  MapEntry(RegExp(r'UTKATHLETICS', caseSensitive: false), 'Entertainment'),

  // Rent / Housing
  MapEntry(RegExp(r'BILT.*RENT', caseSensitive: false), 'Rent'),
  MapEntry(RegExp(r'BILTPROTECT', caseSensitive: false), 'Rent'),

  // Fees
  MapEntry(RegExp(r'LATE FEE', caseSensitive: false), 'Fee'),
];

// Combine default rules with user-defined rules from persistent storage
List<MapEntry<RegExp, String>> getCategoryRules() {
  final userRules = loadCategoryRules();
  final userEntries = userRules.map((r) => MapEntry(r.toRegExp(), r.category)).toList();
  // User rules take precedence by coming first
  return [...userEntries, ...defaultCategoryRules];
}

// For backward compatibility, expose as categoryRules
List<MapEntry<RegExp, String>> get categoryRules => getCategoryRules();
