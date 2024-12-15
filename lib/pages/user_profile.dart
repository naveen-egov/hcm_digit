import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/scrollable_content.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/models/entities/project_beneficiary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hcm_digit/blocs/auth/auth.dart';
import 'package:hcm_digit/data/local_store/secure_store/secure_store.dart';
import 'package:hcm_digit/data/remote_client.dart';
import 'package:hcm_digit/utils/remote_provider.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import '../utils/i18_key_constants.dart' as i18;
import 'package:hcm_digit/router/app_router.dart';
import 'package:hcm_digit/user_profile.dart';
import 'package:hcm_digit/widgets/localized.dart';
import 'package:reactive_forms/reactive_forms.dart';

@RoutePage()
class UserProfilePage extends LocalizedStatefulWidget {
  const UserProfilePage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends LocalizedState<UserProfilePage> {
  UserModel? userData;

  static const _individualNameKey = 'individualName';
  static const _idTypeKey = 'idType';
  static const _idNumberKey = 'idNumber';
  static const _dobKey = 'dob';
  static const _genderKey = 'gender';
  static const _mobileNumberKey = 'mobileNumber';
  bool isDuplicateTag = false;
  static const maxLength = 200;
  final clickedStatus = ValueNotifier<bool>(false);
  DateTime now = DateTime.now();

  @override
  void initState() {
    extractPathParams(html.window.location.href);
    // TODO: implement initState
    if (userData == null) {
    } else {}
    super.initState();
  }

  void extractPathParams(String url) async {
    // Parse the URL
    Uri uri = Uri.parse(url);

 
    // Extract query parameters
    Map<String, String> queryParams = uri.queryParameters;
    if (queryParams.entries.lastOrNull?.value != null) {
      final data = (await postFetchUserInfo(
        queryParams.entries.lastOrNull!.value,
        '_UgkpFCOsqoxsbLfywjXFuVRYZaHeYK6l0GmxMg3Rg8',
        'http://localhost:3000/userprofile',
        'authorization_code',
      ));

      var user = UserModel.fromJson(data);
      setState(() {
        userData = user;
      });
     
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        body: ReactiveFormBuilder(
            form: buildForm,
            builder: (context, form, child) {
              form.control(_individualNameKey).value = userData?.name;
              form.control(_mobileNumberKey).value = userData?.phoneNumber;
              form.control(_genderKey).value = userData?.gender;
              form.control(_dobKey).value = userData?.birthdate;

              return ScrollableContent(
                  footer: DigitCard(
                      child: DigitElevatedButton(
                          child: Text(localizations
                              .translate(i18.common.coreCommonSubmit)),
                          onPressed: () async {
                            final userIndividualId = await LocalSecureStore
                                .instance.userIndividualId;

                            final entity = IndividualModel(
                                email: userData?.email,
                                tenantId: 'mz',
                                dateOfBirth: form.control(_dobKey).value,
                                mobileNumber:
                                    form.control(_mobileNumberKey).value,
                                gender: form
                                            .control(_genderKey)
                                            .value
                                            .toString()
                                            .codeUnitAt(0) ==
                                        'M'
                                    ? Gender.male
                                    : Gender.female,
                                name: NameModel(
                                    givenName:
                                        form.control(_individualNameKey).value),
                                auditDetails: AuditDetails(
                                    createdBy: userIndividualId!,
                                    createdTime:
                                        DateTime.now().millisecondsSinceEpoch),
                                clientReferenceId: const Uuid().v1());

                            // ignore: use_build_context_synchronously
                            final result = await context
                                .read<
                                    RemoteRepository<IndividualModel,
                                        IndividualSearchModel>>()
                                .create(entity);

//                             final response =
//                                 IndividualModelMapper.fromJson(result.data);

//                             final r = ProjectBeneficiaryModel(
//                                 beneficiaryClientReferenceId:
//                                     response.individualId,
//                                 clientReferenceId: Uuid().v1(),
//                                 dateOfRegistration:
//                                     DateTime.now().millisecondsSinceEpoch);
// // ignore: use_build_context_synchronously
//                             await context
//                                 .read<
//                                     RemoteRepository<ProjectBeneficiaryModel,
//                                         ProjectBeneficiarySearchModel>>()
//                                 .create(r);

                          

                       

                            context.router.push(
                              DeliverInterventionRoute(),
                            );
                          })),
                  slivers: [
                    SliverToBoxAdapter(
                        child: DigitCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizations.translate(
                              i18.individualDetails.individualsDetailsLabelText,
                            ),
                            style: theme.textTheme.displayMedium,
                          ),
                          // if (userData?.picture != null)
                          // Image.memory(
                          //     width: MediaQuery.of(context).size.width,
                          //     Uri.parse(userData!.picture).datera!.contentAsBytes()),
                          DigitTextFormField(
                            label: localizations.translate(
                              i18.individualDetails.nameLabelText,
                            ),
                            validationMessages: {
                              "required": (control) {
                                return localizations.translate(
                                  '${i18.individualDetails.nameLabelText}_IS_REQUIRED',
                                );
                              },
                            },
                            textCapitalization: TextCapitalization.none,
                            formControlName: _individualNameKey,
                            isRequired: true,
                            keyboardType: TextInputType.text,
                          ),
                          DigitTextFormField(
                            label: localizations.translate(
                              i18.individualDetails.dobLabelText,
                            ),
                            validationMessages: {
                              "required": (control) {
                                return localizations.translate(
                                  '${i18.individualDetails.dobLabelText}_IS_REQUIRED',
                                );
                              },
                            },
                            textCapitalization: TextCapitalization.none,
                            formControlName: _dobKey,
                            isRequired: true,
                            keyboardType: TextInputType.text,
                          ),
                          DigitTextFormField(
                            label: localizations.translate(
                              i18.individualDetails.genderLabelText,
                            ),
                            validationMessages: {
                              "required": (control) {
                                return localizations.translate(
                                  '${i18.individualDetails.genderLabelText}_IS_REQUIRED',
                                );
                              },
                            },
                            textCapitalization: TextCapitalization.none,
                            formControlName: _genderKey,
                            isRequired: true,
                            keyboardType: TextInputType.text,
                          ),
                          DigitTextFormField(
                            label: localizations.translate(
                              i18.individualDetails.mobileNumberLabelText,
                            ),
                            validationMessages: {
                              "required": (control) {
                                return localizations.translate(
                                  '${i18.individualDetails.mobileNumberInvalidFormatValidationMessage}_IS_REQUIRED',
                                );
                              },
                            },
                            formControlName: _mobileNumberKey,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            textCapitalization: TextCapitalization.none,
                          ),
                        ],
                      ),
                    ))
                  ]);
            }));
  }

  FormGroup buildForm() => fb.group(<String, Object>{
        _individualNameKey: FormControl<String>(
          value: userData?.name,
          validators: [Validators.required],
        ),
        _mobileNumberKey: FormControl<String>(
            validators: [Validators.required], value: userData?.phoneNumber),
        _genderKey: FormControl<String>(
            validators: [Validators.required], value: userData?.gender),
        _dobKey: FormControl<String>(
            validators: [Validators.required], value: userData?.birthdate)
      });
}

class UserModel {
  final String sub;
  final String birthdate;
  final Address address;
  final String gender;
  final String name;
  final String phoneNumber;
  final String email;
  final String picture;

  UserModel({
    required this.sub,
    required this.birthdate,
    required this.address,
    required this.gender,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.picture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      sub: json['sub'] as String,
      birthdate: json['birthdate'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      gender: json['gender'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      picture: json['picture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'birthdate': birthdate,
      'address': address.toJson(),
      'gender': gender,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'picture': picture,
    };
  }
}

class Address {
  final String locality;

  Address({required this.locality});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      locality: json['locality'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locality': locality,
    };
  }
}
