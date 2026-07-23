import '../l10n/app_localizations.dart';

const vehicleMakesByCategory = <String, List<String>>{
  'car': [
    'Toyota', 'Nissan', 'Honda', 'Mitsubishi', 'Hyundai',
    'Suzuki', 'Kia', 'Mazda', 'Isuzu', 'Mercedes-Benz',
    'BMW', 'Volkswagen', 'Ford', 'Chevrolet', 'Land Rover',
    'Jeep', 'Lexus', 'Audi', 'Volvo', 'Range Rover',
    'Daihatsu', 'Subaru', 'Fiat', 'Peugeot', 'Renault',
    'Maruti', 'Tata', 'Mahindra',
  ],
  'motorcycle': [
    'Honda', 'Yamaha', 'Suzuki', 'Kawasaki', 'BMW',
    'KTM', 'Ducati', 'Harley-Davidson', 'Bajaj', 'TVS',
    'Hero', 'Royal Enfield', 'Vespa', 'Piaggio', 'Aprilia',
  ],
  'bicycle': [
    'Trek', 'Giant', 'Specialized', 'Cannondale', 'Merida',
    'Scott', 'Cube', 'Bianchi', 'GT', 'Raleigh',
    'Schwinn', 'Hero', 'Atlas',
  ],
  'construction_equipment': [
    'Caterpillar', 'Komatsu', 'Hitachi', 'Volvo CE', 'JCB',
    'Liebherr', 'Doosan', 'XCMG', 'SANY', 'Kobelco',
    'Hyundai CE', 'Terex', 'Bobcat', 'John Deere', 'Case',
  ],
};

const vehicleModelsByCategoryMake = <String, Map<String, List<String>>>{
  'car': {
    'Toyota': ['Corolla', 'Camry', 'Yaris', 'Hilux', 'Land Cruiser', 'RAV4', 'Vitz', 'Premio', 'Noah', 'Hiace', 'Prado', 'Fortuner'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Fit', 'City', 'Odyssey', 'Stepwgn'],
    'Nissan': ['Sunny', 'Altima', 'Patrol', 'X-Trail', 'Pathfinder', 'Navara', 'Juke'],
    'Mitsubishi': ['Pajero', 'Lancer', 'Montero', 'Outlander', 'Delica', 'Mirage'],
    'Suzuki': ['Swift', 'Alto', 'Vitara', 'Jimny', 'S-Cross', 'Celerio', 'Ertiga'],
    'Hyundai': ['Elantra', 'Tucson', 'Sonata', 'Santa Fe', 'i10', 'i20', 'Grand i10'],
    'Kia': ['Sportage', 'Sorento', 'Rio', 'Optima', 'Cerato', 'Picanto'],
    'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Polo', 'Beetle', 'Jetta'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE', 'A-Class', 'G-Class'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5', '7 Series', 'X1', 'X6'],
    'Ford': ['Escape', 'Explorer', 'Focus', 'Ranger', 'Mustang', 'F-150'],
    'Chevrolet': ['Cruze', 'Malibu', 'Tahoe', 'Trailblazer', 'Camaro'],
    'Isuzu': ['D-Max', 'MU-X', 'Forward', 'Elf'],
    'Mazda': ['CX-5', 'Mazda3', 'Mazda6', 'BT-50', 'CX-9'],
    'Subaru': ['Forester', 'Outback', 'Impreza', 'Legacy', 'XV'],
    'Lexus': ['RX', 'ES', 'NX', 'LX', 'GX'],
    'Land Rover': ['Range Rover', 'Discovery', 'Defender', 'Evoque', 'Velar'],
    'Peugeot': ['205', '206', '307', '308', 'Partner', '3008'],
    'Renault': ['Clio', 'Megane', 'Logan', 'Duster', 'Sandero', 'Fluence'],
    'Fiat': ['500', 'Punto', 'Doblo', 'Panda', 'Uno'],
  },
  'motorcycle': {
    'Honda': ['CBR', 'CB', 'CRF', 'Africa Twin', 'Gold Wing', 'Shadow', 'Rebel', 'X-ADV', 'PCX', 'Wave'],
    'Yamaha': ['MT', 'YZF', 'R1', 'R6', 'R3', 'WR', 'XT', 'Ténéré', 'NMax', 'Aerox'],
    'Suzuki': ['GSX-R', 'GSX-S', 'V-Strom', 'Hayabusa', 'SV650', 'DR-Z', 'Burgman'],
    'Kawasaki': ['Ninja', 'Z', 'Versys', 'KLR', 'Vulcan', 'KLX'],
    'BMW': ['S 1000', 'R 1250', 'K 1600', 'F 850', 'G 310'],
    'KTM': ['Duke', 'RC', 'Adventure', 'EXC'],
    'Ducati': ['Panigale', 'Monster', 'Multistrada', 'Scrambler', 'Streetfighter'],
    'Harley-Davidson': ['Street', 'Sportster', 'Softail', 'Touring', 'CVO'],
    'Bajaj': ['Pulsar', 'Platina', 'Avenger', 'Dominar', 'Discover'],
    'TVS': ['Apache', 'Star City', 'Sport', 'Jupiter'],
    'Hero': ['Splendor', 'Passion', 'HF Deluxe', 'Glamour'],
    'Royal Enfield': ['Classic 350', 'Meteor 350', 'Himalayan', 'Interceptor 650', 'Continental GT'],
    'Vespa': ['Primavera', 'Sprint', 'GTS'],
    'Piaggio': ['Liberty', 'Zip', 'MP3'],
    'Aprilia': ['RS', 'Tuono', 'Shiver', 'SR'],
  },
  'bicycle': {
    'Trek': ['Marlin', 'FX', 'Domane', 'Émonda', 'Madone', 'Dual Sport', 'Mountain', 'Road'],
    'Giant': ['Escape', 'Defy', 'TCR', 'Trinity', 'Reign', 'Anthem', 'XTC'],
    'Specialized': ['Rockhopper', 'Sirrus', 'Allez', 'Tarmac', 'Roubaix', 'Stumpjumper', 'Epic'],
    'Cannondale': ['Trail', 'Quick', 'Synapse', 'CAAD', 'Topstone', 'Scalpel'],
    'Merida': ['Crossway', 'Big Nine', 'Reacto', 'Scultura', 'eOne-SSixty'],
    'Scott': ['Aspect', 'Contessa', 'Addict', 'Spark', 'Scale', 'Genius'],
    'Cube': ['AIM', 'Nature', 'Axial', 'Reaction', 'Stereo', 'Agree', 'Litening'],
    'Bianchi': ['Impulso', 'Infinito', 'Aria', 'Oltre', 'Specialissima'],
    'GT': ['Aggressor', 'Avalanche', 'Force', 'Grade', 'Sensor'],
    'Raleigh': ['Mountain', 'Road', 'Hybrid', 'Electric'],
    'Schwinn': ['Mountain', 'Road', 'Hybrid', 'Cruiser', 'Electric'],
    'Hero': ['Adventure', 'Atlas', 'City', 'Mountain'],
    'Atlas': ['Mountain', 'Road', 'Hybrid', 'City'],
  },
  'construction_equipment': {
    'Caterpillar': ['D6', '320', 'D8', '950', '330', 'M315', 'M320', 'M322', 'MH3026', 'TH514'],
    'Komatsu': ['PC200', 'D155', 'WA380', 'PC300', 'HB365', 'HM400', 'D61', 'WA500'],
    'Hitachi': ['ZX200', 'EX200', 'ZW220', 'ZX300', 'EH4000'],
    'Volvo CE': ['EC220', 'L120', 'A40', 'SD160', 'DD130'],
    'JCB': ['3CX', 'JS220', 'TM320', '540-170', 'Vibromax'],
    'Liebherr': ['R924', 'L586', 'LTM', 'PR736'],
    'Doosan': ['DX225', 'DX300', 'SD300', 'DL420'],
    'XCMG': ['XE215', 'XE305', 'LW500', 'GR215'],
    'SANY': ['SY215', 'SY335', 'SY500', 'STC1000'],
    'Kobelco': ['SK200', 'SK350', 'SK300', 'SK140'],
    'Hyundai CE': ['R220', 'R330', 'HL955', 'HW150'],
    'Terex': ['TX51', 'TR100', 'TA400'],
    'Bobcat': ['E35', 'S650', 'T770', 'MT85'],
    'John Deere': ['210', '310', '410', '510', '610', '710'],
    'Case': ['CX210', 'CX350', 'M Series', 'SR200', 'SV300'],
  },
};

/// Backward-compatible aliases
final carMakes = vehicleMakesByCategory['car']!;
final carModelsByMake = vehicleModelsByCategoryMake['car']!;

List<String> makesForCategory(String category) =>
    vehicleMakesByCategory[category] ?? [];

List<String> modelsForCategoryMake(String category, String make) =>
    vehicleModelsByCategoryMake[category]?[make] ?? [];

String? getFirstModelForMake(String make) =>
    carModelsByMake[make]?.isNotEmpty == true ? carModelsByMake[make]!.first : null;

const vehicleCategories = ['car', 'motorcycle', 'bicycle', 'construction_equipment'];

const bodyTypesByCategory = <String, List<String>>{
  'car': ['sedan', 'SUV', 'hatchback', 'pickup', 'truck', 'van', 'minibus', 'coupe', 'convertible', 'station_wagon', 'other'],
  'motorcycle': ['standard', 'cruiser', 'sport', 'touring', 'dual_sport', 'scooter', 'moped', 'other'],
  'bicycle': ['mountain', 'road', 'hybrid', 'city', 'electric', 'folding', 'other'],
  'construction_equipment': ['excavator', 'bulldozer', 'loader', 'crane', 'forklift', 'roller', 'dumper', 'generator', 'compressor', 'other'],
};

const mileageUnitByCategory = <String, String>{
  'car': 'km',
  'motorcycle': 'km',
  'bicycle': 'km',
  'construction_equipment': 'Hours',
};

const carConditions = ['new', 'used'];

String vehicleCategoryLabel(String category, AppLocalizations l10n) {
  switch (category) {
    case 'car': return l10n.categoryCar;
    case 'motorcycle': return l10n.categoryMotorcycle;
    case 'bicycle': return l10n.categoryBicycle;
    case 'construction_equipment': return l10n.categoryConstructionEquipment;
    default: return category;
  }
}

String conditionLabel(String condition, AppLocalizations l10n) {
  switch (condition) {
    case 'new': return l10n.conditionNew;
    case 'used': return l10n.conditionUsed;
    default: return condition;
  }
}

String bodyTypeLabel(String type, AppLocalizations l10n) {
  return type == 'other' ? l10n.listingOther : type;
}
const carRentalPeriods = ['day', 'month', 'year'];
const carFeatureOptions = ['AC', 'Power Steering', 'Central Locking', 'Power Windows', 'ABS', 'Airbag', 'Sunroof', 'Bluetooth', 'Backup Camera', 'Navigation', 'Cruise Control', 'Leather Seats', 'Alloy Wheels', 'Fog Lights', 'Roof Rack', 'Tow Bar'];

const motorcycleFeatureOptions = ['ABS', 'Top Case', 'Side Panniers', 'Windshield', 'Heated Grips', 'Crash Bars', 'LED Lights', 'USB Charger', 'Alarm System', 'Luggage Rack'];

const bicycleFeatureOptions = ['Front Suspension', 'Rear Suspension', 'Disc Brakes', 'Electric Assist', 'Battery Included', 'Lights', 'Fenders', 'Kickstand', 'Basket', 'Bell', 'Lock Included'];

const constructionFeatureOptions = ['GPS', 'Backup Camera', 'ROPS', 'AC', 'Heated Seat', 'Long Reach Arm', 'Quick Attach', 'Hydraulic Thumb', 'Track vs Wheels', 'Low Hours', 'Service Records'];

List<String> featureOptionsForCategory(String category) {
  switch (category) {
    case 'motorcycle': return motorcycleFeatureOptions;
    case 'bicycle': return bicycleFeatureOptions;
    case 'construction_equipment': return constructionFeatureOptions;
    default: return carFeatureOptions;
  }
}
