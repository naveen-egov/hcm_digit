
# Project Setup Instructions

Follow the steps below to set up the project locally:

## Prerequisites
1. **Install Java 11**  
   - **Linux:**
     ```bash
     sudo apt update
     sudo apt install openjdk-11-jdk
     ```
     Verify installation:
     ```bash
     java -version
     ```
     Expected output: `java version "11.x.x"`

   - **macOS:**
     ```bash
     brew install openjdk@11
     ```
     Add to your shell profile:
     ```bash
     echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
     source ~/.zshrc
     ```

   - **Windows:**  
     Download Java 11 from [AdoptOpenJDK](https://adoptopenjdk.net/) and set the `JAVA_HOME` environment variable to the installation path.

2. **Install Flutter (Version 3.16.5)**  
   - Download Flutter 3.16.5 from the [Flutter Releases Page](https://docs.flutter.dev/development/tools/sdk/releases).
   - Extract the Flutter SDK and add the `flutter/bin` directory to your system PATH.

   Verify the installation:
   ```bash
   flutter --version

3. **Clone the Repository**
   - git clone <repository-url>
   - cd <repository-folder>/hcm_digit
  
     
4.  **Install Dependencies**
    - Install the required Flutter dependencies by running:
   ```bash
flutter pub get
 ```

6.  **Generate Files**
    - Use the build_runner tool to generate necessary files and resolve conflicting outputs:
   ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
```

6. **Run the Application**
   - Run the application in debug mode on the Chrome browser with a custom web port (3000) and disabled web security:
  ```bash
  flutter run -d chrome --debug --web-port=3000 --web-browser-flag "--disable-web-security"
```



