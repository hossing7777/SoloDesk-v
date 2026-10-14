/// Free-tier limits (enforced before every insert).
const int kFreeClients = 5;
const int kFreeInvoices = 5;

/// Replace with your own Gumroad product URL.
const String kGumroadUrl = 'https://gumroad.com/l/solodesk';

/// Currencies offered in Settings (ISO 4217 codes).
const List<String> kCurrencies = [
  'USD', 'EUR', 'GBP', 'AED', 'INR', 'CNY', 'RUB', 'BRL', 'CAD', 'IRR',
];

/// Inline vector art used on the landing screen (rendered by flutter_svg).
const String kHeroSvg = '''
<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="18" width="100" height="84" rx="14" fill="#4F46E5"/>
  <rect x="26" y="40" width="68" height="8" rx="4" fill="#FFFFFF"/>
  <rect x="26" y="58" width="48" height="8" rx="4" fill="#C7D2FE"/>
  <circle cx="88" cy="82" r="11" fill="#FFFFFF"/>
</svg>
''';
