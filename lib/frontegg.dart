import 'frontegg_platform_interface.dart';
import 'models/frontegg_state.dart';

class FronteggFlutter {
  final stateChanged = FronteggPlatform.instance.eventChannel.receiveBroadcastStream();

  Future<void> login() async {
    await FronteggPlatform.instance.login();
  }

  Stream<FronteggState> listener() {
    final stream = stateChanged.map((state) {
      return FronteggState.fromMap(state as Map<Object?, Object?>);
    });

    FronteggPlatform.instance.subscribe();
    return stream;
  }
}
