abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For simplicity, assuming always connected
    // In a real app, you would check connectivity
    return true;
  }
}
