import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'morpheme_cubit.dart';

/// A [MorphemeStatePage] is mixin class on [State] purpose
/// to make clean state management combine with [MorphemeCubit]
mixin MorphemeStatePage<T extends StatefulWidget, C extends MorphemeCubit>
    on State<T> {
  /// The cubit where cubit extends [MorphemeCubit]
  late C cubit = setCubit();

  /// Set the cubit must be set in declare mixin [MorphemeStatePage]
  C setCubit();

  /// close cubit on dispose state.
  bool get closeCubitOnDispose => true;

  /// Describes the part of the user interface represented by this widget,
  /// replace [build] for create interface.
  ///
  /// ```dart
  /// @override
  /// Widget buildWidget(BuildContext context) {
  ///   return Scaffold(
  ///     appBar: AppBar(title: Text(context.s.login)),
  ///     body: ListView(
  ///       padding: const EdgeInsets.all(16),
  ///       children: [
  ///         ThirdLoginButton(
  ///           onFacebookPressed: cubit.onLoginWithFacebookPressed,
  ///           onGooglePressed: cubit.onLoginWithGooglePressed,
  ///           onApplePressed: cubit.onLoginWithApplePressed,
  ///         ),
  ///         const MorphemeSpacing.vertical36(),
  ///         const DividerOr(),
  ///         const MorphemeSpacing.vertical36(),
  ///         const LoginWithEmail(),
  ///         const MorphemeSpacing.vertical32(),
  ///         const NewRegister(),
  ///       ],
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  Widget buildWidget(BuildContext context);

  /// Call [initState] for cubit and call [initAfterFirstLayout] after frame completed.
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    cubit.initState(context);
    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) {
        cubit.initAfterFirstLayout(context);
        cubit.initArgument<T>(context, widget);
      }
    });
  }

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cubit.didChangeDependencies(context);
  }

  @mustCallSuper
  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    cubit.didUpdateWidget<T>(context, oldWidget, widget);
  }

  /// Close cubit for clear memory.
  @mustCallSuper
  @override
  void dispose() {
    if (closeCubitOnDispose) cubit.close();
    super.dispose();
  }

  /// Replace build [StatefulWidget] with [buildWidget]
  ///
  /// Create [MultiBlocProvider] for [Cubit] and [Bloc]
  /// after that create [MultiBlocListener] if is not empty list.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<C>.value(value: cubit),
        ...cubit.blocProviders(context),
      ],
      child: Builder(
        builder: (context) {
          cubit.context = context;
          if (cubit.blocListeners(context).isEmpty) {
            return buildWidget(context);
          }
          return MultiBlocListener(
            listeners: cubit.blocListeners(context),
            child: buildWidget(context),
          );
        },
      ),
    );
  }
}
