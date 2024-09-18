import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [MorphemeCubit] is abstract class with extend [Cubit] purpose
/// to make clean state management combine with [MorphemeStatePage]
abstract class MorphemeCubit<T> extends Cubit<T> {
  MorphemeCubit(super.initialState);

  /// Used to check if the widget is mounted or not.
  bool mounted = true;
  BuildContext? context;

  /// Called when this object is inserted into the tree.
  void initState(BuildContext context) {}

  /// Called when this after the first time frame has been displayed.
  void initAfterFirstLayout(BuildContext context) {}

  /// Called when after the first time frame has been displayed for initial the current configuration.
  ///
  /// A [State] object's configuration is the corresponding [StatefulWidget]
  /// instance. This property is initialized by the framework before calling
  /// [initState]. If the parent updates this location in the tree to a new
  /// widget with the same [runtimeType] and [Widget.key] as the current
  /// configuration, the framework will update this property to refer to the new
  /// widget and then call [didUpdateWidget], passing the old configuration as
  /// an argument.
  void initArgument<Page>(BuildContext context, Page widget) {}

  /// Called when a dependency of this [State] object changes.
  ///
  /// For example, if the previous call to [build] referenced an
  /// [InheritedWidget] that later changed, the framework would call this
  /// method to notify this object about the change.
  ///
  /// This method is also called immediately after [initState]. It is safe to
  /// call [BuildContext.dependOnInheritedWidgetOfExactType] from this method.
  ///
  /// Subclasses rarely override this method because the framework always
  /// calls [build] after a dependency changes. Some subclasses do override
  /// this method because they need to do some expensive work (e.g., network
  /// fetches) when their dependencies change, and that work would be too
  /// expensive to do for every build.
  void didChangeDependencies(BuildContext context) {}

  /// Called whenever the widget configuration changes.
  ///
  /// If the parent widget rebuilds and request that this location in the tree
  /// update to display a new widget with the same [runtimeType] and
  /// [Widget.key], the framework will update the [widget] property of this
  /// [State] object to refer to the new widget and then call this method
  /// with the previous widget as an argument.
  ///
  /// Override this method to respond when the [widget] changes (e.g., to start
  /// implicit animations).
  ///
  /// The framework always calls [build] after calling [didUpdateWidget], which
  /// means any calls to [setState] in [didUpdateWidget] are redundant.
  ///
  /// {@macro flutter.widgets.State.initState}
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.didUpdateWidget(oldWidget)`.
  void didUpdateWidget<Page>(
      BuildContext context, Page oldWidget, Page widget) {}

  /// Called when a [MorphemeStatePage] is build with [MultiBlocProvider].
  ///
  /// ```dart
  /// @override
  /// List<BlocProvider> blocProviders(BuildContext context) => [
  ///    BlocProvider<LoginBloc>(create: (context) => loginBloc),
  /// ];
  /// ```
  ///
  /// See also:
  ///
  /// * [blocListeners] for define bloc listener in [MultiBlocListener].
  ///
  List<BlocProvider> blocProviders(BuildContext context) => [];

  /// Called when a [MorphemeStatePage] is build with [MultiBlocListener].
  ///
  /// ```dart
  /// @override
  /// List<BlocProvider> blocProviders(BuildContext context) => [
  ///    BlocListener<LoginBloc, LoginState>(listener: _listenerLogin),
  /// ];
  ///
  /// void _listenerLogin(BuildContext context, LoginState state) {
  ///   if (state is LoginFailed) {
  ///     state.failure.showSnackbar(context);
  ///   } else if (state is LoginSuccess) {
  ///     context.go(ConstantRoutes.main);
  ///   }
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [blocProviders] for define bloc provider in [MultiBlocProvider].
  ///
  List<BlocListener> blocListeners(BuildContext context) => [];

  /// Called when this object is closes the instance.
  void dispose() {}

  @override
  void emit(T state) {
    if (isClosed) return;

    super.emit(state);
  }

  /// Closes the instance.
  /// This method should be called when the instance is no longer needed.
  /// Once [close] is called, the instance can no longer be used.
  @override
  Future<void> close() {
    dispose();
    context = null;
    mounted = false;
    return super.close();
  }
}
