/// Explicit screen state used by every view-model and switched on in the UI.
library;

import '../errors/failure.dart';

sealed class ScreenState<T> {
  const ScreenState();
}

class ScreenLoading<T> extends ScreenState<T> {
  const ScreenLoading();
}

class ScreenData<T> extends ScreenState<T> {
  const ScreenData(this.value);
  final T value;
}

class ScreenEmpty<T> extends ScreenState<T> {
  const ScreenEmpty();
}

class ScreenError<T> extends ScreenState<T> {
  const ScreenError(this.failure);
  final AppFailure failure;
}

extension ScreenStateX<T> on ScreenState<T> {
  R when<R>({
    required R Function() loading,
    required R Function(T value) data,
    required R Function() empty,
    required R Function(AppFailure failure) error,
  }) => switch (this) {
    ScreenLoading<T>() => loading(),
    ScreenData<T>(:final value) => data(value),
    ScreenEmpty<T>() => empty(),
    ScreenError<T>(:final failure) => error(failure),
  };

  T? get valueOrNull => switch (this) {
    ScreenData<T>(:final value) => value,
    _ => null,
  };

  bool get isLoading => this is ScreenLoading<T>;
  bool get hasError => this is ScreenError<T>;
}