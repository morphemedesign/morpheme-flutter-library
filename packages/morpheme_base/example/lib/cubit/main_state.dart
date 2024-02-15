part of 'main_cubit.dart';

class MainStateCubit extends Equatable {
  const MainStateCubit({
    required this.counter,
  });

  final int counter;

  MainStateCubit copyWith({
    int? counter,
  }) {
    return MainStateCubit(
      counter: counter ?? this.counter,
    );
  }

  @override
  List<Object?> get props => [counter];
}
