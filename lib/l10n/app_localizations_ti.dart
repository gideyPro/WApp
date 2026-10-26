// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tigrinya (`ti`).
class AppLocalizationsTi extends AppLocalizations {
  AppLocalizationsTi([String locale = 'ti']) : super(locale);

  @override
  String get commonUser => 'ተጠቃሚ';

  @override
  String get commonNA => 'የለን';

  @override
  String get commonAppInitials => 'ዌማ';

  @override
  String get commonYou => 'ንስኹም';

  @override
  String get commonNow => 'ሕጂ';

  @override
  String get commonOk => 'እሺ';

  @override
  String get commonCancel => 'ይትረፍ';

  @override
  String get commonDelete => 'ኣጥፍኡ';

  @override
  String get commonEdit => 'ኣመዓራርዩ';

  @override
  String get commonRetry => 'ደጊምኩም ፈትኑ';

  @override
  String get commonError => 'ፀገም';

  @override
  String get commonNo => 'ኣይ';

  @override
  String get commonYes => 'እወ';

  @override
  String get commonContinue => 'ይቐፅሉ';

  @override
  String get commonRetryMessage => 'በጃኹም ደጊምኩም ፈትኑ';

  @override
  String get commonPressBackAgain => 'ንምውፃእ ደጊምኩም ፅቐጡ';

  @override
  String get commonOptional => 'ኣማራጺ';

  @override
  String get commonSave => 'ዓቕቡ';

  @override
  String get navHome => 'መበገሲ';

  @override
  String get navOrders => 'ትእዛዛት';

  @override
  String get navMessages => 'መልእኽታት';

  @override
  String get navSettings => 'ናተይ ኣካውንት';

  @override
  String get homeLatestRecently => 'ኣብ ቀረባ ዝወፁ';

  @override
  String get homeVipTitle => 'ፕሪሚየም VIP ዝርዝራት';

  @override
  String get homeViewAll => 'ኹሉ ርኣዩ';

  @override
  String get vipTeaserCta => 'VIP ምልክታታት ክፈቱ';

  @override
  String get vipNoListings => 'VIP ዝርዝር የለን';

  @override
  String get vipBadge => 'VIP';

  @override
  String get profileMyListings => 'ናተይ ንብረታት';

  @override
  String get myListingsEmptySubtitle => 'ንምጅማር ናይ መጀመሪያ ንብረትኩም ወስኹ';

  @override
  String noStatusListings(Object status) {
    return 'ዝተረኽበ $status ንብረት የለን';
  }

  @override
  String get profileFavorites => 'ዝተመረፁ';

  @override
  String get profilePayments => 'ዝርዝር ክፍሊት';

  @override
  String get profileKyc => 'መረጋገፂ መንነት (KYC)';

  @override
  String get profileSubscriptions => 'ናይ ኣባልነት ፓኬጅ';

  @override
  String get profileHelp => 'ማእኸል ሓገዝ';

  @override
  String get helpSearchHint => 'ኣብዚ ድለዩ...';

  @override
  String get helpNoResultsTitle => 'ዝተረኽበ የለን';

  @override
  String get helpNoResultsSubtitle => 'ካልእ ቃል ይሞክሩ...';

  @override
  String get helpStillNeedHelp => 'ተወሳኺ ሓገዝ ትደልዩ ዲኹም?';

  @override
  String get helpSupportTeam => 'ጉጅለ ሓገዝና ንዓኹም ንምሕጋዝ ድሉው እዩ።';

  @override
  String get helpEmail => 'ኢሜይል';

  @override
  String get helpCall => 'ደውሉ';

  @override
  String get helpErrorEmail => 'ናይ ኢሜይል መተግበሪ ክኽፈት ኣይተኻእለን';

  @override
  String get helpErrorPhone => 'ናይ ስልኪ መተግበሪ ክኽፈት ኣይተኻእለን';

  @override
  String get helpYoutubeSub => 'መምርሕታት፣ ጠቓሚ ሓበሬታታትን ናይ ቪዲዮ ዳህሳሳትን ርኣዩ';

  @override
  String get helpYoutubeSubscribe => 'ሰብስክራይብ ግበሩ';

  @override
  String get helpCategoryAccount => 'ኣካውንትን ፕሮፋይልን';

  @override
  String get helpCategoryListings => 'ንብረታት';

  @override
  String get helpCategoryOrders => 'ፍሉይ ትእዛዛትን ሕቶታትን';

  @override
  String get helpCategoryPayments => 'ክፍሊታትን ምዝገባታትን';

  @override
  String get helpCategoryKyc => 'ምርግጋፅ መንነት (KYC)';

  @override
  String get helpCategorySafety => 'ድሕንነትን ደንብታትን';

  @override
  String get helpAccCreateTitle => 'ኣካውንት ከመይ ይኽፈትን ይዳሎን';

  @override
  String get helpAccCreateContent =>
      'ኣብ ዌቭማርት ሓዱሽ ኣካውንት ንምኽፋት:\n\n1. ነቲ መተግበሪ ይኽፈቱ እሞ \"ተመዝገብ\" ወይ \"እቶ\" ዝብል ጠውቑ\n2. ምሉእ ስምኩም፣ ቑፅሪ ስልክኹምን ድልዱል መሕለፊ ቃልን (password) ኣእትዉ\n3. ናይ 6 ኣሃዝ መረጋገፂ ኮድ (OTP) ብኤስኤምኤስ ብቕልጡፍ ክስደደልኩም እዩ\n4. ስልክኹም ኣረጋጊፅኩም ኣካውንትኩም ንምንቃሕ ነቲ ኮድ ኣእትዉ\n\nምስ ተመዝገብኩም ኣባይቲ፣ መካይን ከምኡ እውን ናይ ስራሕ ዕድላት ክትድህስሱ፣ ዝመረፅኩምዎም ክትዕቅቡ፣ ናይ ሸየጥቲ ርክብ ዝርዝር ክትርእዩ ወይ ናይ ባዕልኹም ንብረታትን ናይ ስራሕ ምልክታታትን ክትዝርግሑ ትኽእሉ ኢኹም።';

  @override
  String get helpAccFavTitle => 'ዝተመረፁ ንብረታትን ምልክታታትን ምምሕዳር';

  @override
  String get helpAccFavContent =>
      'ዘገድሱኹም ንብረታትን ምልክታታትን ብቐሊሉ ንምክትታል:\n\n1. ኣብ ዝኾነ ናይ ገዛ፣ መኪና ወይ ስራሕ ምልክታ ዘሎ ምልክት ልቢ ብምጥዋቕ ዓቅብዎ\n2. ዝተዓቀቡ ንብረታትኩም ኣብ ዝኾነ እዋን ካብ ኣካውንት > ዝተመረፁ ርኸብዎም\n3. ናይ ዋጋ ምንካይ እንተተገይሩ፣ እቲ ንብረት እንተተሸይጡ/ተኻርዩ ወይ ናይቲ ስራሕ ዕድል እንተተዓፅዩ ኵነታቱ ብቐጥታ ይሕደስ\n4. ንብረት ካብ ዝተመረፁ ንምውፃእ ነቲ ምልክት ልቢ ደጊምኩም ጠውቑ\n\nምልክታታት መሪፅካ ምዕቃብ ዋጋታት ንምንፅፃርን ደጊምካ ከይደለኻ ብቕልጡፍ ንምርካብን ይሕግዘኩም።';

  @override
  String get helpAccMsgTitle => 'ኣብ ውሽጢ መተግበሪ ዝርርብን ቁፅሪ ስልኪ ምርኣይን';

  @override
  String get helpAccMsgContent =>
      'ዌቭማርት ምስ ሸየጥቲ፣ ኣስራሕትን ወከልትን እትራኸቡሎም ቀጥተኛ መንገዲታት የቕርብ:\n\n1. ናይ መተግበሪ ውሽጢ ዝርርብ: ቑፅሪ ስልክኹም ከየካፈልኩም ቅልጡፍን ውሑስን ዝርርብ ንምጅማር ኣብቲ ዝርዝር ዘሎ \"ዝርርብ\" ዝብል ጠውቑ\n2. ኵነታት መልእኽቲ: ሓደ ምልክት ቼክ መልእኽቲ ምልኣኹ የርኢ፤ ክልተ ምልክት ቼክ ድማ ምብፅሑን ምንባቡን የመልክት\n3. ቁፅሪ ስልኪ ሸያጢ ምርኣይ: ናይቲ ሸያጢ ወይ ኣስራሒ ዝተረጋገፀ ቑፅሪ ስልኪ ንምርኣይ \"ርክብ ኣርኢ\" ወይ \"ደውሉ\" ዝብል ጠውቑ (ካብ ናይ ኣባልነት ኮታኹም 1 ምርኣይ ይጥቀም)\n4. ኣርእስቲ ዝርርብ: ኣብቲ ናይ ዝርርብ ርእሲ እቲ ዝርርብ ብዛዕባ ኣየናይ ገዛ፣ መኪና ወይ ስራሕ ምዃኑ ብቐሊሉ ምርኣይ ይከኣል\n\nንድሕንነትኩም ዝርርባትን ስምምዓትን ኩሉ ግዜ ኣብ ውሽጢ መተግበሪ ዌቭማርት ጥራሕ ግበርዎም።';

  @override
  String get helpListCreateTitle =>
      'ኣባይቲ፣ መካይን ከምኡ እውን ናይ ስራሕ ምልክታታት ከመይ ይዝርጋሕ';

  @override
  String get helpListCreateContent =>
      'ኣብ ዌቭማርት ንብረት ወይ ምልክታ ምዝርጋሕ ቀሊልን ብደረጃ ዝምራሕን እዩ:\n\n1. ኣብቲ ናይ ታሕቲ ዳሰሳ ማእኸል ዘሎ ምልክት \"+\" ጠውቑ\n2. እተሳትፍዎ ዘፈር ምረፁ: ቤት ወይ ንብረት (ገዛ/ኣፓርታማ/ንግዲ ቤት/መሬት ንመሸጣ ወይ ንክራይ)፣ ተሽከርካሪ (መኪና/ናይ ፅዕነት መኪና/ሞተርሳይክል/ማሽነሪ ንመሸጣ ወይ ንክራይ)፣ ወይ ክፍቲ ናይ ስራሕ ቦታ\n3. ዘድልዩ ዝርዝራት ምልኡ (ዋጋ፣ ስፍሓት፣ ዝተጓዓዞ ኪሎሜትር፣ ዓይነት ማርሽ፣ ዓይነት ነዳዲ፣ ዓይነት ቆፀራ፣ ደረጃ ትምህርትን ትኽክለኛ ቦታን)\n4. ፅሬት ዘለዎም ፎቶታትን ሰነዳትን (ከም ሳይት ፕላን ወይ ናይ መኪና መረዳእታታትን) ኣተሓሕዙ\n5. ሓበሬታኹም መርሚርኩም \"ኣእትዉ\" ዝብል ጠውቑ\n\nትኽክለኛነቶምን ፅሬቶምን ተረጋጊፁ ንህዝቢ ምርኣይ ቅድሚ ምጅማሩ ኩሎም ምልክታታት ብጉጅለ ግምገማና ኣብ ውሽጢ 24 ሰዓታት ይምርመሩ።';

  @override
  String get helpListManageTitle => 'ምልክታታት ምምሕዳር፣ ምምሕያሽን ምሕዳስን';

  @override
  String get helpListManageContent =>
      'ኣብ ዘውፃእኹምዎም ንብረታትን ምልክታታትን ምሉእ ቁፅፅር ኣለኩም:\n\n1. ዘውፃእኹምዎም ኣባይቲ፣ መካይንን ክፍቲ ናይ ስራሕ ቦታታትን ንምርኣይ ናብ ኣካውንት > ናተይ ንብረታት ኺዱ\n2. ኵነታት ምልክታታት ተኸታተሉ: ኣብ ግምገማ ዘሎ፣ ንጡፍ፣ ዝተሸጠ፣ ዝተኻረየ፣ ዝተተሓዘ ወይ ዝተነፀገ\n3. ንምምሕዳር ኣብ ዝኾነ ምልክታ ጠውቑ: ሓበሬታ ንምዕራይ፣ ዋጋ ንምቕያር፣ ወይ ከም ዝተሸጠ/ዝተዓፀወ ምልክት ንምግባር\n4. ምርኣይ ምዕባይ: ካብ መመሓደሪ እቲ ምልክታ ብቐጥታ \"ፍሉይ ምልክታ\" ወይ \"VIP\" ምምሕያሻት ግበሩ\n5. ምስራዝ ወይ ምዕጻው: ድሕሪ ሕጂ ዘየለዉ ንብረታት ምሉእ ብምሉእ ሰርዙ ወይ ንግዚኡ ደብቑ\n\nመተሓሳሰቢ: መሰረታዊ ሓበሬታታት (ከም ኣድራሻ ወይ ዋና ኣርእስቲ) ምቕያር ብጉጅለ ግምገማና ቅልጡፍ ዳግመ-ምርመራ ክሓትት ይኽእል እዩ።';

  @override
  String get helpListTipsTitle => 'ዕዉትን ቅልጡፍ ዓዳጊ ዝስሕብን ምልክታ ንምውፃእ ዝሕግዙ ነጥብታት';

  @override
  String get helpListTipsContent =>
      'ናይ ሓቂ ዓደግቲ፣ ተኻረይትን ብቑዓት ኣመልከትን ብቕልጡፍ ንምስሓብ ነዞም ዝስዕቡ ነጥብታት ተኸተሉ:\n\n1. ፅሬት ዘለዎም ፎቶታት: ኩሎም ክፍሊታት፣ ናይ ውሽጥን ደገን ገፅታ ዘርእዩ ብውሑዱ 5 ብሩህ ዝኾኑ ፅሩያት ፎቶታት ኣእትዉ\n2. ንፁር ዋጋ: ሚዛናውን ምስ ናይ ሕጂ ዕዳጋ ዝኸይድን ዋጋ ኣቐምጡ። እቲ ዋጋ ዝደራደር ምዃኑን ዘይምዃኑን ብንፁር ግለፁ\n3. ዝርዝር ሓበሬታ: ንቤት ናይቲ ቦታ ስፍሓት፣ ማይን መብራህትን ከምኡ እውን ፍሉጣት መለለዪ ቦታታት ግለፁ። ንመካይን ድማ ትኽክለኛ ናይ ሞዴል ዓመት፣ ዝተጓዓዞ ኪሎሜትር፣ ዓይነት ማርሽ፣ ዓይነት ነዳዲን ኵነታት እታ መኪናን ሓብሩ\n4. ንፁር መግለፂ ስራሕ: ንናይ ስራሕ ምልክታታት መጠን መሃያ፣ ሰዓታት ስራሕ፣ ዝድለ ደረጃ ትምህርትን ልምዲ ስራሕን ብንፁር ኣቐምጡ\n5. ቅልጡፍ ምላሽ: ኣብ ውሽጢ እቲ መተግበሪ ንዝለኣኹ መልእኽትታት ብቕልጡፍ ምላሽ ሃቡ። ቅልጡፍ ምላሽ ምትእምማን ይፈጥር፣ ንዕዳጋ ድማ የሳልጥ።';

  @override
  String get helpListVideoTitle => 'ናይ ቪዲዮ ዑደትን ዳህሳስን';

  @override
  String get helpListVideoContent =>
      'ናይ ቪዲዮ ዑደት ዓደግትን ተኻረይትን ብኣካል ቅድሚ ምኻዶም ብዛዕባ እቲ ንብረት ናይ ሓቂን ምሉእን ግንዛበ ንኽረኽቡ ይሕግዝ:\n\n1. ቪዲዮ ምትሕሓዝ: ገዛ ወይ መኪና እንተመዝግቡ ወይ እንተተመዓራርዩ ሓፂር ናይ ቪዲዮ ዑደት (ክሳብ 60 ካልኢት) ኣተሓሕዙ\n2. ምድላው ቪዲዮ: ናይ ቪዲዮ ሲስተምና ኣብ ዝኾነ ናይ ሞባይል ኢንተርኔት ብዘይ ምቁራፅ ንኽሰርሕ ነቲ ቪዲዮ ብፅሬት የዳልዎ\n3. ኵነታት ምድላው: እቲ ቪዲዮ ኣብ ምድላው እንተሃልዩ ናይ ምድላው ምልክት ይርአ፤ ምስ ተዛዘመ እቲ ቪዲዮ ብቐጥታ ንተዓዘብቲ ይቐርብ\n4. ዝለዓለ ተደላይነት: ናይ ሓቂ ናይ ቪዲዮ ዳህሳስ ዘለዎም ንብረታት ብዓደግቲ ዝለዓለ ተቐባልነትን ምትእምማንን ይረኽቡ\n\nናይ ቪዲዮ ዳህሳሳት ኣብ ዝኾነ ስሩዕ ናይ ሞባይል ዳታ ብዘይ ፀገም ብቐሊሉ ክርኣዩ ይኽእሉ።';

  @override
  String get helpListInterestTitle => 'ኣብ ንብረታት ድሌት ምግላፅን ምስ ሸየጥቲ ምርኻብን';

  @override
  String get helpListInterestContent =>
      'ምስ ዝተረጋገፁ ሸየጥቲ፣ ኣካረይትን ኣስራሕትን ብቐሊሉ ተራኸቡ:\n\n1. ዝደለኹምዎ ገዛ፣ መኪና ወይ ናይ ስራሕ ምልክታ ክፈቱ\n2. ቑፅሪ ስልኪ ምርኣይ: ነቲ ዝተረጋገፀ ቑፅሪ ስልኪ ብቐጥታ ርኢኹም ንምድዋል \"ርክብ ኣርኢ\" ዝብል ጠውቑ። ነፍሲ ወከፍ ምርኣይ ካብ ናይ ኣባልነት ኮታኹም 1 ምርኣይ ይጥቀም\n3. ናይ መተግበሪ ዝርርብ: ሕቶታት ንምሕታት፣ ተወሳኺ ሓበሬታ ንምርካብ ወይ ንምርድዳእ \"ዝርርብ\" ዝብል ጠውቑ\n4. ምምልካት ስራሕ: ንናይ ስራሕ ምልክታታት \"ኣመልክት\" ብምጥዋቕ ወይ ብቐጥታ ነቲ ኣስራሒ መልእኽቲ ብምስዳድ ኣመልክቱ\n5. ድሌታተይ: ዘዘራረብኩምዎም ሸየጥትን ናይ ድሌት ታሪኽኩምን ካብ ኣካውንት > ድሌታተይ ኣብ ዝኾነ እዋን ክትርእዩ ትኽእሉ ኢኹም\n\nናይ ሸያጢ ቑፅሪ ስልኪ ብቐጥታ ንምርኣይ ዝተረፈ ናይ ወርሒ ኮታ ዘለዎ ንጡፍ ናይ ኣባልነት ፓኬጅ የድሊ።';

  @override
  String get helpListStatusTitle => 'ኵነታትን ደረጃታትን ምልክታታት';

  @override
  String get helpListStatusContent =>
      'ኣብ ዌቭማርት ዝዝርጋሕ ነፍሲ ወከፍ ምልክታ ነዞም ዝስዕቡ ደረጃታት ይሓልፍ:\n\n- ኣብ ግምገማ ዘሎ (Pending): ዘእተኹምዎ ሓበሬታን ፎቶን ብጉጅለ ግምገማና ይምርመር ኣሎ (መብዛሕትኡ ግዜ ኣብ ውሽጢ 24 ሰዓታት)\n- ንጡፍ (Active): ምልክታኹም ፀዲቑ ኣብ መላእ ኢትዮጵያ ንዘለዉ ተጠቀምቲ ኣብ ፍለጋን መበገሲ ገፅን ይርአ ኣሎ\n- ፍሉይ ምልክታ / VIP: ምልክታኹም ፍሉይ ባጅ ረኺቡ ኣብ መበገሲ ገፅን ኣብ ላዕሊ ፍለጋን ጎሊሁ ይርአ\n- ዝተሸጠ / ዝተኻረየ / ዝተተሓዘ: እቲ ንብረት ተሸይጡ፣ ተኻርዩ ወይ ናይቲ ስራሕ ቦታ ተታሒዙ እዩ\n- ዝተነፀገ (Rejected): እቲ ምልክታ መምርሒታት ኣየማልአን (ንኣብነት ድግግሞሽ ምልክታ፣ ዘይተማልአ ሓበሬታ ወይ ዘይንፁር ፎቶ)። ነቲ ዝተውሃበ መብርሂ ኣንቢብኩም ኣመዓራሪኹም ደጊምኩም ኣእትዉ\n- ዝተኣገደ / ዝቖመ (Frozen): ብዋንኡ ወይ ብኣመሓዳሪ ንግዚኡ ከይርአ ዝተገበረ\n\nኵነታት ኩሎም ምልክታታትኩም ኣብ ዝኾነ እዋን ካብ ኣካውንት > ናተይ ንብረታት ክትርእዩ ትኽእሉ ኢኹም።';

  @override
  String get helpOrdCreateTitle => 'ፍሉይ ሕቶታት ንብረት፣ ተሽከርካሪን ናይ ስራሕ ሓይልን';

  @override
  String get helpOrdCreateContent =>
      'ዝደለኹምዎ ዓይነት ገዛ፣ መኪና ወይ ሰራሕተኛ ክትረኽቡ እንተዘይክኢልኩም ፍሉይ ሕቶ (ትእዛዝ) ክትፈጥሩ ትኽእሉ ኢኹም:\n\n1. ናብ ክፍሊ \"ትእዛዛት\" ኺዱ እሞ \"ትእዛዝ ፍጠር\" ዝብል ጠውቑ\n2. እትደልይዎ ዘፈር ምረፁ: ቤት ወይ ንብረት (ንምግዛእ ወይ ንምክራይ)፣ ተሽከርካሪ (ዓይነት መኪና፣ ሞዴል፣ መጠን ዋጋ)፣ ወይ ዘድልየኩም ዓይነት ሰራሕተኛ\n3. በጀትኩም፣ ዝመረፅኩምዎ ከባቢን ዝርዝር ድሌታትኩምን ግለፁ\n4. ሕቶኹም ኣእትዉ፤ መተሓባበርትናን ሲስተምናን ዝሰማማዕ ንብረት ምድላይ ይጅምሩ\n\nምስ ድሌትኩም ዝሰማማዕ ንብረት ወይ ሰራሕተኛ ምስ ተረኽበ ብቕልጡፍ ሓበሬታ ክበፅሓኩም እዩ።';

  @override
  String get helpOrdManageTitle => 'ጥቆማታትን ምላሻትን ትእዛዝ ምምሕዳር';

  @override
  String get helpOrdManageContent =>
      'ምስ ናይ ትእዛዝ ሕቶኹም ዝሰማምዑ ኣባይቲ፣ መካይን ወይ ሰራሕተኛታት ምስ ተረኽቡ:\n\n1. ምሉእ ሓበሬታ እቲ ጥቆማ ዝሓዘ ቅልጡፍ መልእኽቲ ክበፅሓኩም እዩ\n2. ዝቐረቡ ፎቶታት፣ ዋጋን ዝርዝር ሓበሬታን ኣብ ገፅ ትእዛዛትኩም ከፊትኩም ርኣዩ\n3. እቲ ዝቐረበ ኣማራፂ እንተሰማሚዕኩም ምስ ዋና፣ ሸያጢ ወይ ኣመልካቲ ብቐጥታ ንምርኻብ \"ተቐበል\" ዝብል ጠውቑ\n4. እቲ ዝቐረበ እንተዘይተመችዩኩም ሕቶኹም ክፍቲ ኮይኑ ካልኦት ጥቆማታት ንኽቕበል \"ውድቂ ግበር\" ዝብል ምረፁ\n5. ዝደለኹምዎ ንብረት ምስ ረኸብኩም ነቲ ትእዛዝ ኣብ ዝኾነ እዋን ክትዓፅውዎ ትኽእሉ ኢኹም።';

  @override
  String get helpPayPlansTitle => 'ናይ ኣባልነት ፓኬጃት፣ ደረት ምልክታታትን ኮታ ምርኣይን';

  @override
  String get helpPayPlansContent =>
      'ዌቭማርት ንዓደግቲ፣ ሸየጥቲ፣ ደላሎን ኣስራሕትን ዝተዳለዉ ንፁራት ናይ ኣባልነት ፓኬጃት የቕርብ:\n\n- ነፃ / ጀማሪ (Free/Starter): ኣባይቲ፣ መካይንን ስራሕትን ብነፃ ምድህሳስ፤ ዝመረፅኩምዎም ምዕቃብን ኣብ ውሽጢ መተግበሪ ብፅሑፍ ምዝርራብን\n- ቤዚክ (Basic): ኣብ ኩሎም ዘፈራት ምልክታታት ምዝርጋሕ፣ ናይ ቪዲዮ ዑደታት ምርኣይ፣ ከምኡ እውን ናይ ሸየጥትን ኣስራሕትን ቑፅሪ ስልኪ ንምርኣይ ዘኽእሉ ወርሓዊ ኮታታት ምርካብ\n- ፕሮፌሽናል (Professional): ዝለዓለ ቁፅሪ ምልክታታት ምውፃእ፣ ምልክታታት ናብ ቅድሚት ናይ ምውፃእ (Featured) ዕድል፣ ዝለዓለ ናይ ምርኣይ ኮታታትን ቀዳምነት ዝወሃቦ ናይ ሓገዝ ኣገልግሎትን\n- ቪአይፒ (VIP): ዝለዓለ ናይ ምርኣይ ኮታ፣ ፍሉያት ንዝኾኑን ብዕሊ ዘይተዘርግሑን ናይ ቪአይፒ ኣባይትን መካይንን ምሉእ ምርኣይ፣ ፍሉይ ናይ ቪአይፒ ባጅን ኣብቲ መድረኽ ቀዳማይ ተራእይነትን\n\nናይ ምርኣይ ኮታታት ኣብ ነፍሲ ወከፍ ናይ ኣባልነት እዋን ይሕደሱ። ካብ ገፅ ኣባልነት ኣብ ዝኾነ እዋን ፓኬጅኹም ከተዕብዩ ወይ ክትሕድሱ ትኽእሉ ኢኹም።';

  @override
  String get helpPayMakeTitle =>
      'ብቴሌብር፣ CBEBirr ከምኡ እውን ብካርድ ብቻፓ ኣቢልካ ክፍሊት ምፍፃም';

  @override
  String get helpPayMakeContent =>
      'ናይ ኣባልነት ፓኬጅኩም ንምዕባይ ወይ ንምልክታኹም ፍሉይ ምርኣይ ንምሃብ ብቐዳማይ ናይ ክፍሊት መንገዲ ኢትዮጵያ ብዝኾነ ቻፓ (Chapa) ኣቢልኩም ውሑስ ክፍሊት ክትፍፅሙ ትኽእሉ ኢኹም:\n\n1. ናብ ኣካውንት > ኣባልነት ኺዱ እሞ ዝደለኹምዎ ፓኬጅ ምረፁ\n2. \"ሕጂ ተመዝገቡ\" ወይ \"ፓኬጅ ኣዕብዩ\" ዝብል ጠውቑ\n3. ናብቲ ውሑስ ናይ ቻፓ ክፍሊት ገፅ ክትውሰዱ ኢኹም\n4. እትመርፅዎ ናይ መክፈሊ መንገዲ ምረፁ: ቴሌብር (Telebirr)፣ CBEBirr፣ M-Pesa፣ ኣዋሽ ብር ወይ ናይ ባንኪ ካርድ\n5. ኣብ ሞባይል ባንኪንኩም ወይ ዋሌትኩም ዝመፅእ ሕቶ ብምፅዳቕ ክፍሊትኩም ፈፅሙ\n6. ክፍሊት ምስ ተዛዘመ ናይ ኣባልነት ኣገልግሎትኩምን ናይ ምርኣይ ኮታኹምን ብቕልጡፍ ይነቅሕ\n\nዌቭማርት ዝኾነ ዝተሓብአ ክፍሊት ኣየኽፍልን፤ ኣብቲ ስክሪን ዝርአ ዋጋ እቲ ትኽክለኛ መጠን ክፍሊት እዩ።';

  @override
  String get helpPaySecurityTitle => 'ድሕንነት ክፍሊትን ምክልኻል ሓበሬታን';

  @override
  String get helpPaySecurityContent =>
      'ናይ ፋይናንስ ድሕንነትኩም ቀዳማይ ትኹረትና እዩ:\n\n1. ዝለዓለ ድሕንነት ምስጢራውነት: ኩሎም ክፍሊታት ብናይ ቻፓ ዓለም ለኻዊ ናይ ድሕንነት ደረጃ (PCI-DSS) ብዘማልአን ብዝለዓለ ድሕንነት ብዝተሓለወን ሲስተም ይፍፀሙ\n2. ሓበሬታ ካርድ ኣይዕቀብን: ዌቭማርት ናይ ባንኪ ካርድ ቑፅርኹም፣ ናይ ባንኪ መሕለፊ ቃልኩም ወይ ናይ ሞባይል ዋሌት ሚስጢር ቑፅርኹም ፈፂሙ ኣይርእን ኣየቐምጥን እውን\n3. ቅልጡፍ ደረሰኝ: ንነፍሲ ወከፍ ዝተሳኸዐ ክፍሊት ፍሉይ መረዳእታ ኮድ ዘለዎ ዲጂታል ደረሰኝ ኣብ ኣካውንትኩም ይፍጠር\n4. ሓገዝ ክፍሊት: ብባንክኹም ወይ ብዋሌትኩም ክፍሊት ፈፂምኩም ኣብ ኣካውንትኩም እንተዘይተራእዩ ነቲ ፍሉይ ናይቲ ክፍሊት ኮድ (Reference Code) ብምሓዝ ንጉጅለ ሓገዝና እንተዘራሪብኩም ብቕልጡፍ ይስተኻኸለልኩም።';

  @override
  String get helpPayVipTitle => 'ናይ VIP ማዕርግን ምልክታታት ናብ ቅድሚት ምውፃእን (Featured)';

  @override
  String get helpPayVipContent =>
      'ምልክታኹም ብብዙሓት ሰባት ንኽርአን ብቕልጡፍ ንኽሽየጥ ወይ ሰራሕተኛ ንምርካብ ናይ መፋለጢ ኣማራፅታት ተጠቐሙ:\n\n- ፍሉይ ምልክታ (Featured): ንብረትኩም ወይ ናይ ስራሕ ምልክታኹም ኣብ መበገሲ ገፅ ላዕሊ ኣብ ዘሎ ባነር የውፅኦ፤ ከምኡ እውን ኣብ ፍለጋ ውፅኢታት ን30 መዓልቲ ጎሊሁ ንኽርአ ይገብር\n- VIP ምልክታ: ወርቃማ ናይ VIP ባጅ ይህቦ፤ ኣብ ዝርዝር ምልክታታት ካብ ኩሉ ንላዕሊ የቐምጦ፤ ከምኡ እውን ንዓበይቲ ዓደግቲ ፍሉይ ትኹረት ይህብ\n- ፍሉያት ናይ VIP ንብረታት: ናይ VIP ኣባልነት ዘለዎም ተጠቀምቲ ንስሩዓት ተጠቀምቲ ዘይርኣዩ ፍሉያት ኣባይትን መካይንን ናይ ምርኣይን ምግዛእን ዕድል ይረኽቡ\n\nምልክታ ንምፍላጥ: ናብ ኣካውንት > ናተይ ንብረታት ኺዱ፣ ንጡፍ ምልክታኹም ክፈቱ፣ \"ኣፋልጥ / Feature\" ዝብል ምረፁ፣ ዓይነት መፋለጢ ወሲንኩም ኣረጋግፁ።';

  @override
  String get helpKycWhyTitle => 'ምርግጋፅ መንነት (KYC) ስለምንታይ ኣድለየ?';

  @override
  String get helpKycWhyContent =>
      'ዌቭማርት ድሕንነት ሕብረተሰብና ንምሕላውን ናይ ኢትዮጵያ ናይ ዲጂታል ንግዲ ሕግታት ንምኽባርን ምርግጋፅ መንነት ይጥቀም:\n\n1. ምትላል ምክልኻል: ናይ ተጠቀምቲ ናይ ሓቂ መንነት ምርጋፅ ናይ ሓሶት ኣካውንታት፣ ዘየለዉ ንብረታት ምዝርጋሕን ናይ መንነት ስርቅን ይከላኸል\n2. ዝተረጋገፀ ተጠቃሚ ባጅ: መንነቶም ዘረጋገፁ ተጠቀምቲ ሰማያዊ ናይ ቼክማርክ ባጅ ይረኽቡ፤ እዚ ድማ ኣብ ዓደግቲ ዘሎ ምትእምማንን ተደላይነትን ብዓቢዩ የዕብዮ\n3. ምልክታ ናይ ምውፃእ ፍቓድ: ኣባይቲ፣ መካይን ንምሻጥ ወይ ንምክራይ ከምኡ እውን ናይ ስራሕ ምልክታ ንምውፃእ ምርጋፅ መንነት ምዝዛም ግዴታ እዩ\n4. ውሑስ ዕዳጋ: ዝለዓለ ዋጋ ዘለዎም ንብረታት ኣብ ዝሽየጡሉ እዋን ኣብ መንጎ ክልቲኦም ወገናት ምሉእ ምትእምማን ንኽህሉ ይገብር።';

  @override
  String get helpKycHowTitle => 'ምርግጋፅ መንነት ብፋይዳ፣ ፓስፖርት ወይ ቀበሌ መለለዪ ከመይ ይምላእ';

  @override
  String get helpKycHowContent =>
      'ምርግጋፅ መንነት ኣብቲ መተግበሪ ኣብ ውሽጢ 2 ደቒቓ ብቐሊሉ ምዝዛም ይከኣል:\n\n1. ናብ ኣካውንት > ምርግጋፅ መንነት (KYC) ኺዱ\n2. ዓይነት ሰነድ ምረፁ: ናይ ኢትዮጵያ ሃገራዊ መለለዪ (ፋይዳ)፣ ፓስፖርት፣ ፍቓድ መዘወሪ ወይ ናይ ቀበሌ መለለዪ\n3. ናይቲ መለለዪኹም ቅድሚትን ድሕሪትን ገፅ ብሩህ ኣብ ዘለዎ ቦታ ንፁር ፎቶ ኣልዕሉ\n4. ብካሜራ ስልክኹም ንፁር ናይ ገፅኹም ፎቶ (ሴልፊ) ተልዓሉ (ናይ ፀሓይ መነፅር ወይ ቆቢዕ ከይገበርኩም ገፅኩም ብንፁር ክርአ ኣለዎ)\n5. ትኽክለኛ ስምኩምን ቑፅሪ ሰነድኩምን ኣረጋጊፅኩም \"መረጋገፂ ኣእትዉ\" ዝብል ጠውቑ\n\nሲስተምናን ጉጅለ መረጋገፅናን ሓበሬታኹም ኣብ ውሽጢ 24 ክሳብ 48 ሰዓታት ገምጊሞም ምላሽ ክህቡ እዮም።';

  @override
  String get helpKycRejectTitle => 'መረጋገፂ መንነተይ ስለምንታይ ተነፂጉ?';

  @override
  String get helpKycRejectContent =>
      'ምርግጋፅ መንነትኩም ተቐባልነት እንተዘይረኺቡ መብዛሕትኡ ግዜ ካብዞም ዝስዕቡ ምኽንያታት ብሓዲኦም እዩ:\n\n1. ዝደበዘዘ ወይ ዘንፀባርቕ ፎቶ: ናይ ብርሃን ምውሓድ ወይ ናይ ካሜራ ምስታው ብምህላዉ እቲ ፅሑፍ ወይ ፎቶ ብንፁር ዘይምንባብ\n2. ግዝኡ ዝሓለፎ ሰነድ: ዝተለኣኸ መለለዪ ወይ ፓስፖርት ግዜ ኣገልግሎቱ ዝሓለፎ ምዃኑ\n3. ዘይምምስሳል ስም: ኣብ ፕሮፋይልኩም ዘሎ ስም ኣብቲ መለለዪ ካብ ዘሎ ሕጋዊ ስም ምስ ዘይመሳሰል\n4. ንፁር ዘይኮነ ሴልፊ: ናይ ገፅኹም ፎቶ ዝፀልመተ፣ ዝተቖረፀ ወይ ኣብቲ መለለዪ ካብ ዘሎ ፎቶ ምስ ዘይመሳሰል\n5. ምሉእ ዘይኮነ ምስሊ ሰነድ: ናይቲ መለለዪ ኩርናዓት ወይ ወሰናት ኣብቲ ፎቶ ብምሉእ ዘይምርኣይ\n\nመፍትሒ: ናብ ምርግጋፅ መንነት ኺዱ እሞ \"ደጊምኩም ኣእትዉ\" ዝብል ጠውቑ፤ ምሉእ እቲ ሰነድ ዝርኣየሉ ፅሩይ ፎቶን ሓዱሽ ንፁር ሴልፊን ኣልዒልኩም ደጊምኩም ስደዱ።';

  @override
  String get helpSafePrivacyTitle => 'ፖሊሲ ግላዊነትን ድሕንነት ሓበሬታን';

  @override
  String get helpSafePrivacyContent =>
      'ዌቭማርት ድሕንነትን ሚስጢራውነትን ውልቀ ሓበሬታኹም ብጥብቂ ይሕሉ:\n\n1. እንእክቦ ሓበሬታ: ናይ ኣካውንት ሓበሬታ (ስም፣ ቑፅሪ ስልኪ፣ ኢሜይል)፣ ዘውፃእኹምዎም ንብረታት ዝርዝርን ናይ ዓማዊል ሓገዝ ርክባትን ጥራሕ እዩ\n2. ርክብ ናይ ምዕቃብ መትከል: ናይ ሓቂ ዓዳጊ ናይ ሸያጢ ርክብ ንምርኣይ ኮታኡ ተጠቒሙ ክሳብ ዘየፍቀደ ናይ ውልቀ ቑፅሪ ስልክኹምን ኢመይልኩምን ኣብ ቅሉዕ ምልክታታት ተሓቢኦም ይፀንሑ\n3. ሓበሬታ ኣሕሊፍካ ዘይምሃብ: ውልቀ ሓበሬታኹም ንመፋለጥቲ ወይ ንሳልሳይ ወገን ፈፂምና ኣይንሸይጥን ወይ ኣይነካፍልን\n4. ውሑስ ሚስጢራውነት: ንምርግጋፅ መንነት (KYC) ዝተለኣኹ ሰነዳት ብዝለዓለ ምስጢራውነት ተዓፅዮም ዝቕመጡ እንትኾኑ ንመረጋገፂ ኣገልግሎት ጥራሕ ይውዕሉ\n\nምሉእ ፖሊሲ ግላዊነት ኣብ ወብሳይትና ምንባብ ወይ ሕቶ እንተሃልዩኩም ብ support@wavemart.et ክትረኽቡና ትኽእሉ ኢኹም።';

  @override
  String get helpSafeReportTitle => 'ዘጠራጥሩ ነገራት ሪፖርት ምግባርን ሓገዝ ምርካብን';

  @override
  String get helpSafeReportContent =>
      'ናይቲ መድረኽና ድሕንነት ብዝለዓለ ትኹረት ንሕሉ፤ ድሕንነትኩም ዝተሓለወ ንኽኸውን ነዞም ዝስዕቡ መንገዲታት ተጠቐሙ:\n\n1. ኣብ መተግበሪ ውሽጢ ሪፖርት ምግባር: ዘጠራጥር ዋጋ፣ ናይ ሓሶት ፎቶ ወይ ዘይግባእ ተግባር እንተጋጢሙኩም ኣብ ዝኾነ ናይ ገዛ፣ መኪና ወይ ስራሕ ምልክታ ዘሎ ሰለስተ ነጥቢ ሜኑ ብምጥዋቕ \"ሪፖርት ግበር\" ዝብል ምረፁ\n2. ናይ ቅድመ ክፍሊት ፈፂምኩም ኣይትስደዱ: ነቲ ንብረት፣ ገዛ ወይ መኪና ብኣካል ከይረኣኹምን ሰነዳቱ ከየረጋገፅኩምን ንዝኾነ ሰብ ናይ ቅድመ ክፍሊት፣ ናይ ኮሚሽን ወይ መትሓዚ ገንዘብ ብባንኪ ወይ ብቴሌብር ኣይትስደዱ\n3. ናይ ህፁፅ እዋን ስልኪ: ናይ ዓማዊል ድሕንነት ጉጅለና ብቐጥታ ብቑፅሪ ስልኪ +251 981 41 81 81 ርኸብዎም\n4. ናይ ኢሜይል ሓገዝ: ብ support@wavemart.et ዝበፅሓኩም ሓበሬታን ፎቶን ብምስዳድ ሓብሩና፤ ናይ ድሕንነት ጉጅለና ነቲ ጉዳይ መርሚሩ ኣብ ውሽጢ 24 ሰዓታት ስጉምቲ ክወስድ እዩ\n\nዌቭማርት ኣብ መላእ ኢትዮጵያ ውሑስን እሙንን ናይ ዕዳጋ ቦታ ንኽኸውን ብሓባር ንስራሕ።';

  @override
  String get profileVerificationKyc => 'KYC';

  @override
  String get profileStatsListings => 'ንብረታት';

  @override
  String get profileStatsFavorites => 'ዝተመረፁ';

  @override
  String get profileMyInterests => 'ድሌታተይ';

  @override
  String get profileMale => 'ተባዕታይ';

  @override
  String get profileFemale => 'ኣንስተይቲ';

  @override
  String get profileFirstName => 'ሽም';

  @override
  String get profileLastName => 'ሽም ኣቦ';

  @override
  String get profileEmail => 'ኢሜይል';

  @override
  String get profileGender => 'ፆታ';

  @override
  String get profileEmailRequired => 'ኢሜይል የድሊ እዩ';

  @override
  String get profileEmailInvalid => 'በጃኹም ትኽክለኛ ኢሜይል ኣእትዉ';

  @override
  String get kycTitle => 'መረጋገፂ መንነት (KYC)';

  @override
  String get kycVerifiedTitle => 'መንነት ተረጋጊፁ';

  @override
  String get kycVerifiedSubtitle =>
      'መንነትኩም ተረጋጊፁ ኣሎ። ሕጂ ንብረታት ክትምዝግቡን ኩሉ ኣገልግሎት ክትረኽቡን ትኽእሉ ኢኹም።';

  @override
  String get kycCreateListing => 'ንብረት መዝግብ';

  @override
  String get kycPendingTitle => 'ምርግጋፅ ኣብ ገምጋም ኣሎ';

  @override
  String get kycPendingSubtitle =>
      'ሰነዳትኩም ይግምገም ኣሎ። እዚ መብዛሕትኡ ግዜ ካብ 24-48 ሰዓታት ይወስድ።';

  @override
  String kycSubmittedAt(Object date) {
    return 'ዝተልኣኸሉ ዕለት: $date';
  }

  @override
  String get kycRefreshStatus => 'ኩነታት ኣሐድሱ';

  @override
  String get kycRejectedTitle => 'ምርግጋፅ ተነፂጉ';

  @override
  String kycRejectedReason(Object reason) {
    return 'ምክንያት: $reason';
  }

  @override
  String get kycRejectedSubtitle => 'በጃኹም ንፁርን ክንበብ ዝኽእልን ሰነዳት ደጊምኩም ስደዱ።';

  @override
  String get kycResubmit => 'ሰነዳት ደጊምኩም ስደዱ';

  @override
  String get kycInfoBanner => 'መንነትኩም ንምርግጋፅ በጃኹም ንፁር ፎቶ ናይ መንነት ወረቐትኩም ኣተሓሕዙ።';

  @override
  String get kycDocumentType => 'ዓይነት ሰነድ';

  @override
  String get kycNationalId => 'ብሔራዊ መታወቂያ';

  @override
  String get kycPassport => 'ፓስፖርት';

  @override
  String get kycFrontOfDocument => 'ናይቲ ሰነድ ቅድሚት';

  @override
  String get kycFrontSubtitle => 'ናይ ቅድሚት መታወቂያ ንፁር ፎቶ';

  @override
  String get kycBackOfDocument => 'ናይቲ ሰነድ ድሕሪት';

  @override
  String get kycBackSubtitle => 'ናይ ድሕሪት ገፅ ንፁር ፎቶ';

  @override
  String get kycSelfieWithDocument => 'ምስቲ ሰነድ ዘለኩም ፎቶ';

  @override
  String get kycSelfieSubtitle => 'መለለዪኹም ኣብ ጥቓ ገፅኩም ሒዝኩም ተልዓሉ';

  @override
  String get kycSubmitForVerification => 'ንምርግጋፅ ስደዱ';

  @override
  String get kycTapToChange => 'ንምቕያር ጠውቑ';

  @override
  String get kycSelectDocumentType => 'በጃኹም ዓይነት ሰነድ ምረፁ';

  @override
  String get kycUploadFront => 'በጃኹም ናይ ቅድሚት ገፅ ፎቶ ኣተሓሕዙ';

  @override
  String get kycSuccess => 'ምርግጋፅ ብትኽክል ተልኢኹ ኣሎ! ኣብ ገምጋም ይርከብ።';

  @override
  String kycError(Object error) {
    return 'ፎቶ ምልዓል ኣይተኻእለን: $error';
  }

  @override
  String get kycTakePhoto => 'ስእሊ ኣልዕሉ';

  @override
  String get kycChooseGallery => 'ካብ ጋለሪ ምረፁ';

  @override
  String get kycConnectionErrorTitle => 'ፀገም ርክብ ተፈጢሩ';

  @override
  String get kycConnectionErrorSubtitle =>
      'ኵነታት KYC ንምፅዓን ኣይተኻእለን። በጃኹም ኢንተርኔት ርክብኩም መርምሩ ደጊምኩም ፈትኑ።';

  @override
  String get kycRetry => 'ደጊምኩም ፈትኑ';

  @override
  String get kycVerifyPhoneSubtitle => 'ቅድሚ ምቕጣልኩም ቁፅሪ ተሌፎንኩም ከተረጋግፁ የድሊ';

  @override
  String get kycPhoneNumberMinDigits => 'ቁፅሪ ተሌፎን ብውሑዱ 7 ኣሃዛት ክኸውን ኣለዎ';

  @override
  String get searchFilters => 'መፃረዪታት';

  @override
  String get searchPropertyType => 'ዓይነት ንብረት';

  @override
  String get searchListingStatus => 'ኵነታት መሸጣ/ክራይ';

  @override
  String get searchPriceRange => 'ናይ ዋጋ ክልል';

  @override
  String get searchSortBy => 'ቅደም ሰዓብ';

  @override
  String get searchApplyFilters => 'መፃረዪታት ተጠቐሙ';

  @override
  String get searchReset => 'ኣሐድሱ';

  @override
  String get searchPlaceholder => 'ብቦታ ድለዩ...';

  @override
  String get searchClearAll => 'ኹሉ ኣጥፍኡ';

  @override
  String get searchUnder5M => 'ትሕቲ 5 ሚልዮን';

  @override
  String get search5M10M => '5-10 ሚልዮን';

  @override
  String get search10M50M => '10-50 ሚልዮን';

  @override
  String get search50M100M => '50-100 ሚልዮን';

  @override
  String get search100MPlus => 'ልዕሊ 100 ሚልዮን';

  @override
  String get searchNoResultsTitle => 'ዝተረኽበ ንብረት የለን';

  @override
  String get searchNoResultsSubtitle => 'በጃኹም ዳህሳስኩም ወይ መፃረዪኹም ቀይርኩም ፈትኑ';

  @override
  String get searchSortNewest => 'ሓድሽ';

  @override
  String get searchSortOldest => 'ዝፀንሐ';

  @override
  String get searchSortPriceLow => 'ትሑት ዋጋ';

  @override
  String get searchSortPriceHigh => 'ልዑል ዋጋ';

  @override
  String get searchFilterAll => 'ኹሉ';

  @override
  String get searchFilterAny => 'ዝኾነ';

  @override
  String get listingNext => 'ቀፃሊ';

  @override
  String get listingSubmit => 'ኣእትዉ';

  @override
  String get listingContinue => 'ይቐፅሉ';

  @override
  String get listingYearBuilt => 'ዝተሃነፀሉ ዓመት';

  @override
  String get listingRentalPeriod => 'ናይ ኪራይ ግዘ';

  @override
  String get listingPostedForOtherOwner => 'ንኻልእ ዋና ዝተለጠፈ';

  @override
  String get listingOwnerName => 'ስም ዋና';

  @override
  String get listingOwnerPhone => 'ቁጽሪ ስልኪ ዋና';

  @override
  String get listingOwnerNameRequired => 'ስም ዋና ኣእትዉ';

  @override
  String get listingOwnerPhoneRequired => 'ቁጽሪ ስልኪ ዋና ኣእትዉ';

  @override
  String get listingStepBasics => 'መሰረታዊ';

  @override
  String get listingStepDetails => 'ዝርዝራት';

  @override
  String get listingStepMedia => 'ሚዲያ';

  @override
  String get listingStepReview => 'ክለሳ';

  @override
  String get listingPropertyType => 'ዓይነት ንብረት';

  @override
  String get listingVideoMaxSize => 'ዝለዓለ 100MB';

  @override
  String listingExistingFile(Object name) {
    return 'ሕጂ ዘሎ: $name';
  }

  @override
  String get listingListingType => 'ዓይነት ምዝገባ';

  @override
  String get listingHoldingType => 'ዓይነት ትሕዝቶ';

  @override
  String get listingTaxPaid => 'ታክስ ዝተኸፈለሉ';

  @override
  String get listingUseType => 'ዓይነት ኣገልግሎት';

  @override
  String get listingLocation => 'ቦታ';

  @override
  String get listingPriceEtb => 'ዋጋ (ብር)';

  @override
  String get listingHasDebt => 'ዕዳ ወይ እገዳ ኣለዎ';

  @override
  String get listingDebtAmount => 'መጠን ዕዳ';

  @override
  String get listingSelectHolding => 'ዓይነት ትሕዝቶ ይምረፁ';

  @override
  String get listingSelectUse => 'ዓይነት ግልጋሎት ይምረፁ';

  @override
  String get listingRegion => 'ክልል';

  @override
  String get listingZone => 'ዞባ';

  @override
  String get listingWoreda => 'ወረዳ';

  @override
  String get listingKebele => 'ቀበሌ';

  @override
  String get listingSpecificLocation => 'ፍሉይ ቦታ (ኣማራጭ)';

  @override
  String get listingTaxPaidYear => 'ግብሪ ዝተኸፈለሉ ዓመት';

  @override
  String get listingAcquisition => 'ዝተረኸበሉ መንገዲ';

  @override
  String get listingLeasedYear => 'ናይ ሊዝ ዓመት';

  @override
  String get listingLeasePrice => 'ዋጋ ሊዝ ብሜትር ካሬ';

  @override
  String get listingBuildType => 'ዓይነት ህንፃ';

  @override
  String get listingAnnualPayment => 'ዓመታዊ ክፍሊት';

  @override
  String get listingCooperativeName => 'ሽም ማሕበር';

  @override
  String get listingCooperativeCode => 'ኮድ ማሕበር';

  @override
  String get listingBuildingStatus => 'ኩነታት ህንፃ';

  @override
  String get listingRoomConfig => 'ኣቀማምጣ ክፍልታት';

  @override
  String get listingTotalRooms => 'ጠቅላላ ክፍልታት';

  @override
  String listingPhotosCount(Object count) {
    return '$count ስእልታት';
  }

  @override
  String get listingBedrooms => 'መደቀሲ ክፍልታት';

  @override
  String get listingBathrooms => 'መሕፀቢ ክፍልታት (ባኞታት)';

  @override
  String get listingKitchens => 'ክሽነታት';

  @override
  String listingKitchensCount(Object count) {
    return '$count ክሽነ(ታት)';
  }

  @override
  String get listingSalons => 'ሳሎናት';

  @override
  String get listingHouseType => 'ዓይነት ገዛ';

  @override
  String get listingSelectHouseType => 'ዓይነት ገዛ ይምረፁ';

  @override
  String get listingAmenities => 'መሰረታዊ ግልጋሎት';

  @override
  String get listingElectricity => 'መብራት';

  @override
  String get listingWater => 'ማይ';

  @override
  String get listingParking => 'ፓርኪንግ';

  @override
  String get listingAreaDimensions => 'ስፍሓት ቦታ';

  @override
  String get listingTotalArea => 'ጠቅላላ ስፍሓት (ካሬ)';

  @override
  String get listingFrontArea => 'ናይ ቅድሚት ስፍሓት (ካሬ)';

  @override
  String get listingSideArea => 'ናይ ጎኒ ስፍሓት (ካሬ)';

  @override
  String get listingFacingDirection => 'ዝጥምቶ ኣንፈት';

  @override
  String get listingSelectDirection => 'ኣንፈት ምረፁ';

  @override
  String get listingFacing3Directions => '3 ኣንፈታት ዝጥምት';

  @override
  String get listingFacingAllDirections => 'ኩሎም ኣንፈታት ዝጥምት';

  @override
  String get listingDescriptionLabel => 'መግለፂ';

  @override
  String get listingDescribeProperty => 'ብዛዕባ ንብረትኩም ግለፁ';

  @override
  String get listingImages => 'ስእልታት ንብረት (የድሊ)';

  @override
  String get listingSitePlans => 'ሳይት ፕላን (የድሊ)';

  @override
  String get listingOwnershipProof => 'መረጋገፂ ዋናነት';

  @override
  String get listingIsTransferable => 'ክመሓላለፍ ዝኽእል';

  @override
  String get listingTransferable => 'ክመሓላለፍ ዝኽእል';

  @override
  String get listingNotTransferable => 'ክመሓላለፍ ዘይኽእል';

  @override
  String get listingTapToAdd => 'ንምውሳኽ ጠውቑ';

  @override
  String listingImagesSelected(Object count) {
    return '$count ስእልታት ተመሪፆም';
  }

  @override
  String get listingBrowseFile => 'ፋይል ድለዩ';

  @override
  String listingChangeFile(Object name) {
    return 'ቀይሩ: $name';
  }

  @override
  String get listingSummary => 'መጠቓለሊ';

  @override
  String get listingNew => 'ሓድሽ';

  @override
  String get listingAcceptTerms => 'ብውዕላትን ደንብታትን እሰማማዕ';

  @override
  String get listingTermsSubtitle =>
      'ንብረትኩም ብምእታውኩም ብውዕልናን ፖሊሲ ምስጢራውነትናን ትሰማምዑ ኣለኹም';

  @override
  String get listingNoOptions => 'ዝኾነ ኣማራፂ የለን';

  @override
  String get listingSelect => 'ይምረፁ';

  @override
  String get listingFreeHold => 'ነባር ትሕዝቶ';

  @override
  String get listingLeaseHold => 'ሊዝ';

  @override
  String get listingCooperative => 'ማሕበር';

  @override
  String get listingResidential => 'ንመንበሪ';

  @override
  String get listingCommercial => 'ንንግዲ';

  @override
  String get listingMixed => 'ኩሉ ዝሓውስ';

  @override
  String get listingInvestment => 'ንኢንቨስትመንት';

  @override
  String get listingFinished => 'ዝተወድአ';

  @override
  String get listingUnfinished => 'ዘይተወድአ';

  @override
  String get listingNorth => 'ሰሜን';

  @override
  String get listingSouth => 'ደቡብ';

  @override
  String get listingEast => 'ምብራቕ';

  @override
  String get listingWest => 'ምዕራብ';

  @override
  String get listingNorthEast => 'ሰሜን ምብራቕ';

  @override
  String get listingNorthWest => 'ሰሜን ምዕራብ';

  @override
  String get listingSouthEast => 'ደቡብ ምብራቕ';

  @override
  String get listingSouthWest => 'ደቡብ ምዕራብ';

  @override
  String get listingVilla => 'ቪላ';

  @override
  String get listingApartment => 'ኣፓርታማ';

  @override
  String get listingCondominium => 'ኮንዶሚኒየም';

  @override
  String get listingTownhouse => 'ታውን ሃውስ (ናይ ከተማ ገዛ)';

  @override
  String get listingBungalow => 'ባንጋሎው';

  @override
  String get listingCooperative140 => 'ማሕበር (140m²)';

  @override
  String get listingCooperative70 => 'ማሕበር (70m²)';

  @override
  String get listingMarketPlace => 'ዕዳጋ ማእኸል';

  @override
  String get listingPurchased => 'ዝተዓደገ';

  @override
  String get listingInherited => 'ብውርሲ ዝተረኽበ';

  @override
  String get listingGift => 'ብውህብቶ';

  @override
  String get listingAssignment => 'ብውክልና';

  @override
  String get listingOther => 'ካልእ';

  @override
  String get listingFreeHoldDetails => 'ዝርዝር ነባር ትሕዝቶ';

  @override
  String get listingLeaseHoldDetails => 'ዝርዝር ሊዝ';

  @override
  String get listingCooperativeDetails => 'ዝርዝር ማሕበር';

  @override
  String get listingFinancial => 'ናይ ገንዘብ ኩነታት';

  @override
  String get listingSummaryProperty => 'ንብረት';

  @override
  String get listingFeatured => 'ፍሉይ';

  @override
  String get listingHouse => 'ገዛ';

  @override
  String get listingLand => 'መሬት';

  @override
  String get listingPriceOnRequest => 'ዋጋ ብድርድር';

  @override
  String get listingUnknownLocation => 'ዘይፍለጥ ቦታ';

  @override
  String get listingToday => 'ሎሚ';

  @override
  String get listingYesterday => 'ትማሊ';

  @override
  String listingDaysAgo(Object count) {
    return 'ቅድሚ $count መዓልቲ';
  }

  @override
  String listingWeeksAgo(Object count) {
    return 'ቅድሚ $count ሰሙን';
  }

  @override
  String listingMonthsAgo(Object count) {
    return 'ቅድሚ $count ወርሒ';
  }

  @override
  String get listingSale => 'መሸጣ';

  @override
  String get listingRent => 'ክራይ';

  @override
  String get listingForSale => 'ንመሸጣ';

  @override
  String get listingForRent => 'ንክራይ';

  @override
  String get listingVerified => 'ተረጋጊፁ';

  @override
  String listingUnitM2(Object count) {
    return '$count ካሬ';
  }

  @override
  String get listingsTitle => 'ንብረታት';

  @override
  String get listingsCreate => 'ሓድሽ ንብረት ወስኹ';

  @override
  String get listingsFeatured => 'ፍሉያት ንብረታት';

  @override
  String get listingsNoResults => 'ዝተረኽበ ንብረት የለን';

  @override
  String get listingsKeyFeatures => 'ቀንዲ መግለፂታት';

  @override
  String get listingsImInterested => 'ምስ ወኪል ተራኸቡ';

  @override
  String get listingsInterestAccepted => 'ድሌት ተቐባልነት ረኺቡ';

  @override
  String get listingsInterestPending => 'ኣብ መስርሕ';

  @override
  String get listingsInterestRejected => 'ድሌት ተነፂጉ';

  @override
  String get listingsDefaultInterestMessage => 'ድሌት ኣለኒ!';

  @override
  String get callIncoming => 'ፃውዒት ስልኪ...';

  @override
  String get callAccept => 'ተቐበሉ';

  @override
  String get callDecline => 'ኣይትቀበሉ';

  @override
  String get jitsiCallTitle => 'ናይ ድምፂ ስልኪ';

  @override
  String get listingsDescription => 'መግለፂ';

  @override
  String get listingsPropertyDetails => 'ዝርዝር ንብረት';

  @override
  String listingsBedrooms(Object count) {
    return '$count መደቀሲ ክፍልታት';
  }

  @override
  String listingsBathrooms(Object count) {
    return '$count መሕፀቢ ክፍልታት';
  }

  @override
  String listingsSalons(Object count) {
    return '$count ሳሎናት';
  }

  @override
  String get listingsFrontArea => 'ናይ ቅድሚት ግፍሓት';

  @override
  String get listingsSideArea => 'ናይ ጎኒ ግፍሓት';

  @override
  String get listingsUseType => 'ዓይነት ኣገልግሎት';

  @override
  String get listingsHoldingType => 'ዓይነት ትሕዝቶ';

  @override
  String get listingsFacing => 'ኣንፈት';

  @override
  String get listingsNegotiable => 'ብድርድር';

  @override
  String get listingsEncumbrance => 'ዕዳ/ገደብ';

  @override
  String listingsEncumbranceYes(Object amount) {
    return 'እወ ($amount ብር)';
  }

  @override
  String get listingsVideoTour => 'ናይ ቪዲዮ ዑደት';

  @override
  String get listingsVideoOptimizing => 'ቪዲዮ ይዳሎ ኣሎ…';

  @override
  String get listingsViewOriginal => 'መበቆላዊ ቪዲዮ ርኣዩ';

  @override
  String get listingsNoDescription => 'መግለፂ ኣይተዋህበን';

  @override
  String get listingsSimilarListings => 'ተመሳሳሊ ንብረታት';

  @override
  String get listingsNoFeatures => 'ቀንዲ መገለፂታት ኣይተጠቐሱን';

  @override
  String get listingsNotFound => 'ንብረቱ ኣይተረኽበን';

  @override
  String get listingsNotFoundSubtitle => 'እዚ ንብረት ተሰሪዙ ክኸውን ይኽእል እዩ';

  @override
  String get listingsLoadError => 'ንብረቱ ክፅዕን ኣይከኣለን';

  @override
  String listingIdLabel(Object id) {
    return 'ንብረት #$id';
  }

  @override
  String listingsTitleTemplate(Object action, Object location, Object type) {
    return '$type $action ኣብ $location';
  }

  @override
  String listingsPriceFixed(Object price) {
    return '$price ብር';
  }

  @override
  String listingsPriceRange(Object max, Object min) {
    return '$min - $max ብር';
  }

  @override
  String get listingsYes => 'እወ';

  @override
  String get favoritesTitle => 'ዝተመረፁ';

  @override
  String get ordersTitle => 'ትእዛዛት';

  @override
  String ordersCount(Object count) {
    return '$count ትእዛዛት';
  }

  @override
  String get ordersDetailTitle => 'ዝርዝር ትእዛዝ';

  @override
  String get ordersEmpty => 'ክሳብ ሕጂ ዝኾነ ትእዛዝ የለን';

  @override
  String get ordersEmptySubtitle => 'ንኽትጅምሩ ናይ ንብረት መስፈርቲኹም ኣቕርቡ';

  @override
  String get ordersCreate => 'ትእዛዝ ፍጠሩ';

  @override
  String get ordersStatusActive => 'ንጡፍ';

  @override
  String get ordersStatusFulfilled => 'ተፈፂሙ';

  @override
  String get ordersStatusCancelled => 'ተሰሪዙ';

  @override
  String get ordersTypeHouse => 'ገዛ';

  @override
  String get ordersTypeLand => 'መሬት';

  @override
  String get ordersTypeLabel => 'ዓይነት ንብረት';

  @override
  String get ordersListingType => 'ዓይነት ድሌት';

  @override
  String get ordersBuy => 'ምግዛእ';

  @override
  String get ordersRent => 'ምክራይ';

  @override
  String get ordersHoldingType => 'ዓይነት ትሕዝቶ';

  @override
  String get ordersSelect => 'ምረፁ';

  @override
  String get ordersFacing => 'ኣንፈት';

  @override
  String get ordersBudget => 'በጀት (ETB)';

  @override
  String get ordersMin => 'ትሑት';

  @override
  String get ordersMax => 'ዝለዓለ';

  @override
  String get ordersArea => 'ግፍሓት (m²)';

  @override
  String get ordersDescription => 'መግለፂ';

  @override
  String get ordersDescriptionHint => 'መጠን፣ ባህርያት፣ መስፈርታት...';

  @override
  String get ordersSubmit => 'ትእዛዝ ኣቕርቡ';

  @override
  String get ordersCancel => 'ትእዛዝ ሰርዙ';

  @override
  String get ordersCancelConfirm => 'ነዚ ትእዛዝ ክትስርዙ ርግፀኛ ዲኹም?';

  @override
  String get ordersCancelled => 'ትእዛዝ ተሰሪዙ';

  @override
  String get ordersCreated => 'ትእዛዝ ብትኽክል ተፈጢሩ';

  @override
  String get ordersLocation => 'ከባቢ';

  @override
  String get ordersSuggestionsEmpty =>
      'ክሳብ ሕጂ ዝተጠቐሰ ንብረት የለን። ኣመሓዳሪ ዝሰማምዑ ንብረታት ኣብዚ ክሕብር እዩ።';

  @override
  String get ordersSuggestions => 'ዝተጠቆሙ ንብረታት';

  @override
  String get ordersSuggestionsViewDetails => 'ዝርዝራት ርኣዩ';

  @override
  String get ordersSuggestionsSubtitle => 'ኣመሓዳሪ እዞም ንብረታት ንዓኹም ጠቒሙ ኣሎ።';

  @override
  String get ordersSuggestionsAccept => 'ተቐበሉ';

  @override
  String get ordersSuggestionsDecline => 'ውድቂ ግበሩ';

  @override
  String get ordersSuggestionsAccepted => 'ተቐባልነት ረኺቡ';

  @override
  String get ordersSuggestionsDeclined => 'ተነፂጉ';

  @override
  String get ordersSuggestionsAcceptedMessage =>
      'ተቐባልነት ረኺቡ ኣሎ። ወኪላትና ክራኸቡኹም እዮም።';

  @override
  String get ordersSuggestionsDeclinedMessage => 'ሓሳብ ተነፂጉ።';

  @override
  String get ordersSuggestionsError => 'ጥቆማ ክተኣናገድ ኣይከኣለን።';

  @override
  String get favoritesEmpty => 'ዝተመረፀ ንብረት የለን';

  @override
  String get favoritesEmptySubtitle => 'ዝመረፅኩምዎም ንብረታት ኣብዚ ክትረኽብዎም ኢኹም';

  @override
  String get favoritesAdded => 'ናብ ዝተመረፁ ተወሲኹ';

  @override
  String get favoritesRemoved => 'ካብ ዝተመረፁ ወፂኡ';

  @override
  String get messagesTitle => 'መልእኽታት';

  @override
  String get messagesEmpty => 'መልእኽቲ የለን';

  @override
  String get messagesTypeMessage => 'መልእኽቲ ፅሓፉ...';

  @override
  String get messagesUnread => 'ዘይተነበቡ';

  @override
  String get messagesUnreadMessages => 'ዘይተነበቡ መልእኽታት';

  @override
  String get messagesSwitchContext => 'ኣርእስቲ ቀይሩ';

  @override
  String get settingsSectionAccount => 'ናይ ኣካውንት ሓበሬታ';

  @override
  String get settingsSectionSupport => 'ሓገዝ';

  @override
  String get settingsSubscriptionsSubtitle => 'ፓኬጅኩም ርኣዩ';

  @override
  String get settingsPaymentsSubtitle => 'ታሪኽ ክፍሊት';

  @override
  String get settingsKycVerified => 'ተረጋጊፁ';

  @override
  String get settingsKycPending => 'ኣብ መስርሕ';

  @override
  String get settingsKycRequired => 'የድሊ';

  @override
  String get settingsPrivacyPolicy => 'ፖሊሲ ምስጢራውነት';

  @override
  String get settingsTermsOfService => 'ውዕል ኣገልግሎት';

  @override
  String settingsWebOpenError(Object title) {
    return '$title ክኽፈት ኣይከኣለን';
  }

  @override
  String get settingsPreferences => 'ቅንብራት';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsNotifications => 'መተሓሳሰቢታት';

  @override
  String get settingsDarkMode => 'ፀሊም ገፅ';

  @override
  String get settingsDeleteAccount => 'ኣካውንት ሰርዙ';

  @override
  String get settingsDeleteAccountConfirm =>
      'ርግፀኛ ዲኹም ኣካውንትኩም ክተጥፍእዎ ትደልዩ? እዚ ምምላስ ዘይብሉ ስጉምቲ እዩ። ኩሉ ሓበሬታኹም፣ ዝርዝራትኩምን መልእኽትታትኩምን ክወገድ እዩ።';

  @override
  String get settingsDeleteAccountSuccess => 'ኣካውንት ብትኽክል ተሰሪዙ';

  @override
  String get listingEditTitle => 'ንብረት ኣመዓራርዩ';

  @override
  String get listingEditCooldownActive =>
      'ንብረታት ኣብ ውሽጢ 14 መዓልታት ሓደ ጊዜ ጥራይ ክዕረዩ ይከኣል።';

  @override
  String get listingMediaLockedTitle => 'ሚዲያ ተዓፅዩ';

  @override
  String get listingMediaLockedDesc => 'ንብረት ምስ ተመዝገበ ሚዲያ ምቕያር ኣይከኣልን።';

  @override
  String get listingDeleteConfirmTitle => 'ንብረት ሰርዙ';

  @override
  String get listingDeleteConfirmMessage => 'ነዚ ንብረት ክትሰርዙ ርግፀኛ ዲኹም?';

  @override
  String get languageTitle => 'ቋንቋ ይምረፁ';

  @override
  String get languageEnglish => 'English (እንግሊዝኛ)';

  @override
  String get languageAmharic => 'አማርኛ (ኣምሓርኛ)';

  @override
  String get languageTigrinya => 'ትግርኛ';

  @override
  String get authEnterPhone => 'ቁፅሪ ተሌፎንኩም ኣእትዉ';

  @override
  String get authSendOtp => 'ኮድ ስደዱ';

  @override
  String get authVerifyOtp => 'ኮድ ኣረጋግፁ';

  @override
  String get authEnterOtp => 'በዓል 6 ኣሃዝ ኮድ ኣእትዉ';

  @override
  String get authResendOtp => 'ኮድ ደጊምኩም ስደዱ';

  @override
  String get authLogin => 'እተዉ';

  @override
  String get authRegister => 'ተመዝገቡ';

  @override
  String get authLogout => 'ውፅኡ';

  @override
  String get authLogoutConfirm => 'ክትወፅኡ ርግፀኛ ዲኹም?';

  @override
  String get authEnterPhonePrompt => 'በጃኹም ቁፅሪ ተሌፎንኩም ኣእትዉ';

  @override
  String get authEnterOtpPrompt => 'በጃኹም በዓል 6 ኣሃዝ ኮድ ኣእትዉ';

  @override
  String get authWelcomeTitle => 'ናብ ዌቭማርት ብድሓን መፁ';

  @override
  String get authWelcomeSubtitle => 'እቲ እትኣምንዎ ናይ ንብረት ዕዳጋ';

  @override
  String authOtpSentMessage(Object phone) {
    return 'በዓል 6 ኣሃዝ ኮድ ናብ $phone ሰዲድና ኣለና';
  }

  @override
  String authOtpSentEmailMessage(Object email) {
    return '6 ኣሃዝ ኮድ ናብ $email ተላኢኹ ኣሎ';
  }

  @override
  String authResendCountdown(Object seconds) {
    return 'ኮድ ድሕሪ $seconds ሰከንድ ደጊምኩም ስደዱ';
  }

  @override
  String get authChangeNumber => 'ቁፅሪ ቀይሩ';

  @override
  String get authChangeNumberConfirm => 'ናይ ስልኪ ቑፅርኹም ክትቅይሩ ትደልዩ ዲኹም?';

  @override
  String get authExitLogin => 'ካብ ምእታው ውፅኡ';

  @override
  String get authExitLoginConfirm => 'ናይ ምእታው መስርሕ ከተቋርፁ ትደልዩ ዲኹም?';

  @override
  String get authNoAccount => 'ኣካውንት የብልኩምን? ';

  @override
  String get authCreateAccount => 'ኣካውንትኹም ፍጠሩ';

  @override
  String get authJoinMarketplace => 'ነቲ እትኣምንዎ ናይ ንብረት ዕዳጋ ተፀንበሩ';

  @override
  String get authPersonalInfo => 'ናይ ውልቀ ሓበሬታ';

  @override
  String get authVerifyPhone => 'ተሌፎንኩም ኣረጋግፁ';

  @override
  String get authVerifyAndCreate => 'ኣረጋግፁን ኣካውንት ፍጠሩን';

  @override
  String get authWelcomeBack => 'እንኳዕ ብደሓን መፃእኩም';

  @override
  String get authAlreadyHaveAccount => 'ኣካውንት ኣለኩም ድዩ? ';

  @override
  String get authCancelRegistration => 'ምዝገባ ክትሰርዙ ትደልዩ ዲኹም?';

  @override
  String get authFirstNameRequired => 'በጃኹም ሽምኩም ኣእትዉ';

  @override
  String get authLastNameRequired => 'በጃኹም ሽም ኣቦኹም ኣእትዉ';

  @override
  String get authPhoneRequired => 'በጃኹም ትኽክለኛ ቁፅሪ ተሌፎን ኣእትዉ';

  @override
  String get authSelectGender => 'በጃኹም ፆታኹም ምረፁ';

  @override
  String get authNetworkError => 'ናይ ኔትወርክ ፀገም። በጃኹም ደጊምኩም ፈትኑ።';

  @override
  String get subscriptionsTitle => 'ናይ ኣባልነት ፓኬጃት';

  @override
  String get subscriptionsCurrentPlan => 'ናይ ሕጂ ፓኬጅ';

  @override
  String get subscriptionsSubscribe => 'ሕጂ ተመዝገቡ';

  @override
  String get subscriptionsSelectPlan => 'ፓኬጅ ይምረፁ';

  @override
  String get subscriptionsChoosePlan => 'ፓኬጅኹም ይምረፁ';

  @override
  String get subscriptionsSelectPlanSubtitle =>
      'ንዓኹም ዝበቅዕ ፓኬጅ ይምረፁ። ኣብ ዝኾነ እዋን ክተዕብይዎ ትኽእሉ ኢኹም።';

  @override
  String get subscriptionsListings => 'ንብረታት';

  @override
  String get subscriptionsRentalListings => 'ናይ ክራይ ንብረታት';

  @override
  String get subscriptionsRentalVehicles => 'ናይ ክራይ መካይን';

  @override
  String get subscriptionsFeaturedListings => 'ፍሉያት ንብረታት';

  @override
  String subscriptionsDaysLeft(Object count) {
    return '$count መዓልታት ተሪፎም';
  }

  @override
  String get subscriptionsFreeSuccess => 'ነጻ ፓኬጅ ብትኽክል ተበጊሱ!';

  @override
  String subscriptionsExpiresOn(Object date) {
    return 'ብ$date ይዛዝም';
  }

  @override
  String subscriptionsCancelledOn(Object date) {
    return 'ብ$date ተሰሪዙ';
  }

  @override
  String subscriptionsExpiredOn(Object date) {
    return 'ብ$date ሓሊፉ';
  }

  @override
  String get subscriptionsFeatures => 'ባህርያት';

  @override
  String get subscriptionsNoPlansAvailable =>
      'ኣብዚ ግዘ ዝኾነ ንጡፍ ናይ ኣባልነት ፓኬጅ የለን።';

  @override
  String get subscriptionsOrders => 'ትእዛዛት';

  @override
  String get subscriptionsContactViews => 'ናይ ርክብ መረዳእታ ምርኣይ';

  @override
  String get subscriptionsManage => 'ኣመሓድሩ';

  @override
  String get subscriptionsRenew => 'ፓኬጅ ኣሐድሱ';

  @override
  String subscriptionsFreeTrial(Object planName) {
    return 'ናጻ ፈተነ፦ $planName';
  }

  @override
  String get subscriptionsStartFreeTrialTitle => 'ናጻ ፈተነ ክትጅምሩ ትደልዩ ዲኹም?';

  @override
  String subscriptionsStartFreeTrialPrompt(Object days, Object planName) {
    return 'ናይ $days መዓልታት ናጻ ፈተነ ኣብ $planName ይጀምሩ? ንሓደ ኣካውንት ሓደ ፈተነ ጥራሕ።';
  }

  @override
  String get subscriptionsStartTrialButton => 'ፈተነ ይጀምሩ';

  @override
  String subscriptionsStartTrialDaysButton(Object days) {
    return 'ናይ $days መዓልታት ናጻ ፈተነ ይጀምሩ';
  }

  @override
  String subscriptionsUpgradeOff(Object percent) {
    return '$percent% ቅናሽ';
  }

  @override
  String subscriptionsPromoOff(Object percent) {
    return '$percent% ቅናሽ';
  }

  @override
  String get subscriptionsPaymentPending => 'ክፍሊት ተላኢኹ። ምስተረጋገፀ ክንሕብረኩም ኢና።';

  @override
  String get subscriptionPaymentCancelled =>
      'ክፍሊት ተሰሪዙ። ኣብ ዝኾነ ግዜ ደጊምኩም ክትፍትኑ ትኽእሉ ኢኹም።';

  @override
  String get subscriptionsPoweredByChapa => 'ክፍሊታት ብቻፓ ብውሑስ ኣገባብ ይካየዱ';

  @override
  String get subscriptionsVipAccess => 'ናይ VIP መዳረሻ';

  @override
  String get notificationsEmpty => 'ሓድሽ ሓበሬታ የለን';

  @override
  String get notificationsEmptySubtitle => 'ሓድሽ ነገር ምስ ዝህሉ ኣብዚ ክትርእዩ ኢኹም';

  @override
  String get notificationsMarkAllRead => 'ኹሉ ርኡይ ግበሮ';

  @override
  String get paymentsEmpty => 'ዝኾነ ናይ ክፍሊት ታሪኽ የለን';

  @override
  String get paymentsRef => 'መለለዪ';

  @override
  String get paymentsUnknownDate => 'ዘይፍለጥ ዕለት';

  @override
  String get paymentsSubscription => 'ክፍሊት ኣባልነት';

  @override
  String get paymentsFeatured => 'ክፍሊት ፍሉይ ንብረት';

  @override
  String get paymentsDirect => 'ቀጥታ ክፍሊት';

  @override
  String get paymentsGeneral => 'ክፍሊት';

  @override
  String get messageRetry => 'ደጊምኩም ፈትኑ';

  @override
  String get messageDismiss => 'ዕፀዉ';

  @override
  String get messageNetworkTitle => 'ናይ ኢንተርኔት ርክብ የለን';

  @override
  String get messageNetworkSubtitle => 'በጃኹም ርክብኩም ኣረጋግፁ እሞ ደጊምኩም ፈትኑ።';

  @override
  String get messageEmptyTitle => 'ነገር የለን';

  @override
  String get messageEmptySubtitle => 'ሕጂ ክርአ ዝከኣል ነገር የለን።';

  @override
  String get messageErrorTitle => 'ገለ ፀገም ኣጋጢሙ';

  @override
  String get messageErrorSubtitle => 'ሕቶኹም ክነጠናቕቕ ኣይከኣልናን።';

  @override
  String get messageSuccessTitle => 'ተሳኺዑ!';

  @override
  String get messageSuccessSubtitle => 'ብትኽክል ተፈፂሙ።';

  @override
  String get messageInfoTitle => 'ሓበሬታ';

  @override
  String get messageInfoSubtitle => 'እዚ ገለ ኣገዳሲ ሓበሬታ እዩ።';

  @override
  String get messageWarningTitle => 'መጠንቀቕታ';

  @override
  String get messageWarningSubtitle => 'እዚ ኣገዳሲ መልእኽቲ ይገምግሙ።';

  @override
  String get listingUpgradeNow => 'ሕጂ ኣዕብዩ';

  @override
  String get listingFeatureNow => 'ሕጂ ፈሊኹም ኣውፅኡ';

  @override
  String get listingViewPlans => 'ፓኬጃት ርኣዩ';

  @override
  String get listingFeatureThis => 'ነዚ ንብረት ፈሊኹም ኣውፅኡ';

  @override
  String get listingUnfeature => 'ምፍላይ ኣቋርፁ';

  @override
  String get listingUnfeatureConfirmTitle => 'ምፍላይ እቲ ምልክታ ከተቋርፁ ትደልዩ ዲኹም?';

  @override
  String get listingUnfeatureConfirmMessage =>
      'ነቲ ፍሉይ ደረጃ ከተልዕልዎ ርግፀኛ ዲኹም? እንደገና ፈሊኹም ንምውፃእ ካልእ ኮታ ክትጥቀሙ የድልየኩም እዩ።';

  @override
  String get commonGoodMorning => 'ከመይ ሓዲርኩም';

  @override
  String get commonGoodAfternoon => 'ከመይ ውዒልኩም';

  @override
  String get commonGoodEvening => 'ከመይ ኣምሲኹም';

  @override
  String get errorLoadingListings => 'ንብረታት ክፅዕን ኣይከኣለን';

  @override
  String get errorLoadingPayments => 'ክፍሊታት ክፅዕን ኣይከኣለን';

  @override
  String get errorLoadingNotifications => 'ሓበሬታ ክፅዕን ኣይከኣለን';

  @override
  String get errorLoadingFavorites => 'ዝተመረፁ ክፅዕን ኣይከኣለን';

  @override
  String get errorLoadingConversations => 'ዝርርባት ክፅዕን ኣይከኣለን';

  @override
  String get errorLoadingMessages => 'መልእኽታት ክፅዕን ኣይከኣለን';

  @override
  String get errorSubscription => 'ናይ ምዝገባ ጌጋ';

  @override
  String errorJoinCall(Object error) {
    return 'ናብ ርክብ ክፅንበር ኣይተኻእለን: $error';
  }

  @override
  String get subscriptionPaymentSuccess => 'ክፍሊት ብትኽክል ተፈፂሙ!';

  @override
  String subscriptionUnexpectedError(Object error) {
    return 'ዘይተፀበናዮ ጌጋ ኣጋጢሙ: $error';
  }

  @override
  String get subscriptionRequiredTitle => 'ፓኬጅ የድሊ';

  @override
  String get subscriptionRequiredListingSubtitle =>
      'ንብረት ንምምዝጋብ ዘኽእል ንጡፍ ፓኬጅ የድሊ።';

  @override
  String get subscriptionRequiredDetailsSubtitle =>
      'ዝርዝር ንብረታት ንምርኣይን ምስ ዋናታት ንምርኻብን ዘኽእል ንጡፍ ናይ ኣባልነት ፓኬጅ የድሊ።';

  @override
  String get subscriptionRequiredOrderSubtitle =>
      'ትእዛዝ ንምምዝጋብ ዘኽእል ንጡፍ ፓኬጅ የድሊ።';

  @override
  String get subscriptionLimitReached =>
      'ናይ ምዝገባ ደረትኩም በፂሕኩም ኣለኹም። ተወሳኺ ንብረታት ንምምዝጋብ ምዝገባኩም ኣዕብዩ።';

  @override
  String get subscriptionLimitReachedRental =>
      'ናይ ክራይ ዝርዝራት ደረት በፂሕኩም ኣለኹም። ዝያዳ ክራይ ንምልጣፍ ምዝገባኹም ኣዕብዩ።';

  @override
  String get subscriptionLimitReachedRentalVehicle =>
      'ናይ ክራይ መካይን ደረት በፂሕኩም ኣለኹም። ዝያዳ ንምልጣፍ ምዝገባኹም ኣዕብዩ።';

  @override
  String get subscriptionLimitReachedTitle => 'ናይ ምዝገባ ደረት በፂሑ';

  @override
  String get kycRequiredTitle => 'መረጋገፂ መንነት (KYC) የድሊ';

  @override
  String get kycPendingSubtitleReview =>
      'መረጋገፂ መንነትኩም ገና ኣብ ገምጋም ይርከብ። ምስ ፀደቐ ንብረት ክትምዝግቡ ትኽእሉ ኢኹም።';

  @override
  String get kycRequiredSubtitlePost =>
      'ንብረት ቅድሚ ምምዝጋብኩም መረጋገፂ መንነት (KYC) ክተጠናቕቑ ኣለኩም።';

  @override
  String get kycVerifyNow => 'ሕጂ ኣረጋግፁ';

  @override
  String get orderSelectPropertyType => 'ዓይነት ንብረት ምረፁ';

  @override
  String get orderBudgetAreaSubtitle => 'በጀት፣ ስፍሓትን ዓይነት ግብይትን';

  @override
  String get orderHoldingFacingSubtitle => 'ዓይነት ትሕዝቶን ዝጥምቶ ኣንፈትን';

  @override
  String get orderDescriptionSubtitle => 'ዘድልየኩም ንብረት ብዝርዝር ግለፁ';

  @override
  String get orderRequired => 'የድሊ';

  @override
  String orderUpTo(Object price, Object unit) {
    return 'ክሳብ $price $unit';
  }

  @override
  String get listingErrorPropertyTypeRequired => 'ዓይነት ንብረት የድሊ';

  @override
  String get listingErrorHoldingTypeRequired => 'ዓይነት ትሕዝቶ የድሊ';

  @override
  String get listingErrorListingTypeRequired => 'ዓይነት ምዝገባ የድሊ';

  @override
  String get listingErrorUseTypeRequired => 'ዓይነት ኣገልግሎት የድሊ';

  @override
  String get listingErrorAddressRequired => 'በጃኹም ምሉእ ኣድራሻ ምረፁ';

  @override
  String get listingErrorMinPrice => 'ትክክለኛ ዋጋ የእትዉ';

  @override
  String get listingPricePerAgreement => 'ብስምምነት';

  @override
  String get listingPriceOnAgreement => 'ዋጋ ብስምምነት';

  @override
  String get listingErrorLeasedYearRequired => 'ናይ ሊዝ ዓመት የድሊ';

  @override
  String get listingErrorCooperativeNameRequired => 'ሽም ማሕበር የድሊ';

  @override
  String get listingErrorCooperativeCodeRequired => 'ኮድ ማሕበር የድሊ';

  @override
  String get listingErrorRoomsRequired => 'ጠቅላላ ክፍልታት የድልዩ';

  @override
  String get listingErrorHouseTypeRequired => 'ዓይነት ገዛ የድሊ';

  @override
  String get listingErrorAreaRequired => 'ጠቅላላ ስፍሓት የድሊ';

  @override
  String get listingErrorDescriptionRequired => 'መግለፂ የድሊ';

  @override
  String get listingErrorImageRequired => 'ብውሑዱ ሓደ ስእሊ ንብረት የድሊ';

  @override
  String get listingErrorSitePlanRequired => 'ብውሑዱ ሓደ ሳይት ፕላን የድሊ';

  @override
  String get listingErrorVideoRequired => 'ናይ ቪዲዮ ዑደት የድሊ';

  @override
  String get listingErrorOwnershipProofRequired =>
      'ንናይ ማሕበር ንብረታት መረጋገፂ ዋናነት የድሊ';

  @override
  String get listingErrorTermsRequired => 'ውዕላትን ደንብታትን ክትቅበሉ ኣለኩም';

  @override
  String listingErrorTaxYearRange(Object max, Object min) {
    return 'ታክስ ዝተኸፈለሉ ዓመት ኣብ መንጎ $minን $maxን ክኸውን ኣለዎ';
  }

  @override
  String listingErrorYearBuiltRange(Object max, Object min) {
    return 'ዝተሃነፀሉ ዓመት ኣብ መንጎ $minን $maxን ክኸውን ኣለዎ';
  }

  @override
  String get notificationJustNow => 'ሕጂ';

  @override
  String get listingUpgradeToFeature => 'ፈሊኹም ንምውፃእ ኣዕብዩ';

  @override
  String get listingUpgradeToVip => 'ናብ VIP ኣዕብዩ';

  @override
  String get subscriptionRequiredFeatureSubtitle =>
      'ነዚ ምልክታ ፈሊኹም ንምውፃእ ፍሉያት ምልክታታት ናይ ምውፃእ ዕድል ዘለዎ ንጡፍ ናይ ምዝገባ ዕድል የድሊ።';

  @override
  String get errorConnection => 'ናይ ርክብ ፀገም';

  @override
  String get commonBrowseProperties => 'ንብረታት ርኣዩ';

  @override
  String get subscriptionPaymentFailedTitle => 'ክፍሊት ኣይተሳኽዐን';

  @override
  String get subscriptionPaymentFailedSubtitle =>
      'ክፍሊት ኣይተዛዘመን። ደጊምኩም ክትፍትኑ ትደልዩ ዲኹም?';

  @override
  String get subscriptionTechnicalFailureSubtitle =>
      'ናይ ክፍሊት መስመር ክርከብ ኣይተኻእለን። በጃኹም ናይ ኢንተርኔት ርክብኩም ኣረጋግፁ።';

  @override
  String messagesWith(Object name) {
    return 'ምስ $name';
  }

  @override
  String get errorJoinCallGeneric => 'ናይ መፀንበሪ ሊንክ ክኽፈት ኣይከኣለን';

  @override
  String get errorVideoLoad => 'ቪዲዮ ምፅዓን ኣይተኻእለን';

  @override
  String get statusActive => 'ንጡፍ';

  @override
  String get statusExpired => 'ግዚኡ ዝሓለፎ';

  @override
  String get statusCancelled => 'ዝተሰረዘ';

  @override
  String get statusPending => 'ኣብ መስርሕ';

  @override
  String get statusSuccess => 'ተሳኺዑ';

  @override
  String get statusFailed => 'ኣይተዓወተን';

  @override
  String get statusRefunded => 'ዝተመለሰ';

  @override
  String get connectivityOffline => 'ናይ ኢንተርኔት ርክብ የለን';

  @override
  String get connectivityConnecting => 'ይራኸብ ኣሎ...';

  @override
  String get connectivityOnline => 'ኢንተርኔት ተመሊሱ';

  @override
  String get markAsVipTitle => 'ከም VIP ምልክት ይገበር?';

  @override
  String get markAsVip => 'ከም VIP ምልክት ግበሩ';

  @override
  String get markAsVipMessage => 'ንብረትኩም ካብ ተራ ተጠቀምቲ ክኽወልን ብ VIP ምልክት ክልለ እዩ።';

  @override
  String get upgradeToContact => 'ንምርካብ ፓኬጅ ምሕያሽ';

  @override
  String get listingsRevealContact => 'ቁፅሪ ስልኪ ሸያጢ ኣርእዩ';

  @override
  String get listingsRevealing => 'የርኢ ኣሎ...';

  @override
  String get listingsSeller => 'ሸያጢ';

  @override
  String listingsContactViewsRemaining(int remaining, int max) {
    return 'ኣብዚ እዋን $remaining ካብ $max ቁፅሪ ስልኪ ሸያጢ ንምርኣይ ተሪፉኩም ኣሎ።';
  }

  @override
  String get ordersLimitTitle => 'ናይ ትእዛዝ ገደብኩም ወዲእኹም ኣለኹም';

  @override
  String get ordersLimitMessage =>
      'ንናይ ሕጂ ፓኬጅኩም ዝለዓለ ቁፅሪ ትእዛዝ በፂሑ ኣሎ። ተወሳኺ ትእዛዝ ንምፍጠር ፓኬጅኩም ኣማሓይሹ።';

  @override
  String get ordersUpgradePlan => 'ፓኬጅ ኣመሓይሹ';

  @override
  String get subscriptionVideoUpgrade => 'ናይ ቪዲዮ ዑደት ንምርኣይ ፓኬጅኩም ኣማሓይሹ';

  @override
  String get subscriptionPlanNotSupportedListing =>
      'ናይ ሕጂ ፓኬጅኩም ንብረት ምልጣፍ ኣይፈቅድን።';

  @override
  String get subscriptionPlanNotSupportedListingSubtitle =>
      'በጃኹም ናብ ምልጣፍ ንብረት ዝድግፍ ፓኬጅ ኣመሓይሹ።';

  @override
  String get subscriptionPlanNotSupportedOrder =>
      'ናይ ሕጂ ፓኬጅኩም ትእዛዝ ምፍጣር ኣይድግፍን።';

  @override
  String get subscriptionPlanNotSupportedOrderSubtitle =>
      'በጃኹም ናብ ምፍጣር ትእዛዝ ዝድግፍ ፓኬጅ ኣመሓይሹ።';

  @override
  String get subscriptionsShowPricesIn => 'ዓይነት ገንዘብ፦';

  @override
  String get subscriptionsDowngradeTitle => 'ፓኬጅ ክትቅይሩ ትደልዩ ዲኹም?';

  @override
  String get subscriptionsDowngradeMessage =>
      'ናይ ሕጂ ፓኬጅኩም ጥቅማት (ናይ ንብረት መለጠፊ ቦታታት፣ ብፍሉይ ዝቀርቡ ዝርዝራት፣ ቪአይፒ ከምኡውን ካልኦት) ናብ ሓዱሽ ፓኬጅ ኣይምሓለፉን። ዘይተጠቅምኩምዎ ጥቅማት ክጠፍኡ ይኽእሉ እዮም።';

  @override
  String get subscriptionsDowngradeConfirm => 'ብዘየግድስ ቀይሩ';

  @override
  String get commonTryAgain => 'ደጊምኩም ፈትኑ';

  @override
  String get commonDismiss => 'ዕፀዉ';

  @override
  String get networkErrorTitle => 'ናይ ኢንተርነት ርክብ የለን';

  @override
  String get networkErrorMessage => 'በጃኹም ናይ ኢንተርነት ርክብኩም ኣረጋግፁ እሞ ደጊምኩም ፈትኑ።';

  @override
  String get statusFrozen => 'ዝተኸልከለ';

  @override
  String get statusRejected => 'ተነፂጉ';

  @override
  String get statusSold => 'ዝተሸጠ';

  @override
  String get statusRented => 'ዝተኻረየ';

  @override
  String get splashSubtitle => 'እቲ እትኣምንዎ ናይ ንብረት ዕዳጋ';

  @override
  String get homeRefreshing => 'ይሓድስ ኣሎ...';

  @override
  String get shareListingTitle => 'ካብ ዌቭማርት ዝተመቓቐለ - እሙን ናይ ንብረት ዕዳጋኹም';

  @override
  String get shareListingMessage => 'ነዚ ንብረት ኣብ ዌቭማርት ርኣዩ: ';

  @override
  String get authOrSeparator => 'ወይ';

  @override
  String get commonSigningIn => 'ይኣቱ ኣሎ...';

  @override
  String get commonSignInWithGoogle => 'ብGoogle እተዉ';

  @override
  String get webviewDone => 'ተፈፂሙ';

  @override
  String get webviewConnecting => 'ምስ ናይ ክፍሊት መስመር ይራኸብ ኣሎ...';

  @override
  String get webviewActivating => 'ፓኬጅኩም ይበገስ ኣሎ...';

  @override
  String get webviewPleaseWait => 'በጃኹም ቁሩብ ተፀበዩ';

  @override
  String get webviewGatewayTimeout => 'ናይ መእተዊ ግዜ ምውዳእ';

  @override
  String get webviewFailedToLoad => 'ናይ ክፍሊት URL ምፅዓን ኣይተኻእለን';

  @override
  String get settingsDeleteRedirect => 'ነቲ መስርሕ ንምውዳእ ናብ መርበብ ሓበሬታና ክትምረሑ ኢኹም።';

  @override
  String get commonFailedOpenOrder => 'ትእዛዝ ምክፋት ኣይተኻእለን';

  @override
  String get jitsiSettingUpCall => 'ፃውዒት ይዳሎ ኣሎ...';

  @override
  String get submissionFailed => 'ምእታው ኣይተዓወተን';

  @override
  String get submissionSaveDraft => 'ረቂቕ ዓቒብኩም ውፅኡ';

  @override
  String get submissionExit => 'ውፅኡ';

  @override
  String get submissionGoBack => 'ተመለሱ';

  @override
  String get authFailedIdToken => 'ID ቶከን ምርካብ ኣይተኻእለን';

  @override
  String get helpErrorYoutube => 'ዩቲዩብ ክኽፈት ኣይተኻእለን';

  @override
  String settingsBrowserErrorMessage(Object url) {
    return 'ብራውዘር ክኽፈት ኣይተኻእለን። በጃኹም $url በፅሑ';
  }

  @override
  String get interestsEmpty => 'ድሌታት የለን';

  @override
  String get interestsEmptySubtitle => 'ኣብ ንብረታት ዝገለፅኩምዎ ድሌት ኣብዚ ክርአ እዩ';

  @override
  String get updateRequired => 'ምሕዳስ የድሊ';

  @override
  String get updateAvailable => 'ሓድሽ ኣፕዴት ኣሎ';

  @override
  String get updateBlockingMessage =>
      'እዚ ናይ መተግበሪ ሕታም ካብ ጥቕሚ ወፃኢ ኮይኑ ኣሎ። በጃኹም ዌቭማርት ንምጥቃም መተግበሪኹም ኣሐድሱ።';

  @override
  String updateAvailableMessage(Object versionSuffix) {
    return 'ሓድሽ ሕትም$versionSuffix ይርከብ።';
  }

  @override
  String get updateVersionLabel => 'ሕታም: ';

  @override
  String get updateLater => 'ድሕሪ ግዜ';

  @override
  String get updateNow => 'ሕጂ ኣሐድሱ';

  @override
  String get updateWhatsNew => 'እንታይ ሓድሽ?';

  @override
  String get routerInvalidRoute => 'ግጉይ መስመር';

  @override
  String get reportListing => 'ነዚ ምልክታ ሪፖርት ግበሩ';

  @override
  String get reportReason => 'ምኽንያት';

  @override
  String get reportSelectReason => 'ምኽንያት ምረፁ...';

  @override
  String get reportSpam => 'ስፓም';

  @override
  String get reportFake => 'ሓሶት ዝርዝር';

  @override
  String get reportWrongCategory => 'ጌጋ ምድብ';

  @override
  String get reportDuplicate => 'ተመሳሳሊ ዝርዝር';

  @override
  String get reportInappropriate => 'ግቡእ ዘይኮነ ትሕዝቶ';

  @override
  String get reportOther => 'ካልእ';

  @override
  String get reportDescription => 'መግለፂ (ኣማራፂ)';

  @override
  String get reportDescriptionHint => 'ተወሳኺ ዝርዝራት ኣእትዉ...';

  @override
  String get reportSubmit => 'ሪፖርት ኣቕርቡ';

  @override
  String get reportSubmitting => 'ይስደድ ኣሎ...';

  @override
  String get reportSuccess => 'ሪፖርት ተላኢኹ ኣሎ። የቐንየልና።';

  @override
  String get reportErrorGeneric => 'ሪፖርት ምልኣኽ ኣይተኻእለን። በጃኹም ደጊምኩም ፈትኑ።';

  @override
  String get listingCar => 'ተሽከርካሪ';

  @override
  String get listingCarPlural => 'ተሽከርከርቲ';

  @override
  String get listingVehicleCategory => 'ምድብ ተሽከርካሪ';

  @override
  String get listingMake => 'ኣፍራዪ (ብራንድ)';

  @override
  String get listingMakeModel => 'ኣፍራዪን ሞዴልን';

  @override
  String get listingModel => 'ሞዴል';

  @override
  String get listingYear => 'ዓመት';

  @override
  String get listingTransmission => 'ዓይነት ማርሽ';

  @override
  String get listingFuelType => 'ዓይነት ነዳዲ';

  @override
  String get listingBodyType => 'ዓይነት ቅርፂ ተሽከርካሪ (ቦዲ)';

  @override
  String get listingMileage => 'ዝኸዶ ርሕቐት';

  @override
  String get listingMileageMax => 'ዝለዓለ ዝኸዶ ርሕቐት (ኪሜ)';

  @override
  String get listingCondition => 'ኩነታት';

  @override
  String get listingEngineSize => 'መጠን ሞተር';

  @override
  String get listingColor => 'ሕብሪ';

  @override
  String get searchSortYearDesc => 'ዓመት ↓';

  @override
  String get searchSortYearAsc => 'ዓመት ↑';

  @override
  String get searchSortMileageLow => 'ዝኸዶ ርሕቐት ↓';

  @override
  String get searchSortMileageHigh => 'ዝኸዶ ርሕቐት ↑';

  @override
  String get searchLocation => 'ቦታ';

  @override
  String get searchAnyMake => 'ዝኾነ ኣፍራዪ';

  @override
  String get searchAnyModel => 'ዝኾነ ሞዴል';

  @override
  String get searchCars => 'ተሽከርከርቲ ድለዩ';

  @override
  String get commonIsRequired => 'የድሊ እዩ';

  @override
  String get carLocationRequired => 'በጃኹም ቦታ ምረፁ (ቀበሌ)';

  @override
  String get carTermsRequired => 'ነቲ ውዕላት ክትቅበሉ ኣለኩም';

  @override
  String get carRentalPriceNegotiable => 'ብስምምዕነት';

  @override
  String get listingPricing => 'ዋጋ ምውሳን';

  @override
  String get listingOptions => 'ኣማራፂታት';

  @override
  String get listingDoors => 'ማዕጾታት';

  @override
  String get listingSeats => 'መንበራት';

  @override
  String get listingVin => 'VIN';

  @override
  String get listingCreated => 'ተሽከርካሪ ተመዝጊቡ';

  @override
  String get listingUpdated => 'ተሽከርካሪ ተሓዲሱ';

  @override
  String get updateListing => 'ምዝገባ ሓድስ';

  @override
  String get carAddPhoto => 'ፎቶ ወስኹ';

  @override
  String get carPhotoFormatHint => 'JPEG, PNG, WebP — ነፍሲ ወከፍ ዝለዓለ 10MB';

  @override
  String get carEnterMakeName => 'ስም ኣፍራዪ (ብራንድ) ኣእትዉ';

  @override
  String get carEnterModelName => 'ስም ሞዴል ኣእትዉ';

  @override
  String carFileTooLarge(Object name) {
    return '$name ካብ 10MB ገደብ ሓሊፉ';
  }

  @override
  String get photos => 'ፎቶታት';

  @override
  String get mediaTapToPreview => 'ንምርኣይ ጠውቑ';

  @override
  String get mediaImageFormatHint => 'JPEG, PNG, WebP';

  @override
  String get mediaSitePlanSubtitle => 'ምስሊ ሳይት ፕላን';

  @override
  String get mediaExistingSitePlan => 'ዘሎ ሳይት ፕላን';

  @override
  String get mediaOwnershipSubtitle => 'ሰነድ ዋንነት';

  @override
  String get mediaVideoFormatHint => 'MP4, ዝለዓለ 5 ደቒቕ';

  @override
  String get mediaExistingVideo => 'ዘሎ ቪዲዮ';

  @override
  String get mediaPlayPreview => 'ቅድመ-ምርኢት ርኣዩ';

  @override
  String get mediaPicture => 'ምስሊ';

  @override
  String get mediaPictures => 'ምስልታት';

  @override
  String get mediaSitePlan => 'ሳይት ፕላን';

  @override
  String get mediaOwnershipProof => 'መረጋገፂ ዋንነት';

  @override
  String get mediaVideo => 'ቪዲዮ';

  @override
  String mediaFileSizeError(Object label, Object limit) {
    return '$label ካብ $limit ገደብ ሓሊፉ። በጃኹም ንእሽቶ ፋይል ምረፁ።';
  }

  @override
  String get mediaImagesLocked => 'ንብረት ምስ ተመዝገበ ስእልታት ምቕያር ኣይከኣልን።';

  @override
  String get carVipSubtitle => 'ብVIP ተጠቀምቲ ብቻ ዝረአ';

  @override
  String get carCustomFeatures => 'ተወሳኺ መገለፂታት';

  @override
  String get submissionStepValidating => 'ዳታ ይረጋገጽ ኣሎ';

  @override
  String get submissionStepUploading => 'ፋይላት ይፀዓኑ ኣለዉ';

  @override
  String get submissionStepSaving => 'ንብረት ኣብ ምስፋር...';

  @override
  String get submissionValidating => 'ዳታ ይረጋገጽ ኣሎ...';

  @override
  String get submissionUploading => 'ፋይላት ይፀዓኑ ኣለዉ';

  @override
  String get submissionSaving => 'ምዝገባ ይቕመጥ ኣሎ...';

  @override
  String get submissionSavingChanges => 'ለውጥታት ይቕመጡ ኣለዉ...';

  @override
  String get submissionSubmittingTitle => 'ንብረትኩም ይምዝገብ ኣሎ';

  @override
  String get submissionSuccessTitle => 'ንብረትኩም ተመዝጊቡ!';

  @override
  String get submissionPendingApproval =>
      'ምዝገባኹም ክሳብ ዝፀድቕ ኣብ ምፅባይ ይርከብ። ምስ ፀደቐ ክንሕብረኩም ኢና።';

  @override
  String get submissionViewListings => 'ንብረትኩም ርኣዩ';

  @override
  String get submissionCreateAnother => 'ካልእ ፍጠሩ';

  @override
  String get submissionCreatedMessage => 'ምዝገባኹም ተላኢኹ ኣሎ።';

  @override
  String get submissionUpdatedMessage => 'ምዝገባ ብዓወት ተሓዲሱ።';

  @override
  String get submissionConnectionLost => 'መስመር ተቋሪጹ። መረዳእታኹም ተቀሚጡ።';

  @override
  String get submissionRequestTimedOut => 'ናይ ርክብ ሕቶ እዋኑ ሓሊፉዎ። መረዳእታኹም ተቀሚጡ።';

  @override
  String get submissionErrorDefault => 'ገለ ፀገም ተፈጢሩ። በጃኹም ደጊምኩም ፈትኑ።';

  @override
  String get listingDetail => 'ዝርዝራት';

  @override
  String get listingSpecifications => 'ዝርዝር መግለፂ';

  @override
  String get carContactSeller => 'ርክብ ምስ በዓል ንብረት';

  @override
  String get carCall => 'ደውሉ';

  @override
  String get carCallHint => 'ናብ በዓል ንብረት ንምድዋል ጠውቑ';

  @override
  String get carWhatsapp => 'WhatsApp';

  @override
  String get carWhatsappHint => 'ብWhatsApp ተዘራረቡ';

  @override
  String get carTelegram => 'ቴሌግራም';

  @override
  String get carTelegramHint => 'ብቴሌግራም ተዘራረቡ';

  @override
  String get conditionNew => 'ሓድሽ';

  @override
  String get conditionUsed => 'ዘገልገለ';

  @override
  String get categoryCar => 'መኪና';

  @override
  String get categoryMotorcycle => 'ሞተር ሳይክል';

  @override
  String get categoryBicycle => 'ብሽክለታ';

  @override
  String get categoryConstructionEquipment => 'ናይ ኮንስትራክሽን መሳርሒ';

  @override
  String get bodyTypeSedan => 'ሴዳን';

  @override
  String get bodyTypeSuv => 'ኤስዩቪ';

  @override
  String get bodyTypeHatchback => 'ሃችባክ';

  @override
  String get bodyTypePickup => 'ፒከፕ';

  @override
  String get bodyTypeTruck => 'ናይ ፅዕነት መኪና';

  @override
  String get bodyTypeVan => 'ቫን';

  @override
  String get bodyTypeMinibus => 'ሚኒባስ';

  @override
  String get bodyTypeCoupe => 'ኩፔ';

  @override
  String get bodyTypeConvertible => 'ኮንቨርቲብል';

  @override
  String get bodyTypeStationWagon => 'ስቴሽን ዋጎን';

  @override
  String get bodyTypeStandard => 'ስታንዳርድ';

  @override
  String get bodyTypeCruiser => 'ክሩዘር';

  @override
  String get bodyTypeSport => 'ስፖርት';

  @override
  String get bodyTypeTouring => 'ቱሪንግ';

  @override
  String get bodyTypeDualSport => 'ዱአል ስፖርት';

  @override
  String get bodyTypeScooter => 'ስኩተር';

  @override
  String get bodyTypeMoped => 'ሞፔድ';

  @override
  String get bodyTypeMountain => 'ናይ እምባ (ማውንተን)';

  @override
  String get bodyTypeRoad => 'ናይ ኣስፋልት (ሮድ)';

  @override
  String get bodyTypeHybrid => 'ሃይብሪድ';

  @override
  String get bodyTypeCity => 'ናይ ከተማ';

  @override
  String get bodyTypeElectric => 'ኤሌክትሪክ';

  @override
  String get bodyTypeFolding => 'ዝዕፀፍ';

  @override
  String get bodyTypeExcavator => 'ኤክስካቬተር';

  @override
  String get bodyTypeBulldozer => 'ቡልዶዘር';

  @override
  String get bodyTypeLoader => 'ሎደር';

  @override
  String get bodyTypeCrane => 'ክሬን';

  @override
  String get bodyTypeForklift => 'ፎርክሊፍት';

  @override
  String get bodyTypeRoller => 'ሮለር';

  @override
  String get bodyTypeDumper => 'ዳምፐር';

  @override
  String get bodyTypeGenerator => 'ጀነሬተር';

  @override
  String get bodyTypeCompressor => 'ኮምፕረሰር';

  @override
  String get featureAc => 'ኤሲ';

  @override
  String get featureAbs => 'ኤቢኤስ';

  @override
  String get featureAirbag => 'ናይ ድሕንነት አየር ቦርሳ';

  @override
  String get featureAlarmSystem => 'ናይ መጠንቀቅታ ደወል';

  @override
  String get featureAlloyWheels => 'አሎይ ዊልስ';

  @override
  String get featureBackupCamera => 'ናይ ድሕሪት መመልከቲ ካሜራ';

  @override
  String get featureBasket => 'ቅርጫት';

  @override
  String get featureBatteryIncluded => 'ባትሪ ተካቲቱ';

  @override
  String get featureBell => 'ደወል';

  @override
  String get featureBluetooth => 'ብሉቱዝ';

  @override
  String get featureCentralLocking => 'ማእከላይ መሸጎሪ';

  @override
  String get featureCrashBars => 'ናይ መከላኸሊ ሓጺን';

  @override
  String get featureCruiseControl => 'ናይ ፍጥነት መቆጻጸሪ';

  @override
  String get featureDiscBrakes => 'ናይ ዲስክ ፍሬን';

  @override
  String get featureElectricAssist => 'ብኤሌክትሪክ ዝሕገዝ';

  @override
  String get featureFenders => 'ጭቃ መከላኸሊ';

  @override
  String get featureFogLights => 'ናይ ጭጋግ መብራህቲ';

  @override
  String get featureFrontSuspension => 'ናይ ቅድሚ አሞርቲሰር';

  @override
  String get featureGps => 'ጂፒኤስ';

  @override
  String get featureHeatedGrips => 'ዝመውቑ መተሓዚታት ኢድ';

  @override
  String get featureHeatedSeat => 'ዝመውቕ መንበር';

  @override
  String get featureHydraulicThumb => 'ሃይድሮሊክ መቐንጠጢ';

  @override
  String get featureKickstand => 'መደገፊ (እግሪ)';

  @override
  String get featureLeatherSeats => 'ናይ ቆርበት መንበራት';

  @override
  String get featureLedLights => 'ኤልኢዲ መብራህቲ';

  @override
  String get featureLockIncluded => 'መቆለፊ ተካቲቱ';

  @override
  String get featureLongReachArm => 'ነዊሕ ዝዝርጋሕ ክንድ';

  @override
  String get featureLowHours => 'ትሑት ናይ ስራሕ ሰዓታት';

  @override
  String get featureLuggageRack => 'ናይ ሻንጣ መደርደሪ';

  @override
  String get featureNavigation => 'ናቪጌሽን';

  @override
  String get featurePowerSteering => 'ፓወር ስቲሪንግ';

  @override
  String get featurePowerWindows => 'ናይ ኤሌክትሪክ መስኮታት';

  @override
  String get featureQuickAttach => 'ቅልጡፍ መኣሳሰሪ';

  @override
  String get featureRearSuspension => 'ናይ ድሕሪ አሞርቲሰር';

  @override
  String get featureRops => 'ሮፕስ';

  @override
  String get featureRoofRack => 'ናይ ናሕሲ መደርደሪ';

  @override
  String get featureServiceRecords => 'ናይ ጽገና ታሪክ';

  @override
  String get featureSidePanniers => 'ናይ ጎን ቦርሳታት';

  @override
  String get featureSunroof => 'ሰንሩፍ';

  @override
  String get featureTopCase => 'ናይ ድሕሪት ሳንዱቕ';

  @override
  String get featureTowBar => 'ናይ መጎተቲ ሓጺን';

  @override
  String get featureTrackVsWheels => 'ሰንሰለት ወይ ጎማ';

  @override
  String get featureUsbCharger => 'ዩኤስቢ ቻርጀር';

  @override
  String get featureWindshield => 'ናይ ቅድሚ መስታወት';

  @override
  String get listingPostedByAgent => 'ብኤጀንት ዝተለጠፈ';

  @override
  String get listingPostedByAgentLabel => 'እዚ ዝርዝር ብኤጀንት ዝተለጠፈ እዩ';

  @override
  String get orderPostedByAgentLabel => 'እዚ ትእዛዝ ብኤጀንት ዝተለጠፈ እዩ';

  @override
  String get agentIdLabel => 'መለለይ ኤጀንት';

  @override
  String get agentIdRequired => 'ብኤጀንት ምስ ዝለጠፍ መለለይ ኤጀንት የድሊ እዩ';

  @override
  String get agentIdEmpty => 'መለለይ ኤጀንት የድሊ እዩ';

  @override
  String get listingErrorTaxPaidYearRequired => 'ዓመት ክፍሊት ቀረጽ የድሊ እዩ';

  @override
  String get listingErrorAcquisitionClarificationRequired =>
      'ዝተረኸበሉ መንገዲ የድሊ እዩ';

  @override
  String get listingErrorLeasePricePerSqmRequired => 'ብካሬ ሜተር ዋጋ ሊዝ የድሊ እዩ';

  @override
  String get listingErrorBuildTypeRequired => 'ዓይነት ህንፃ የድሊ እዩ';

  @override
  String get listingErrorAnnualPaymentRequired => 'ዓመታዊ ክፍሊት የድሊ እዩ';

  @override
  String get listingErrorBuildingStatusRequired => 'ኩነታት ህንፃ የድሊ እዩ';

  @override
  String get listingErrorDebtAmountRequired => 'መጠን ዕዳ የድሊ እዩ';

  @override
  String get listingErrorYearBuiltRequired => 'ዓመት ህንፀት የድሊ እዩ';

  @override
  String get jobAddEducation => 'ትምህርቲ ወስኹ';

  @override
  String get jobAddExperience => 'ተመክሮ ወስኹ';

  @override
  String get jobAll => 'ኹሎም ስራሕቲ';

  @override
  String get jobApplicationDeadlineOptional => 'ናይ መሕትት መወዳእታ ዕለት (ኣማራጺ)';

  @override
  String get jobBasicInfo => 'መሰረታዊ ሓበሬታ';

  @override
  String get jobBrowseTitle => 'ስራሕቲ ድለዩ';

  @override
  String get jobCategoryEducation => 'ትምህርቲ';

  @override
  String get jobCategoryFinance => 'ፋይናንስ';

  @override
  String get jobCategoryHealthcare => 'ጥዕና';

  @override
  String get jobCategoryIT => 'ኣይቲን ሶፍትዌርን';

  @override
  String get jobCategoryOther => 'ካልእ';

  @override
  String get jobClear => 'ኣጥፍኡ';

  @override
  String get jobCompanyName => 'ሽም ትካል';

  @override
  String get jobCreateButton => 'ስራሕ ኣውፅኡ';

  @override
  String get jobCreateTitle => 'ስራሕ ኣውፅኡ';

  @override
  String get jobDeadline => 'መወዳእታ ዕለት';

  @override
  String get jobDeadlinePast => 'መወዳእታ ዕለት ካብ ሎሚ ኣቐዲሙ ክኸውን ኣይክእልን';

  @override
  String get jobDescription => 'መግለፂ';

  @override
  String get jobEditTitle => 'ስራሕ ኣመዓራርዩ';

  @override
  String get jobEducationLevel => 'ደረጃ ትምህርቲ';

  @override
  String get jobEducationOtherHint => 'ደረጃ ትምህርቲ ኣእትዉ';

  @override
  String get jobEmployerInfo => 'ሓበሬታ ኣስራሒ';

  @override
  String get jobFeatured => 'ፍሉይ ስራሕ';

  @override
  String get jobFieldOfStudy => 'ዓውዲ ትምህርቲ';

  @override
  String get jobFieldOfStudyHint => 'ንኣብነት፡ ኣካውንቲንግ፣ ኮምፒውተር ሳይንስ';

  @override
  String get jobFilter => 'ስራሕቲ መፃረዪ';

  @override
  String get jobFixed => 'ቀዋሚ';

  @override
  String get jobImages => 'ስእልታት';

  @override
  String get jobIndividualPoster => 'ውልቀ ሰብ';

  @override
  String get jobJob => 'ስራሕ';

  @override
  String get jobJobCategory => 'ዓይነት ስራሕ';

  @override
  String get jobJobDetails => 'ዝርዝር ስራሕ';

  @override
  String get jobJobTitle => 'መደብ ስራሕ';

  @override
  String get jobJobType => 'ዓይነት ስራሕ';

  @override
  String get jobLocation => 'ቦታ';

  @override
  String get jobLocationImages => 'ስእልታት ቦታ';

  @override
  String get jobLocationPlaceholder => 'ቦታ ድለዩ...';

  @override
  String get jobLogin => 'እተዉ';

  @override
  String get jobLoginRequired => 'ምእታው የድሊ';

  @override
  String get jobMetaDescription => 'ኣብ ዌቭማርት ዝበለፁ ስራሕቲ ኣብ ኢትዮጵያ ምርካብ።';

  @override
  String get jobMyJobs => 'ናተይ ስራሕቲ';

  @override
  String get jobNegotiable => 'ብድርድር';

  @override
  String get jobNoDeadline => 'መወዳእታ ዕለት የለን';

  @override
  String get jobNoEducationAdded => 'ፍሉይ ናይ ትምህርቲ መስፈርቲ ኣይተወሰኸን።';

  @override
  String get jobNoExperienceAdded => 'ፍሉይ ናይ ስራሕ ተመክሮ መስፈርቲ ኣይተወሰኸን።';

  @override
  String get jobNoPhotos => 'ስእሊ የለን';

  @override
  String get jobNoResultsDescription => 'ምስ መዐቀኒኹም ዝሰማማዕ ስራሕ ክንረክብ ኣይከኣልናን።';

  @override
  String get jobNoResultsTitle => 'ዝተረኽበ ስራሕ የለን';

  @override
  String get jobPhotos => 'ስእልታት';

  @override
  String get jobPositions => 'መደባት ስራሕ';

  @override
  String get jobPostingAsCompany => 'ብሽም ትካል ዲኹም ትለጥፉ ዘለኹም?';

  @override
  String get jobRange => 'ወሰን መሃያ';

  @override
  String get jobRequirements => 'መዐቀኒታት';

  @override
  String get jobSalaryAndReqs => 'መሃያን መዐቀኒታትን';

  @override
  String get jobSalaryMax => 'ዝለዓለ መሃያ';

  @override
  String get jobSalaryMin => 'ዝተሓተ መሃያ';

  @override
  String get jobSalaryPerAgreement => 'ብስምምነት';

  @override
  String get jobSalaryType => 'ዓይነት መሃያ';

  @override
  String get jobSelect => 'ምረፁ';

  @override
  String get jobSimilarJobs => 'ተመሳሳሊ ስራሕቲ';

  @override
  String get jobSpecificLocation => 'ትኽክለኛ ቦታ';

  @override
  String get jobSubmit => 'ኣቕርቡ';

  @override
  String get jobTypeContract => 'ኮንትራት';

  @override
  String get jobTypeFullTime => 'ሙሉእ ግዘ';

  @override
  String get jobTypeInternship => 'ልምምድ';

  @override
  String get jobTypePartTime => 'ትርፊ ግዘ';

  @override
  String get jobUpdate => 'ኣሐድሱ';

  @override
  String get jobValidYearsRequired => 'ቅኑዕ ዓመታት ኣእትዉ (ንኣብነት 2)';

  @override
  String get jobYearsOfExperience => 'ዓመታት ተመክሮ';

  @override
  String get jobContactEmployer => 'ኣስራሒ ረኽቡ';

  @override
  String get jobCall => 'ደውሉ';

  @override
  String get jobCallHint => 'ንኣስራሒ ንምድዋል ጠውቑ';

  @override
  String get jobWhatsapp => 'WhatsApp';

  @override
  String get jobWhatsappHint => 'ብዋትስኣፕ ኣዘራርቡ';

  @override
  String get jobTelegram => 'Telegram';

  @override
  String get jobTelegramHint => 'ብቴሌግራም ኣዘራርቡ';

  @override
  String get jobSeekerMessage => 'መልእክት';

  @override
  String get homeJobs => 'ስራሕቲ';

  @override
  String get homeSeekers => 'ደለይቲ ስራሕ';

  @override
  String get seekersTitle => 'ደለይቲ ስራሕ';

  @override
  String get seekersNoProfiles => 'ዝኾነ መገለጫ ኣይተረኽበን';

  @override
  String get seekersNoResults => 'ዝኾነ ደላይ ስራሕ ኣይተረኽበን';

  @override
  String get jobSearchPlaceholder => 'ስራሕቲ ድለዩ...';

  @override
  String get jobNotFound => 'ስራሕ ኣይተረኽበን';

  @override
  String get jobRequiredGender => 'ዝድለ ፆታ';

  @override
  String get jobPostingLimitTitle => 'ናይ ምልጣፍ ስራሕ ገደብኩም በፂሑ';

  @override
  String get jobPostingLimitSubtitle =>
      'ገደብኩም በፂሕኩም ኣለኹም። ተወሳኺ ስራሕ ንምልጣፍ ፓኬጅኩም ኣማሓይሹ።';

  @override
  String get seekerProfileDetails => 'ዝርዝር መገለጫ';

  @override
  String get seekerExperience => 'ተመክሮ';

  @override
  String get seekerNoEducationAdded => 'ክሳብ ሕጂ ናይ ትምህርቲ መረጋገፂ ኣይተወሰኸን።';

  @override
  String get seekerNoExperienceAdded => 'ክሳብ ሕጂ ናይ ስራሕ ታሪኽ ኣይተወሰኸን።';

  @override
  String get seekerNoBio => 'ዝኾነ መግለጺ ኣይተረኸበን።';

  @override
  String get seekerAboutBio => 'ብዛዕባይ';

  @override
  String get seekerNoWorkExperience => 'ናይ ስራሕ ተመክሮ ኣይተዘርዘረን።';

  @override
  String get seekerPdfDocument => 'ናይ PDF ሰነድ';

  @override
  String get seekerVideo => 'ቪዲዮ';

  @override
  String get seekerWaveMartOptions => 'ኣማራጺታት WaveMart';

  @override
  String get seekerContactOptionsSubtitle =>
      'ምስቲ ደላይ ስራሕ ኣብ ውሽጢ መተግበሪ ብቐጥታ መልእኽቲ ተለዋወጡ';

  @override
  String get listingWaveMartOptions => 'ኣማራጺታት WaveMart';

  @override
  String get listingMessageSeller => 'መልእክት';

  @override
  String seekerYearsExp(String years) {
    return '$years ዓመት ተመክሮ';
  }

  @override
  String seekerYearsTotal(String years) {
    return 'ጠቕላላ $years ዓመት';
  }

  @override
  String get seekerMyProfile => 'ናተይ ናይ ስራሕ ፕሮፋይል';

  @override
  String get seekerFullName => 'ምሉእ ስም';

  @override
  String get seekerProfessionalTitle => 'ሞያዊ መዓርግ';

  @override
  String get seekerMakePublic => 'ናይ ስራሕ ፕሮፋይልኩም ይፋዊ ግበሩ';

  @override
  String get seekerSaveProfile => 'ፕሮፋይልኩም ዓቕቡ';

  @override
  String get seekerProfileSaved => 'ፕሮፋይል ብዓወት ተመዝጊቡ';

  @override
  String get seekerCv => 'ሲቪ';

  @override
  String get seekerUploadCv => 'ሲቪ ኣእትዉ (ኣማራጺ)';

  @override
  String get seekerViewCv => 'ሲቪ ርኣዩ';

  @override
  String get listingPerDay => '/ መዓልቲ';

  @override
  String get listingPerMonth => '/ ወርሒ';

  @override
  String get listingPerYear => '/ ዓመት';

  @override
  String get searchUnder15K => 'ትሕቲ 15 ሺሕ';

  @override
  String get search15K30K => '15 ሺሕ - 30 ሺሕ';

  @override
  String get search30K60K => '30 ሺሕ - 60 ሺሕ';

  @override
  String get search60K100K => '60 ሺሕ - 100 ሺሕ';

  @override
  String get search100KPlus => '100 ሺሕ+';

  @override
  String get listingTypeNotEditable => 'ዓይነት ምዝገባ ድሕሪ ምፍጣሩ ክቀያየር ኣይክእልን';

  @override
  String get searchArea => 'ስፍሓት (ሜ²)';

  @override
  String get searchAreaMin => 'ትሑት ስፍሓት';

  @override
  String get searchAreaMax => 'ላዕለዋይ ስፍሓት';

  @override
  String get searchPriceMin => 'ትሑት ዋጋ';

  @override
  String get searchPriceMax => 'ላዕለዋይ ዋጋ';

  @override
  String get searchCustom => 'ብሕታዊ';

  @override
  String get searchSalaryMin => 'ትሑት ደሞዝ (ብር)';

  @override
  String get searchSeekersPlaceholder => 'ደለይቲ ስራሕ ድለ...';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ውጽኢታት',
      one: '1 ውጽኢት',
      zero: 'ውጽኢት ኣይተረኽበን',
    );
    return '$_temp0';
  }

  @override
  String get searchValidationNumber => 'ቅኑዕ ቁጽሪ ኣእቱ';

  @override
  String get searchValidationRange => 'ትሑት ካብ ላዕለዋይ ንእሽቶ ክኸውን ኣለዎ';

  @override
  String get transmissionManual => 'ብኢድ';

  @override
  String get transmissionAutomatic => 'ኣውቶማቲክ';

  @override
  String get transmissionSemiAutomatic => 'ፈረቕ ኣውቶማቲክ';

  @override
  String get fuelPetrol => 'ቤንዚን';

  @override
  String get fuelGasoline => 'ጋዞሊን';

  @override
  String get fuelDiesel => 'ናፍጣ';

  @override
  String get fuelHybrid => 'ሃይብሪድ';

  @override
  String get fuelElectric => 'ኤሌክትሪክ';

  @override
  String get rentalPeriodDay => 'ብመዓልቲ';

  @override
  String get rentalPeriodMonth => 'ብወርሒ';

  @override
  String get rentalPeriodYear => 'ብዓመት';
}
