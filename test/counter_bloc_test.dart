import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_learning/bloc/counter_bloc.dart';
import 'package:flutter_bloc_learning/bloc/counter_event.dart';

void main() {
  group('CounterBloc', () {
    blocTest<CounterBloc, int>(
      'emits [1] when CounterIncremented is added',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(const CounterIncremented()),
      expect: () => [1],
    );

    blocTest<CounterBloc, int>(
      'emits [-1] when CounterDecremented is added',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(const CounterDecremented()),
      expect: () => [-1],
    );

    blocTest<CounterBloc, int>(
      'emits [1, 0] when CounterIncremented then CounterReset are added',
      build: () => CounterBloc(),
      act: (bloc) {
        bloc.add(const CounterIncremented());
        bloc.add(const CounterReset());
      },
      expect: () => [1, 0],
    );
  });
}
