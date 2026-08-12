import 'package:equatable/equatable.dart';

/// BLOC APPROACH — events
///
/// A [Bloc] reacts to explicit, named Events instead of direct method
/// calls. Every possible state transition is declared up front as its
/// own class. This adds boilerplate but gives you a clear, traceable
/// vocabulary of "things that can happen" — useful for larger features,
/// analytics/logging, and event-source-style debugging.
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

class CounterDecremented extends CounterEvent {
  const CounterDecremented();
}

class CounterReset extends CounterEvent {
  const CounterReset();
}
