import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/counter_bloc.dart';
import 'bloc/counter_event.dart';
import 'cubit/counter_cubit.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cubit vs Bloc',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

/// Two tabs, same feature, two different flutter_bloc approaches —
/// so they can be compared side by side.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cubit vs Bloc'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Cubit'), Tab(text: 'Bloc')],
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (_) => CounterCubit(),
              child: const CubitCounterPage(),
            ),
            BlocProvider(
              create: (_) => CounterBloc(),
              child: const BlocCounterPage(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cubit: methods are called directly on the cubit instance.
class CubitCounterPage extends StatelessWidget {
  const CubitCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CounterCubit>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('CounterCubit', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          BlocBuilder<CounterCubit, int>(
            builder: (context, count) =>
                Text('$count', style: Theme.of(context).textTheme.displayMedium),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: cubit.decrement, child: const Text('-')),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: cubit.increment, child: const Text('+')),
              const SizedBox(width: 16),
              TextButton(onPressed: cubit.reset, child: const Text('reset')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bloc: buttons dispatch Events via `bloc.add(...)` instead of calling
/// methods directly.
class BlocCounterPage extends StatelessWidget {
  const BlocCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CounterBloc>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('CounterBloc', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          BlocBuilder<CounterBloc, int>(
            builder: (context, count) =>
                Text('$count', style: Theme.of(context).textTheme.displayMedium),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => bloc.add(const CounterDecremented()),
                child: const Text('-'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => bloc.add(const CounterIncremented()),
                child: const Text('+'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => bloc.add(const CounterReset()),
                child: const Text('reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
