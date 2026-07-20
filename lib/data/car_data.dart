const carMakes = [
  'Toyota', 'Nissan', 'Honda', 'Mitsubishi', 'Hyundai',
  'Suzuki', 'Kia', 'Mazda', 'Isuzu', 'Mercedes-Benz',
  'BMW', 'Volkswagen', 'Ford', 'Chevrolet', 'Land Rover',
  'Jeep', 'Lexus', 'Audi', 'Volvo', 'Range Rover',
  'Daihatsu', 'Subaru', 'Fiat', 'Peugeot', 'Renault',
  'Maruti', 'Tata', 'Mahindra',
];

const carModelsByMake = <String, List<String>>{
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
};

String? getFirstModelForMake(String make) =>
    carModelsByMake[make]?.isNotEmpty == true ? carModelsByMake[make]!.first : null;

const carTransmissions = ['manual', 'automatic', 'semi-automatic'];
const carBodyTypes = ['sedan', 'SUV', 'hatchback', 'pickup', 'coupe', 'convertible', 'van', 'minibus', 'truck', 'bus', 'other'];
const carFuelTypes = ['gasoline', 'diesel', 'electric', 'hybrid', 'CNG', 'other'];
const carConditions = ['new', 'used'];
const carRentalPeriods = ['day', 'month', 'year'];
const carFeatureOptions = ['AC', 'Power Steering', 'Central Locking', 'Power Windows', 'ABS', 'Airbag', 'Sunroof', 'Bluetooth', 'Backup Camera', 'Navigation', 'Cruise Control', 'Leather Seats', 'Alloy Wheels', 'Fog Lights', 'Roof Rack', 'Tow Bar'];
