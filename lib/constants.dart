import 'package:flutter_dotenv/flutter_dotenv.dart';

String get host => dotenv.env['API_URL'] ?? 'https://dummyjson.com';