# Cubit vs Bloc — Learning Notes

This project implements the **same feature twice** — a simple counter —
once with a `Cubit` and once with a `Bloc`, so the two approaches can be
compared directly rather than abstractly.

## Project layout

```
lib/
  cubit/
    counter_cubit.dart     # Cubit implementation
  bloc/
    counter_event.dart     # Event classes for the Bloc
    counter_bloc.dart      # Bloc implementation
  main.dart                 # Tabbed demo app: Cubit tab + Bloc tab
test/
  counter_cubit_test.dart
  counter_bloc_test.dart
```

## What both have in common

`Cubit` and `Bloc` both come from `flutter_bloc` and both:

- Extend a `BlocBase<State>` and expose a `state` stream the UI can
  listen to.
- Plug into the same widgets: `BlocProvider`, `BlocBuilder`,
  `BlocListener`, `BlocConsumer`, `context.read<T>()`,
  `context.watch<T>()`.
- Are unit-testable in isolation from any widget, using the
  `bloc_test` package's `blocTest` helper (see `test/`).
- Follow the same core rule: **state changes only happen through
  `emit()`**, and only synchronously inside a handler (unless you're
  doing an async `emit.forEach`/`emit.onEach` in a Bloc).

That shared foundation is why switching between them later is mostly
mechanical — the widget layer barely changes.

## Cubit — what it actually is

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}
```

A Cubit is a class with methods. Calling `cubit.increment()` runs code
immediately and calls `emit()`. There's no indirection: the calling
widget invokes a method, and that method decides the new state.

**Learned:** Cubit is essentially "`ChangeNotifier`, but with an
immutable state object and a stream instead of a listener list." It's
the shortest path from "I need some state" to "it's wired into the
UI."

## Bloc — what it actually is

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncremented>((event, emit) => emit(state + 1));
  }
}
```

A Bloc doesn't expose methods to call — it exposes `add(event)`. The
event goes into an internal queue, gets matched to the `on<EventType>`
handler that was registered, and *that* handler decides the new
state. The caller and the state-transition logic are decoupled by the
event object sitting in between.

**Learned:** this indirection is the entire point of Bloc. Because
every transition starts life as a named event object, you get:

- **A single vocabulary of "things that can happen"** in the feature,
  independent of who triggers them (a button, a stream, a deep link,
  another Bloc listening to a `BlocListener`).
- **Testability of "what happens if event X occurs,"** decoupled from
  UI — you can write a `blocTest` that adds an event and asserts the
  resulting state sequence, with zero widgets involved.
- **A hook for async orchestration**: the `emit` passed into a
  handler can be awaited (`await emit.forEach(stream, ...)`), and
  packages like `bloc_concurrency` let you `debounce`/`restartable`
  per-event-type — useful for e.g. search-as-you-type. Cubit has no
  equivalent seam because there's no event to intercept.
- **A natural audit/log point** via `BlocObserver.onEvent`, in addition
  to the `onChange`/`onTransition` hooks both Cubit and Bloc share.

The cost is boilerplate: an event class per action, plus the
registration in the constructor, for logic that in Cubit is a
one-line method.

## Side-by-side

| | Cubit | Bloc |
|---|---|---|
| Trigger | Direct method call | `bloc.add(Event())` |
| Boilerplate | Low (methods only) | Higher (event classes + handlers) |
| Traceability | Only via `onChange` (state diffs) | Via `onEvent` *and* `onChange` (cause + effect) |
| Async orchestration (debounce, streams) | Manual, no built-in seam | First-class via `on<Event>(transformer: ...)` |
| Good for | Small/local state, simple toggles, CRUD-style updates | Multi-source input, complex flows, anything you want to log or replay as discrete actions |
| Learning curve | Lower — feels like plain Dart | Slightly higher — event/state vocabulary to design |

## Justification: which one, when

- **Reached for Cubit by default.** Most local UI state (a counter, a
  form field's validity, a toggle, a simple loading/data/error trio)
  doesn't need a named-event vocabulary — the method call *is* the
  event, and adding one would just be a wrapper around a wrapper.
- **Reach for Bloc when the trigger side is genuinely more complex
  than the state side** — multiple different sources can cause the
  same transition and I want one place that says "here's every way
  this state can change," or when I need to debounce/throttle/replace
  in-flight work per action (e.g. a search box), which Bloc supports
  via event transformers and Cubit does not.
- **Team/debugging factor:** on a larger app, Bloc's event log (via
  `BlocObserver`) is worth the extra classes, because bugs become
  "which event fired, in what state" instead of just "state changed
  from A to B, not sure why."
- flutter_bloc's own docs actually recommend starting with Cubit and
  only upgrading to Bloc when a feature's complexity justifies it —
  the mirrored API (`emit`, `state`, same provider/builder widgets)
  makes that migration mechanical, which this project's two parallel
  implementations demonstrate directly.

## How to run

```bash
flutter pub get
flutter run           # launches the tabbed Cubit-vs-Bloc demo
flutter test          # runs both blocTest suites
```

## Gotchas noted while building this

- `emit()` throws if called after the Cubit/Bloc is `close()`d or
  after a synchronous handler has already returned — state changes
  must happen "in the moment."
- Event classes need `Equatable` (or manual `==`) so that
  `blocTest`'s `expect` list comparisons and Bloc's internal
  deduplication work as expected.
- `BlocProvider` + `context.read<T>()` for one-off actions,
  `BlocBuilder`/`context.watch<T>()` for anything that should rebuild
  on state change — mixing them up is the most common beginner bug in
  both approaches.
