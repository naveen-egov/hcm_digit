import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_components/widgets/digit_project_cell.dart';
import 'package:digit_components/widgets/digit_sync_dialog.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../blocs/auth/auth.dart';
import '../blocs/project_selection/project.dart';
import '../data/local_store/no_sql/schema/project.dart' as project_schema;
import '../router/app_router.dart';
import '../utils/constants.dart';
import '../utils/i18_key_constants.dart' as i18;
import '../widgets/header/back_navigation_help_header.dart';
import '../widgets/localized.dart';

@RoutePage()
class ProjectSelectionPage extends LocalizedStatefulWidget {
  const ProjectSelectionPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<ProjectSelectionPage> createState() => _ProjectSelectionPageState();
}

class _ProjectSelectionPageState extends LocalizedState<ProjectSelectionPage> {
  /// [_selectedProject] is to keep track of the project the user selected.
  /// Primary intention is to use this project during the retry mechanism of a
  /// failing down-sync. At this point, the [ProjectState] has not persisted the
  /// selected project yet
  ProjectModel? _selectedProject;
  DialogRoute? syncDialogRoute;

  @override
  void initState() {
    context.read<ProjectBloc>().add(const ProjectInitializeEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ScrollableContent(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackNavigationHelpHeaderWidget(
              showBackNavigation: false,
              showLogoutCTA: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Text(
                localizations.translate(
                  i18.projectSelection.projectDetailsLabelText,
                ),
                style: theme.textTheme.displayMedium,
              ),
            ),
          ],
        ),
        children: [
          BlocConsumer<ProjectBloc, ProjectState>(
            listener: (context, state) {
              final error = state.syncError;

              if (syncDialogRoute?.isActive ?? false) {
                Navigator.of(context).removeRoute(syncDialogRoute!);
              }

              if (error != null) {
                syncDialogRoute = DialogRoute(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => DigitDialog(
                    options: DigitSyncDialog.getDigitDialog(
                      type: DigitSyncDialogType.failed,
                      label: localizations.translate(
                        i18.projectSelection.syncFailedTitleText,
                      ),
                      primaryAction: DigitDialogActions(
                        label: localizations.translate(
                          i18.projectSelection.retryButtonText,
                        ),
                        action: _selectedProject == null
                            ? null
                            : (context) {
                          if (syncDialogRoute?.isActive ?? false) {
                            Navigator.of(context)
                                .removeRoute(syncDialogRoute!);
                          }
                          context.read<ProjectBloc>().add(
                            ProjectSelectProjectEvent(
                              _selectedProject!,
                            ),
                          );
                        },
                      ),
                      secondaryAction: DigitDialogActions(
                        label: localizations.translate(
                          i18.projectSelection.dismissButtonText,
                        ),
                        action: (context) {
                          if (syncDialogRoute?.isActive ?? false) {
                            Navigator.of(context).removeRoute(syncDialogRoute!);
                          }
                        },
                      ),
                    ),
                  ),
                );

                Navigator.of(context).push(syncDialogRoute!);

                return;
              } else if (state.loading) {
                syncDialogRoute = DialogRoute(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => DigitDialog(
                    options: DigitSyncDialog.getDigitDialog(
                      type: DigitSyncDialogType.inProgress,
                      label: localizations.translate(
                        i18.projectSelection.syncInProgressTitleText,
                      ),
                    ),
                  ),
                );

                Navigator.of(context).push(syncDialogRoute!);
              }

              final selectedProject = state.selectedProject;
        

              if (selectedProject != null) {
 
                final boundary = selectedProject.address?.boundary;

                if (boundary != null) {

                  // triggerLocationTracking(state.selectedProject!);
                  navigateToBoundary(boundary);
                } else {
                  DigitToast.show(
                    context,
                    options: DigitToastOptions(
                      'No boundary data associated with this project.',
                      true,
                      theme,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state.loading) {
                return const Expanded(
                  child: Center(child: Offstage()),
                );
              }

              final projects = state.projects;

              if (projects.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Text(localizations.translate(
                          i18.projectSelection.noProjectsAssigned,
                        )),
                        Text(localizations.translate(
                          i18.projectSelection.contactSysAdmin,
                        )),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: SizedBox(
                            width: 300,
                            child: DigitElevatedButton(
                              onPressed: () {
                                context
                                    .read<AuthBloc>()
                                    .add(const AuthLogoutEvent());
                              },
                              child: Center(
                                child: Text(
                                  localizations.translate(
                                    i18.common.coreCommonOk,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: projects
                    .map(
                      (element) => DigitProjectCell(
                    projectText: element.name,
                    onTap: () {
                      _selectedProject = element;

                      context.read<ProjectBloc>().add(
                        ProjectSelectProjectEvent(element),
                      );
                    },
                  ),
                )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void navigateToBoundary(String boundary) async {
    BoundaryBloc boundaryBloc = context.read<BoundaryBloc>();
    boundaryBloc.add(BoundaryFindEvent(code: boundary));
    try {
      await boundaryBloc.stream
          .firstWhere((element) => element.boundaryList.isNotEmpty);
      if (mounted) {
        context.router.replaceAll([
          // HomeRoute(),
          BoundarySelectionRoute(),
        ]);
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  void triggerLocationTracking(ProjectModel project) async {
    DateTime now = DateTime.now();
    DateTime startAfterTimestamp =
    project.startDateTime!.isBefore(now) ? now : project.startDateTime!;
    DateTime endAfterTimestamp = project.endDateTime!;
  }
}