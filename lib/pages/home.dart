import 'dart:async';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_components/widgets/digit_sync_dialog.dart';
import 'package:digit_data_model/data_model.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hcm_digit/button.dart';
import 'package:hcm_digit/utils/constants.dart';

import 'package:recase/recase.dart';
import 'package:url_launcher/url_launcher.dart';


import '../blocs/app_initialization/app_initialization.dart';
import '../blocs/auth/auth.dart';
import '../blocs/localization/localization.dart';
import '../data/local_store/app_shared_preferences.dart';
import '../data/local_store/no_sql/schema/app_configuration.dart';
import '../data/local_store/no_sql/schema/service_registry.dart';
import '../data/local_store/secure_store/secure_store.dart';
import '../models/entities/roles_type.dart';
import '../router/app_router.dart';

import '../utils/environment_config.dart';
import '../utils/i18_key_constants.dart' as i18;
import '../utils/utils.dart';
import '../widgets/header/back_navigation_help_header.dart';
import '../widgets/home/home_item_card.dart';
import '../widgets/localized.dart';
import '../widgets/showcase/config/showcase_constants.dart';
import '../widgets/showcase/showcase_button.dart';

@RoutePage()
class HomePage extends LocalizedStatefulWidget {
  const HomePage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends LocalizedState<HomePage> {
  bool skipProgressBar = false;
  final storage = const FlutterSecureStorage();
  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  initState() {
    super.initState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
  
    });
    //// Function to set initial Data required for the packages to run

  }

  //  Be sure to cancel subscription after you are done
  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<AuthBloc>().state;
    final localSecureStore = LocalSecureStore.instance;
    if (state is! AuthAuthenticatedState) {
      return Container();
    }
    print(state.userModel);
    final roles = state.userModel.roles.map((e) {
      return e.code;
    });

    if (!(roles.contains(RolesType.distributor.toValue()) ||
        roles.contains(RolesType.registrar.toValue()))) {
      skipProgressBar = true;
    }

    final mappedItems = _getItems(context);

    final homeItems = mappedItems?.homeItems ?? [];
    final showcaseKeys = <GlobalKey>[
      if (!skipProgressBar) homeShowcaseData.distributorProgressBar.showcaseKey,
      ...(mappedItems?.showcaseKeys ?? []),
    ];

    return Scaffold(
      backgroundColor: DigitTheme.instance.colorScheme.surface,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ScrollableContent(
          slivers: [
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return homeItems.elementAt(index);
                },
                childCount: homeItems.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 145,
                childAspectRatio: 104 / 128,
              ),
            ),
          ],
          header: Column(
            children: [
              BackNavigationHelpHeaderWidget(
                showBackNavigation: false,
                showHelp: false,
                showcaseButton: ShowcaseButton(
                  showcaseFor: showcaseKeys.toSet().toList(),
                ),
              ),
      
            ],
          ),
          footer: const PoweredByDigit(
            version: '1'
          ),
          children: const [
            SizedBox(height: kPadding * 2),
            // INFO : Need to add sync bloc of package Here
            
          ],
        ),
      ),
    );
  }
  final OidcConfig oidcConfig = OidcConfig(
                authorizeUri: 'https://esignet.collab.mosip.net/authorize',
                redirectUri: 'http://localhost:3000/userprofile',
                clientId: '_UgkpFCOsqoxsbLfywjXFuVRYZaHeYK6l0GmxMg3Rg8',
                scope: 'openid profile',
              );

   Future<void> _handleTap(BuildContext context) async {
    final validationError = oidcConfig.validateInput();
    if (validationError.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final url = Uri.parse(oidcConfig.buildRedirectURL());
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication, webOnlyWindowName:'_self');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  _HomeItemDataModel? _getItems(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticatedState) {
      return null;
    }

    final Map<String, Widget> homeItemsMap = {
      // INFO : Need to add home items of package Here
      i18.home.fileComplaint:
          homeShowcaseData.distributorFileComplaint.buildWith(
        child: HomeItemCard(
          icon: Icons.announcement,
          label: i18.home.fileComplaint,
          onPressed: () {}
              // context.router.push(const ComplaintsInboxWrapperRoute()),
        ),
      ),



      i18.home.beneficiaryLabel:
          homeShowcaseData.distributorBeneficiaries.buildWith(
        child: HomeItemCard(
          icon: Icons.all_inbox,
          label: i18.home.beneficiaryLabel,
          onPressed: () async {
            _handleTap(context);
            // await context.router.push(const RegistrationDeliveryWrapperRoute());
          },
        ),
      ),

      i18.home.manageStockLabel:
          homeShowcaseData.warehouseManagerManageStock.buildWith(
        child: HomeItemCard(
          icon: Icons.store_mall_directory,
          label: i18.home.manageStockLabel,
          onPressed: () {
            // context.read<AppInitializationBloc>().state.maybeWhen(
            //       orElse: () {},
            //       initialized: (
            //         AppConfiguration appConfiguration,
            //         _,
            //         __,
            //       ) {
            //         context.router.push(ManageStocksRoute());
            //       },
            //     );
          },
        ),
      ),
      i18.home.stockReconciliationLabel:
          homeShowcaseData.wareHouseManagerStockReconciliation.buildWith(
        child: HomeItemCard(
          icon: Icons.menu_book,
          label: i18.home.stockReconciliationLabel,
          onPressed: () {
            // context.router.push(StockReconciliationRoute());
          },
        ),
      ),
  
      i18.home.beneficiaryReferralLabel:
          homeShowcaseData.hfBeneficiaryReferral.buildWith(
        child: HomeItemCard(
          icon: Icons.supervised_user_circle_rounded,
          label: i18.home.beneficiaryReferralLabel,
          onPressed: () async {
            // context.read<AppInitializationBloc>().state.maybeWhen(
            //       orElse: () {},
            //       initialized: (
            //         AppConfiguration appConfiguration,
            //         _,
            //         __,
            //       ) {
            //         context.router.push(SearchReferralReconciliationsRoute());
            //       },
            //     );
          },
        ),
      ),
      i18.home.viewReportsLabel: homeShowcaseData.inventoryReport.buildWith(
        child: HomeItemCard(
          icon: Icons.announcement,
          label: i18.home.viewReportsLabel,
          onPressed: () {
            // context.router.push(InventoryReportSelectionRoute());
          },
        ),
      ),
      i18.home.manageAttendanceLabel:
          homeShowcaseData.manageAttendance.buildWith(
        child: HomeItemCard(
          icon: Icons.fingerprint_outlined,
          label: i18.home.manageAttendanceLabel,
          onPressed: () {
            // context.router.push(const ManageAttendanceRoute());
          },
        ),
      ),


    };

    final Map<String, GlobalKey> homeItemsShowcaseMap = {
      // INFO : Need to add showcase keys of package Here
      i18.home.beneficiaryLabel:
          homeShowcaseData.distributorBeneficiaries.showcaseKey,
      i18.home.manageStockLabel:
          homeShowcaseData.warehouseManagerManageStock.showcaseKey,
      i18.home.stockReconciliationLabel:
          homeShowcaseData.wareHouseManagerStockReconciliation.showcaseKey,

      i18.home.fileComplaint:
          homeShowcaseData.distributorFileComplaint.showcaseKey,
      i18.home.syncDataLabel: homeShowcaseData.distributorSyncData.showcaseKey,
      i18.home.viewReportsLabel: homeShowcaseData.inventoryReport.showcaseKey,
      i18.home.beneficiaryReferralLabel:
          homeShowcaseData.hfBeneficiaryReferral.showcaseKey,
      i18.home.manageAttendanceLabel:
          homeShowcaseData.manageAttendance.showcaseKey,
      i18.home.db: homeShowcaseData.db.showcaseKey,

    };

    final homeItemsLabel = <String>[
      // INFO: Need to add items label of package Here
      i18.home.beneficiaryLabel,
      
      i18.home.manageStockLabel,
i18.home.viewReportsLabel,
i18.home.manageAttendanceLabel,
      
      i18.home.fileComplaint,
      i18.home.stockReconciliationLabel,
      i18.home.beneficiaryReferralLabel,
      
    ];

    final List<String> filteredLabels = homeItemsLabel
        .where((element) =>
            state.actionsWrapper.actions
                .map((e) => e.displayName)
                .toList()
                .contains(element) ||
            element == i18.home.db)
        .toList();

    final showcaseKeys = filteredLabels
        .where((f) => f != i18.home.db)
        .map((label) => homeItemsShowcaseMap[label]!)
        .toList();





    final List<Widget> widgetList =
        filteredLabels.map((label) => homeItemsMap[label]!).toList();

    return _HomeItemDataModel(
      widgetList,
      showcaseKeys
    );
  }


}

// Function to set initial Data required for the packages to run

void loadLocalization(
    BuildContext context, AppConfiguration appConfiguration) async {
  // context.read<LocalizationBloc>().add(
  //     LocalizationEvent.onUpdateLocalizationIndex(
  //         index: appConfiguration.languages!.indexWhere((element) =>
  //             element.value == AppSharedPreferences().getSelectedLocale),
  //         code: AppSharedPreferences().getSelectedLocale!));
}

class _HomeItemDataModel {
  final List<Widget> homeItems;
    final List<GlobalKey> showcaseKeys;
  

  const _HomeItemDataModel(this.homeItems, this.showcaseKeys);
}
