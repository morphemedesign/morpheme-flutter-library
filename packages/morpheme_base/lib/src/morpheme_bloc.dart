import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MorphemeBloc<Event, State> extends Bloc<Event, State> {
  MorphemeBloc(super.initialState);

  @override
  void add(Event event) {
    if (isClosed) return;
    super.add(event);
  }
}
