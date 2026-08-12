import 'package:flutter_bloc/flutter_bloc.dart';

/// CUBIT APPROACH
///
/// A [Cubit] is the simpler of the two flutter_bloc building blocks.
/// State changes happen by calling plain methods, which call `emit()`
/// directly. There is no intermediate "event" object and no mapping
/// step — the method IS the state-change trigger.
///
/// Good fit for: simple, self-contained state with a handful of
/// direct actions (toggle, increment, set value, load/success/error).
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  void decrement() => emit(state - 1);

  void reset() => emit(0);
}
