import '../utils/native_bridge.dart';
import 'api_client.dart';

class ProxyManager {
  static Future<void> setupFromSystemProxy() async {
    final proxy = await NativeBridge.getSystemProxy();
    if (proxy == null) return;
    final host = proxy['host']?.toString() ?? '';
    final port = int.tryParse(proxy['port']?.toString() ?? '');
    if (host.isEmpty || port == null || port <= 0) return;
    ApiClient.instance.setupProxy(host: host, port: port, allowBadCert: true);
  }
}
