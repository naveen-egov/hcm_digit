import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// OIDC Configuration Class
class OidcConfig {
  final String authorizeUri;
  final String redirectUri;
  final String clientId;
  final String scope;
  final String? responseType;
  final String? display;
  final String? prompt;
  final String? nonce;
  final String? state;
  final Map<String, dynamic>? claims;
  final String? claimsLocales;
  final int? maxAge;
  final String? uiLocales;

  OidcConfig({
    required this.authorizeUri,
    required this.redirectUri,
    required this.clientId,
    required this.scope,
    this.responseType,
    this.display,
    this.prompt,
    this.nonce,
    this.state,
    this.claims,
    this.claimsLocales,
    this.maxAge,
    this.uiLocales,
  });

  String validateInput() {
    if (authorizeUri.isEmpty ||
        redirectUri.isEmpty ||
        clientId.isEmpty ||
        scope.isEmpty) {
      return "Required parameter is missing.";
    }
    if (responseType != null && !['code'].contains(responseType)) {
      return "Invalid Response Type.";
    }
    if (display != null && !['page', 'popup', 'touch', 'wap'].contains(display)) {
      return "Invalid display value.";
    }
    if (prompt != null &&
        !['none', 'login', 'consent', 'select_account'].contains(prompt)) {
      return "Invalid prompt value.";
    }
    return '';
  }

  String buildRedirectURL() {
    final uri = Uri.parse(authorizeUri);
    final params = {
      'response_type': responseType ?? 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scope,
      'state': state ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'nonce': nonce,
      if (claims != null) 'claims': claims,
      if (claimsLocales != null) 'claims_locales': claimsLocales,
      if (display != null) 'display': display,
      if (prompt != null) 'prompt': prompt,
      if (maxAge != null) 'max_age': maxAge.toString(),
      if (uiLocales != null) 'ui_locales': uiLocales,
    };
    return Uri.https(uri.authority, uri.path, params).toString();
  }
}

// Button Style Config
class ButtonConfig {
  final String theme;
  final String shape;
  final String type;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final Color textColor;
  final String fontFamily;
  final bool isIconOnly;
  final Map<String, dynamic>? customStyles;

  ButtonConfig({
    this.theme = 'outline',
    this.shape = 'sharpEdges',
    this.type = 'standard',
    this.width = 400.0,
    this.height = 48.0,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.borderRadius = 8.0,
    this.borderWidth = 2.0,
    this.textColor = Colors.black,
    this.fontFamily = 'Arial',
    this.isIconOnly = false,
    this.customStyles,
  });

  BoxDecoration buildDecoration() {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(color: borderColor, width: borderWidth),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  TextStyle buildTextStyle() {
    return TextStyle(
      color: textColor,
      fontFamily: fontFamily,
      fontWeight: FontWeight.bold,
    );
  }
}

// Sign-In Button Widget
class SignInWithEsignetButton extends StatelessWidget {
  final OidcConfig oidcConfig;
  final ButtonConfig buttonConfig;
  final String labelText;
  final String logoPath;

  SignInWithEsignetButton({
    required this.oidcConfig,
    required this.buttonConfig,
    this.labelText = 'Sign in with e-Signet',
    this.logoPath = 'images/esignet_logo.png',
  });

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
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        width: buttonConfig.width,
        height: buttonConfig.height,
        decoration: buttonConfig.buildDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              logoPath,
              width: 24.0,
              height: 24.0,
            ),
            if (!buttonConfig.isIconOnly) ...[
              SizedBox(width: 8.0),
              Text(
                labelText,
                style: buttonConfig.buildTextStyle(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Example Usage
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: SignInWithEsignetButton(
          oidcConfig: OidcConfig(
            authorizeUri: "https://auth.example.com",
            redirectUri: "https://app.example.com/callback",
            clientId: "example-client-id",
            scope: "openid profile email",
            responseType: "code",
          ),
          buttonConfig: ButtonConfig(
            theme: "filledOrange",
            backgroundColor: Colors.orange,
            borderColor: Colors.deepOrange,
            textColor: Colors.white,
          ),
        ),
      ),
    ),
  ));
}
