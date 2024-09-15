import 'package:typesense/typesense.dart';

class TypesenseClient {
  static Client? _instance;

  static Client get instance {
    _instance ??= _createClient();
    return _instance!;
  }

  static Client _createClient() {
    return Client(Configuration(
      'api_key',
      nodes: {
        Node(
          Protocol.https,
          'nodedetails.a1.typesense.net',
          port: 443,
        ),
      },
      numRetries: 3,
      connectionTimeout: const Duration(seconds: 10),
    ));
  }
}
