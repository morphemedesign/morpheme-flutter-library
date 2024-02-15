# Morpheme Base

## MorphemeStatePage dan MorphemeCubit (State Management)

To use morpheme base you can use `StatefullWidget` and in the class extends `State` add the mixin `with MorphemeStatePage<T extends StatefullWidget, C extends MorphemeCubit>`.

Methods that need to be overridden `setCubit` and `buildWidget`. the `build` method is deprecated when using `with MorphemeStatepage` and is replaced by `buildWidget`.

### Example

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:onboarding/widgets/widgets.dart';

import '../cubit/onboarding_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with MorphemeStatePage<OnboardingPage, OnboardingCubit> {
  @override
  OnboardingCubit setCubit() => locator();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: cubit.pageController,
            onPageChanged: cubit.onPageChange,
            children: cubit.listOnboarding,
          ),
          const Positioned(
            left: MorphemeSizes.s16,
            right: MorphemeSizes.s16,
            bottom: MorphemeSizes.s16,
            child: OnboardingButton(),
          ),
        ],
      ),
    );
  }
}
```

To use `MorphemeCubit` first we need `State` from the data class which added the `copyWith` method to replace the variables in `State`.

```dart
part of 'onboarding_cubit.dart';

class OnboardingStateCubit extends Equatable {
  const OnboardingStateCubit({
    required this.selected,
    required this.isLast,
  });

  final int selected;
  final bool isLast;

  OnboardingStateCubit copyWith({
    int? selected,
    bool? isLast,
  }) {
    return OnboardingStateCubit(
      selected: selected ?? this.selected,
      isLast: isLast ?? this.isLast,
    );
  }

  @override
  List<Object?> get props => [selected, isLast]; // add all variables to list props
}
```

`MorphemeCubit` is a controller for all the logic that will be used, by creating a class with extends `MorphemeCubit<State>` in the constructor must call `super(State())` to give the initial value to `State`.

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/onboarding.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends MorphemeCubit<OnboardingStateCubit> {
  OnboardingCubit()
      : super(const OnboardingStateCubit( // must call super with value initial state
          selected: 0,
          isLast: false,
        ));
  ...
  @override
  void initState(BuildContext context) async {}

  @override
  void initAfterFirstLayout(BuildContext context) {}

  @override
  List<BlocProvider> blocProviders(BuildContext context) => [];

  @override
  List<BlocListener> blocListeners(BuildContext context) => [];

  @override
  void dispose() {}

  void onPageChange(int value) => emit(state.copyWith(
        selected: value,
        isLast: value == listOnboarding.length - 1,
      ));

 ...
}
```

here's an example of using `MorphemeCubit` with `bloc` to fetch data to api on `login_cubit.dart`.

```dart
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/body/login_body.dart';
import '../bloc/login/login_bloc.dart';

part 'login_state.dart';

class LoginCubit extends MorphemeCubit<LoginStateCubit> {
  LoginCubit({required this.loginBloc}) : super(LoginStateCubit());

  final LoginBloc loginBloc;

  ...

  @override
  List<BlocProvider> blocProviders(BuildContext context) => [
        BlocProvider<LoginBloc>(create: (context) => loginBloc),
      ];

  @override
  List<BlocListener> blocListeners(BuildContext context) => [
        BlocListener<LoginBloc, LoginState>(listener: _listenerLogin),
      ];

  @override
  void dispose() {
    try {
      loginBloc.close();
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  ...

  void onLoginWithEmailPressed(BuildContext context) {
    _setValidate();
    if (_isValidEmailPassword()) {
      _fetchLogin(LoginBody(email: emailKey.text, password: passwordKey.text));
    }
  }

  ...

  void _fetchLogin(LoginBody body) {
    loginBloc.add(FetchLogin(body));
  }

  void _listenerLogin(BuildContext context, LoginState state) {
    if (state is LoginFailed) {
      state.failure.showSnackbar(context);
    } else if (state is LoginSuccess) {
      context.go(MorphemeRoutes.main);
    }
  }
}
```

- `initState` : same method on `StatefullWidget` when doing `initState`.
- `initAfterFirstLayout` : method that is called when the application finishes rendering what is in the `build` widget.
- `blocProviders` : initialize `bloc` to be used in this method.
- `blocListeners` : catch callback of `state bloc` which will be listened when `state bloc` moves to another `state`.
- `dispose` : same method on `StatefullWidget` when doing `dispose`.
- `emit` : method used to change `state` and `reactive` change UI that requires `state`.

for pages that need reactive data from `MorphemeCubit` we can do the extensions `context.select` and `context.watch` and call them in `build`. then as for `context.read` is used to call methods that are in `MorphemeCubit` and are not listeners, for complete documentation it is in [bloclibrary.dev](https://bloclibrary.dev/).

- `context.select` : listen for changes to a selected variable from `MorphemeCubit` or from `State MorphemeCubit`.

```dart
// fetch data from OnboardingCubit
final listOnboarding = context.select((OnboardingCubit element) => element.listOnboarding);

// fetch data from OnboardingCubit state
final selected = context.select((OnboardingCubit element) => element.state.selected);
```

- `context.watch` : listen for `State` changes, usually used to listen for `State` fetch API changes starting from `Initial`, `Loading`, `Succss` & `Failed`.

```dart
final watchLoginState = context.watch<LoginBloc>().state;
...
MorphemeButton.elevated(
  isLoading: watchLoginState is LoginLoading,
  text: context.s.loginWithEmail,
  onPressed: () =>
      context.read<LoginCubit>().onLoginWithEmailPressed(context),
)
```

- `context.read` : usually used for calling methods in `MorphemeCubit`.

```dart
MorphemeButton.elevated(
  isLoading: watchLoginState is LoginLoading,
  text: context.s.loginWithEmail,
  onPressed: () =>
      context.read<LoginCubit>().onLoginWithEmailPressed(context),
)
```

and the following is an example of implementing `state management` on `onboarding_button.dart`

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:onboarding/cubit/onboarding_cubit.dart';
import 'package:onboarding/widgets/indicator.dart';

class OnboardingButton extends StatelessWidget {
  const OnboardingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listOnboarding =
        context.select((OnboardingCubit element) => element.listOnboarding);
    final selected =
        context.select((OnboardingCubit element) => element.state.selected);
    final isLast =
        context.select((OnboardingCubit element) => element.state.isLast);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isLast
            ? const SizedBox(width: 100)
            : MorphemeButton.text(
                isExpand: false,
                text: context.s.skip,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromWidth(100),
                ),
                onPressed: context.read<OnboardingCubit>().onSkipPressed,
              ),
        Indicator(length: listOnboarding.length, selected: selected),
        MorphemeButton.elevated(
          text: isLast ? context.s.started : context.s.next,
          isExpand: false,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromWidth(100),
          ),
          onPressed: () =>
              context.read<OnboardingCubit>().onNextPressed(context),
        ),
      ],
    );
  }
}
```
