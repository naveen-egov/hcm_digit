import 'package:digit_components/digit_components.dart';
import 'package:digit_data_model/blocs/boundary/boundary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../router/app_router.dart';

/// Wraps the [child] widget with a [BlocListener] that listens to
/// [BoundaryState] changes and navigates to [HomeRoute] when submitted.
class BoundarySelectionWrapper extends StatelessWidget {
  final Widget child;

  const BoundarySelectionWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocListener<BoundaryBloc, BoundaryState>(
        listener: (context, state) {

        },
        child: child,
      );
}
