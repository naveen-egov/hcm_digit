import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:digit_components/blocs/location/location.dart';
import 'package:digit_data_model/models/entities/deliver_strategy_type.dart';
import 'package:hcm_digit/blocs/app_initialization/app_initialization.dart';
import 'package:hcm_digit/data/local_store/secure_store/secure_store.dart';
import 'package:hcm_digit/models/app_config/app_config_model.dart';
import 'package:hcm_digit/models/entities/status.dart';
import 'package:hcm_digit/widgets/beneficiary/resource_beneficiary_card.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:digit_components/widgets/scrollable_content.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/enum/app_enums.dart';
import 'package:digit_ui_components/models/DropdownModels.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/theme/spacers.dart';
import 'package:digit_ui_components/widgets/atoms/digit_button.dart';
import 'package:digit_ui_components/widgets/atoms/digit_date_form_input.dart';
import 'package:digit_ui_components/widgets/atoms/digit_dropdown_input.dart';
import 'package:digit_ui_components/widgets/atoms/digit_stepper.dart';
import 'package:digit_ui_components/widgets/atoms/digit_text_form_input.dart';
import 'package:digit_ui_components/widgets/atoms/digit_toast.dart';
import 'package:digit_ui_components/widgets/atoms/labelled_fields.dart';
import 'package:digit_ui_components/widgets/atoms/reactive_fields.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hcm_digit/blocs/delivery_intervention/deliver_intervention.dart';
import 'package:hcm_digit/blocs/project_selection/project.dart';
import 'package:hcm_digit/models/entities/additional_fields_type.dart';
import 'package:hcm_digit/router/app_router.dart';
import 'package:hcm_digit/widgets/header/back_navigation_help_header.dart';
import 'package:uuid/uuid.dart';
import '../../utils/i18_key_constants.dart' as i18;
import 'package:hcm_digit/widgets/localized.dart';
import 'package:reactive_forms/reactive_forms.dart';

@RoutePage()
class DeliverInterventionPage extends LocalizedStatefulWidget {
  final bool isEditing;

  const DeliverInterventionPage({
    super.key,
    super.appLocalizations,
    this.isEditing = false,
  });

  @override
  State<DeliverInterventionPage> createState() =>
      DeliverInterventionPageState();
}

class DeliverInterventionPageState
    extends LocalizedState<DeliverInterventionPage> {
  final List _controllers = [];

  static const _resourceDeliveredKey = 'resourceDelivered';
  static const _quantityDistributedKey = 'quantityDistributed';
  static const _deliveryCommentKey = 'deliveryComment';
  static const _doseAdministrationKey = 'doseAdministered';
  static const _dateOfAdministrationKey = 'dateOfAdministration';
  final clickedStatus = ValueNotifier<bool>(false);
  bool? shouldSubmit = false;

  // Variable to track dose administration status
  bool doseAdministered = false;

  @override
  Widget build(BuildContext context) {
    List<StepperData> generateSteps(int numberOfDoses) {
      return List.generate(numberOfDoses, (index) {
        return StepperData(
          title:
              '${localizations.translate(i18.deliverIntervention.dose)}${index + 1}',
        );
      });
    }

    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);
    // TODO: implement build
    ProjectModel? projectModel;

    List<ProjectProductVariantModel> productVariants = [];
    if (html.window.sessionStorage['selectedProject'] != null) {
      projectModel = ProjectModelMapper.fromJson(
          json.decode(html.window.sessionStorage['selectedProject']!));

      productVariants =
          projectModel.additionalDetails?.projectType?.resources ?? [];
    }

    return BlocProvider(
        create: (_) => ProductVariantBloc(
              const ProductVariantEmptyState(),
              context.read<
                  RemoteRepository<ProductVariantModel,
                      ProductVariantSearchModel>>(),
              context.read<
                  RemoteRepository<ProjectResourceModel,
                      ProjectResourceSearchModel>>(),
            )..add(
                ProductVariantLoadEvent(
                  query: ProjectResourceSearchModel(
                    projectId: [projectModel!.id],
                  ),
                ),
              ),
        lazy: false,
        child: Scaffold(body:
            BlocBuilder<DeliverInterventionBloc, DeliverInterventionState>(
          builder: (context, deliveryInterventionState) {
            return BlocBuilder<ProductVariantBloc, ProductVariantState>(
              builder: (context, productState) {
                return productState.maybeWhen(
                  orElse: () => const Offstage(),
                  fetched: (productVariantsValue) {
                    final variant = productState.whenOrNull(
                      fetched: (productVariants) {
                        return productVariants;
                      },
                    );

                    final int numberOfDoses = (projectModel?.additionalDetails
                                ?.projectType?.cycles?.isNotEmpty ==
                            true)
                        ? (projectModel
                                ?.additionalDetails
                                ?.projectType
                                ?.cycles?[deliveryInterventionState.cycle - 1]
                                .deliveries
                                ?.length) ??
                            0
                        : 0;

                    final r = [
                      {
                        "code": "SUCCESSFUL_DELIVERY",
                        "name": "Delivery Successful"
                      },
                      {
                        "code": "INSUFFICIENT_RESOURCES",
                        "name": "Insufficient Resources"
                      },
                      {
                        "code": "BENEFICIARY_REFUSED",
                        "name": "Beneficiary Refused"
                      },
                      {
                        "code": "BENEFICIARY_ABSENT",
                        "name": "Beneficiary Absent"
                      }
                    ];
                    final deliveryCommentOptions =
                        r.map((e) => DeliveryCommentOptions.fromJson(e));

                    final steps = generateSteps(numberOfDoses);
                    return ReactiveFormBuilder(
                      form: () => buildForm(
                        context,
                        productVariants,
                        variant,
                      ),
                      builder: (context, form, child) {
                        return ScrollableContent(
                          enableFixedButton: true,
                          footer: BlocBuilder<DeliverInterventionBloc,
                              DeliverInterventionState>(
                            builder: (context, state) {
                              return DigitCard(
                                  margin: const EdgeInsets.only(top: spacer2),
                                  padding: const EdgeInsets.all(spacer2),
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: clickedStatus,
                                      builder: (context, bool isClicked, _) {
                                        return BlocBuilder<LocationBloc,
                                                LocationState>(
                                            builder: (context, locationState) {
                                          return Button(
                                            label: localizations.translate(
                                              i18.common.coreCommonSubmit,
                                            ),
                                            type: ButtonType.primary,
                                            size: ButtonSize.large,
                                            mainAxisSize: MainAxisSize.max,
                                            isDisabled: isClicked,
                                            onPressed: () async {
                                              final deliveredProducts =
                                                  ((form.control(_resourceDeliveredKey)
                                                              as FormArray)
                                                          .value
                                                      as List<
                                                          ProductVariantModel?>);
                                              final hasEmptyResources =
                                                  hasEmptyOrNullResources(
                                                      deliveredProducts);
                                              final hasZeroQuantity =
                                                  hasEmptyOrZeroQuantity(form);
                                              final hasDuplicates =
                                                  hasDuplicateResources(
                                                      deliveredProducts, form);

                                              if (hasEmptyResources) {
                                                Toast.showToast(context,
                                                    message: localizations
                                                        .translate(i18
                                                            .deliverIntervention
                                                            .resourceDeliveredValidation),
                                                    type: ToastType.error);
                                              } else if (hasDuplicates) {
                                                Toast.showToast(context,
                                                    message: localizations
                                                        .translate(i18
                                                            .deliverIntervention
                                                            .resourceDuplicateValidation),
                                                    type: ToastType.error);
                                              } else if (hasZeroQuantity) {
                                                Toast.showToast(context,
                                                    message: localizations
                                                        .translate(i18
                                                            .deliverIntervention
                                                            .resourceCannotBeZero),
                                                    type: ToastType.error);
                                              } else {
                                                final task =
                                                    await _getTaskModel(context,
                                                        form: form,
                                                        projectId:
                                                            projectModel!.id,
                                                            );
                                                // ignore: use_build_context_synchronously
                                                context
                                                    .read<
                                                        DeliverInterventionBloc>()
                                                    .add(DeliverInterventionSubmitEvent(
                                                        isEditing: false,
                                                        navigateToSummary:
                                                            false,
                                                        task: task,
                                                        boundaryModel: BoundaryModel(
                                                            code: projectModel
                                                                .boundaryCode)));

                                                // context.router.push(
                                                //   AcknowledgementRoute(),
                                                // );
                                              }
                                            },
                                          );
                                        });
                                      },
                                    ),
                                  ]);
                            },
                          ),
                          header: const Column(children: [
                            BackNavigationHelpHeaderWidget(
                              showHelp: false,
                            ),
                          ]),
                          children: [
                            Column(
                              children: [
                                DigitCard(
                                    margin: const EdgeInsets.all(spacer2),
                                    children: [
                                      Text(
                                        localizations.translate(
                                          i18.deliverIntervention
                                              .deliverInterventionLabel,
                                        ),
                                        style: textTheme.headingXl,
                                      ),
                                      ReactiveWrapperField(
                                        formControlName: _doseAdministrationKey,
                                        builder: (field) => LabeledField(
                                          label: localizations.translate(i18
                                              .deliverIntervention
                                              .currentCycle),
                                          child: DigitTextFormInput(
                                            readOnly: true,
                                            keyboardType: TextInputType.number,
                                            initialValue: form
                                                .control(_doseAdministrationKey)
                                                .value,
                                          ),
                                        ),
                                      ),
                                      if (numberOfDoses > 1)
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.08,
                                          child: DigitStepper(
                                            activeIndex:
                                                deliveryInterventionState.dose -
                                                    1,
                                            stepperList: steps,
                                            inverted: true,
                                          ),
                                        ),
                                      ReactiveWrapperField(
                                        formControlName:
                                            _dateOfAdministrationKey,
                                        builder: (field) => LabeledField(
                                          label: localizations.translate(
                                            i18.deliverIntervention
                                                .dateOfRegistrationLabel,
                                          ),
                                          child: DigitDateFormInput(
                                            readOnly: true,
                                            initialValue: DateFormat(
                                                    'dd MMM yyyy')
                                                .format(form
                                                    .control(
                                                        _dateOfAdministrationKey)
                                                    .value)
                                                .toString(),
                                            confirmText:
                                                localizations.translate(
                                              i18.common.coreCommonOk,
                                            ),
                                            cancelText: localizations.translate(
                                              i18.common.coreCommonCancel,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                DigitCard(
                                    margin: const EdgeInsets.all(spacer2),
                                    children: [
                                      Text(
                                        localizations.translate(
                                          i18.deliverIntervention
                                              .deliverInterventionResourceLabel,
                                        ),
                                        style: textTheme.headingXl,
                                      ),
                                      ..._controllers
                                          .map((e) => ResourceBeneficiaryCard(
                                                form: form,
                                                cardIndex:
                                                    _controllers.indexOf(e),
                                                totalItems: _controllers.length,
                                                onDelete: (index) {
                                                  (form.control(
                                                    _resourceDeliveredKey,
                                                  ) as FormArray)
                                                      .removeAt(
                                                    index,
                                                  );
                                                  (form.control(
                                                    _quantityDistributedKey,
                                                  ) as FormArray)
                                                      .removeAt(
                                                    index,
                                                  );
                                                  _controllers.removeAt(
                                                    index,
                                                  );
                                                  setState(() {
                                                    _controllers;
                                                  });
                                                },
                                              )),
                                      Center(
                                        child: Button(
                                          label: localizations.translate(
                                            i18.deliverIntervention
                                                .resourceAddBeneficiary,
                                          ),
                                          type: ButtonType.tertiary,
                                          size: ButtonSize.medium,
                                          isDisabled:
                                              ((form.control(_resourceDeliveredKey)
                                                                      as FormArray)
                                                                  .value ??
                                                              [])
                                                          .length <
                                                      (productVariants ?? [])
                                                          .length
                                                  ? false
                                                  : true,
                                          onPressed: () async {
                                            addController(form);
                                            setState(() {
                                              _controllers.add(
                                                _controllers.length,
                                              );
                                            });
                                          },
                                          prefixIcon: Icons.add_circle,
                                        ),
                                      ),
                                    ]),
                                DigitCard(
                                    margin: const EdgeInsets.all(spacer2),
                                    children: [
                                      Text(
                                        localizations.translate(
                                          i18.deliverIntervention
                                              .deliveryCommentHeading,
                                        ),
                                        style: textTheme.headingXl,
                                      ),
                                      ReactiveWrapperField(
                                        formControlName: _deliveryCommentKey,
                                        builder: (field) => LabeledField(
                                          label: localizations.translate(
                                            i18.deliverIntervention
                                                .deliveryCommentLabel,
                                          ),
                                          child: DigitDropdown<String>(
                                            items: deliveryCommentOptions
                                                .map((e) => DropdownItem(
                                                      name: localizations
                                                          .translate(e.name),
                                                      code: e.code,
                                                    ))
                                                .toList()
                                              ..sort((a, b) =>
                                                  a.code.compareTo(b.code)),
                                            emptyItemText:
                                                localizations.translate(
                                                    i18.common.noMatchFound),
                                            onChange: (value) {
                                              form
                                                  .control(_deliveryCommentKey)
                                                  .value = value;
                                            },
                                          ),
                                        ),
                                      ),
                                    ]),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        )));
  }

  addController(FormGroup form) {
    (form.control(_resourceDeliveredKey) as FormArray)
        .add(FormControl<ProductVariantModel>());
    (form.control(_quantityDistributedKey) as FormArray)
        .add(FormControl<int>(value: 0, validators: [Validators.min(1)]));
  }

  bool hasEmptyOrZeroQuantity(FormGroup form) {
    final quantityDistributedArray =
        form.control(_quantityDistributedKey) as FormArray;

    // Check if any quantity is zero or null
    return quantityDistributedArray.value?.any((e) => e == 0 || e == null) ??
        true;
  }

  bool hasEmptyOrNullResources(List<ProductVariantModel?> deliveredProducts) {
    final Map<String?, List<ProductVariantModel?>> groupedVariants = {};
    if (deliveredProducts.isNotEmpty) {
      for (final variant in deliveredProducts) {
        final productId = variant?.productId;
        if (productId != null) {
          groupedVariants.putIfAbsent(productId, () => []);
          groupedVariants[productId]?.add(variant);
        }
      }
      bool hasDuplicateProductIdOrNoProductId =
          deliveredProducts.any((ele) => ele?.productId == null);

      return hasDuplicateProductIdOrNoProductId;
    }

    return true;
  }

  bool hasDuplicateResources(
      List<ProductVariantModel?> deliveredProducts, FormGroup form) {
    final resourceDeliveredArray =
        form.control(_resourceDeliveredKey) as FormArray;
    final Set<String?> uniqueProductIds = {};

    for (int i = 0; i < resourceDeliveredArray.value!.length; i++) {
      final productId = deliveredProducts[i]?.id;
      if (productId != null) {
        if (uniqueProductIds.contains(productId)) {
          // Duplicate found
          return true;
        } else {
          uniqueProductIds.add(productId);
        }
      }
    }
    return false;
  }

  Future<TaskModel> _getTaskModel(BuildContext context,
      {required FormGroup form,
      TaskModel? oldTask,
      int? cycle,
      int? dose,
      String? deliveryStrategy,
      String? projectBeneficiaryClientReferenceId,
      AddressModel? address,
      required String projectId}) async {
    final r = await LocalSecureStore.instance.userRequestModel;
    final createdBy = r!.uuid;
    // Initialize task with oldTask if available, or create a new one
    var task = oldTask;
    var clientReferenceId = task?.clientReferenceId ?? IdGen.i.identifier;
    task ??= TaskModel(
      projectBeneficiaryClientReferenceId: projectBeneficiaryClientReferenceId,
      clientReferenceId: clientReferenceId,
      tenantId: 'mz',
      status: Status.administeredSuccess.toValue(),
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: createdBy,
        createdTime: DateTime.now().millisecondsSinceEpoch,
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: createdBy,
        createdTime: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // Extract productvariantList from the form
    final productvariantList =
        ((form.control(_resourceDeliveredKey) as FormArray).value
            as List<ProductVariantModel?>);
    final deliveryComment = form.control(_deliveryCommentKey).value as String?;
    // Update the task with information from the form and other context
    task = task.copyWith(
      projectId: projectId,
      resources: productvariantList
          .map((e) => TaskResourceModel(
                taskclientReferenceId: clientReferenceId,
                clientReferenceId: IdGen.i.identifier,
                productVariantId: e?.id,
                isDelivered: true,
                taskId: task?.id,
                tenantId: 'mz',
              
                rowVersion: oldTask?.rowVersion ?? 1,
                quantity: (((form.control(_quantityDistributedKey) as FormArray)
                        .value)?[productvariantList.indexOf(e)])
                    .toString(),
                clientAuditDetails: ClientAuditDetails(
                  createdBy: createdBy,
                  createdTime: DateTime.now().millisecondsSinceEpoch,
                ),
                auditDetails: AuditDetails(
                  createdBy: createdBy,
                  createdTime: DateTime.now().millisecondsSinceEpoch,
                ),
              ))
          .toList(),
      address: address?.copyWith(
        relatedClientReferenceId: clientReferenceId,
        id: null,
      ),
      status: Status.administeredSuccess.toValue(),
      additionalFields: TaskAdditionalFields(
        version: task.additionalFields?.version ?? 1,
        fields: [
          AdditionalField(
            AdditionalFieldsType.dateOfDelivery.toValue(),
            DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          AdditionalField(
            AdditionalFieldsType.dateOfAdministration.toValue(),
            DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          AdditionalField(
            AdditionalFieldsType.dateOfVerification.toValue(),
            DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          AdditionalField(
            AdditionalFieldsType.cycleIndex.toValue(),
            "0${cycle ?? 1}",
          ),
          AdditionalField(
            AdditionalFieldsType.doseIndex.toValue(),
            "0${dose ?? 1}",
          ),
          AdditionalField(
            AdditionalFieldsType.deliveryStrategy.toValue(),
            DeliverStrategyType.direct.toValue(),
          ),
          if (deliveryComment != null)
            AdditionalField(
              AdditionalFieldsType.deliveryComment.toValue(),
              'No required',
            ),
        ],
      ),
    );

    return task;
  }

  FormGroup buildForm(
    BuildContext context,
    List<ProjectProductVariantModel>? productVariants,
    List<ProductVariantModel>? variants,
  ) {
    print(productVariants);
    print("BUILD FORM");
    final bloc = context.read<DeliverInterventionBloc>().state;

    _controllers.forEachIndexed((index, element) {
      _controllers.removeAt(index);
    });

    // Add controllers for each product variant to the _controllers list.
    if (_controllers.isEmpty) {
      const int r = 1;

      _controllers.addAll(List.generate(r, (index) => index)
          .mapIndexed((index, element) => index));
    }

    return fb.group(<String, Object>{
      _doseAdministrationKey: FormControl<String>(
        value:
            '${localizations.translate(i18.deliverIntervention.cycle)} ${bloc.cycle == 0 ? (bloc.cycle + 1) : bloc.cycle}'
                .toString(),
        validators: [],
      ),
      _deliveryCommentKey: FormControl<String>(
        value: (bloc.tasks?.lastOrNull?.additionalFields?.fields
                        .where((a) =>
                            a.key ==
                            AdditionalFieldsType.deliveryComment.toValue())
                        .toList() ??
                    [])
                .isNotEmpty
            ? bloc.tasks?.lastOrNull?.additionalFields?.fields
                .where((a) =>
                    a.key == AdditionalFieldsType.deliveryComment.toValue())
                .first
                .value
            : '',
        validators: [],
      ),
      _dateOfAdministrationKey:
          FormControl<DateTime>(value: DateTime.now(), validators: []),
      _resourceDeliveredKey: FormArray<ProductVariantModel>(
        [
          ..._controllers.map((e) => FormControl<ProductVariantModel>(
                value: variants != null && variants.length < _controllers.length
                    ? variants.last
                    : (variants != null &&
                            _controllers.indexOf(e) < variants.length
                        ? variants.firstWhereOrNull(
                            (element) =>
                                element.id ==
                                productVariants
                                    ?.elementAt(_controllers.indexOf(e))
                                    .productVariantId,
                          )
                        : null),
              )),
        ],
      ),
      _quantityDistributedKey: FormArray<int>([
        ..._controllers.mapIndexed(
          (i, e) => FormControl<int>(
            value: 0,
            validators: [Validators.min(1)],
          ),
        ),
      ]),
    });
  }
}
