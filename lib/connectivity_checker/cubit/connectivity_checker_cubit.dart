import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';
import 'package:projectx/connectivity_checker/cubit/connectivity_futures.dart';
part 'connectivity_checker_state.dart';

class ConnectivityCheckerCubit extends Cubit<InternetState> {
  ConnectivityCheckerCubit() : super(InternetInitial());
  late StreamSubscription<ConnectivityResult> _subscription;
  Future<void> connected() async {
    late bool boolFuture;
    try {
      boolFuture = await booleanFuture();
    } catch (e) {
      boolFuture = false;
    }

    if (boolFuture) {
      emit(ConnectedState(message: "Connected"));
    } else {
      emit(NotConnectedState(message: "Not Connected"));
    }
    late StreamSubscription<Future<bool>> subscription;
    var variable = Stream.periodic(const Duration(seconds: 10), (_) async {
      late bool boolFuture;
      try {
        boolFuture = await booleanFuture();
      } catch (e) {
        boolFuture = false;
      }
      return boolFuture;
    });
    subscription = variable.listen((value) async {
      if ((await value)) {
        emit(ConnectedState(message: "Connected"));
      } else {
        emit(NotConnectedState(message: "Not Connected"));
      }
    });
  }

  void notConnected() {
    emit(NotConnectedState(message: "Not Connected"));
  }

  void checkConnection() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        await connected();
      } else {
        notConnected();
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
