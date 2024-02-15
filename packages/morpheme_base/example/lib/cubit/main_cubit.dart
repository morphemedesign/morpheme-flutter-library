import 'package:equatable/equatable.dart';
import 'package:morpheme_base/morpheme_base.dart';

part 'main_state.dart';

class MainCubit extends MorphemeCubit<MainStateCubit> {
  MainCubit() : super(const MainStateCubit(counter: 0));

  void increment() => emit(state.copyWith(counter: state.counter + 1));
}
