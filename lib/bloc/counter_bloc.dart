import 'package:flutter_bloc/flutter_bloc.dart';

import 'counter_event.dart';

/// BLOC APPROACH — the Bloc itself
///
/// Each event is registered with `on<EventType>()` and mapped to a
/// state transition inside a handler. The handler receives the event
/// and an `emit` callback, which (unlike Cubit) can also be used
/// asynchronously — e.g. `await emit.forEach(stream, ...)` — making
/// Bloc a natural fit for reacting to streams, debounced input, or
/// multiple concurrent async sources.
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncremented>((event, emit) => emit(state + 1));
    on<CounterDecremented>((event, emit) => emit(state - 1));
    on<CounterReset>((event, emit) => emit(0));
  }
}
