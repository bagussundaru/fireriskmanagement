# Fire Risk Assessment Build Script FINAL (REVISED)

Write-Host ">>> STARTING BUILD PROCESS REVISED <<<"

# 1. Setup Env Vars
$env:JAVA_HOME = "C:\Java\jdk-17.0.2"
$env:ANDROID_HOME = "C:\Android"
# Path harus include folder bin dari cmdline-tools latest dan platform-tools
$env:PATH = "$env:JAVA_HOME\bin;C:\Android\cmdline-tools\latest\bin;$env:PATH"

Write-Host "JAVA_HOME: $env:JAVA_HOME"
Write-Host "Checking sdkmanager..."
try {
    sdkmanager --version
}
catch {
    Write-Host "Error: sdkmanager not found in PATH checking C:\Android\cmdline-tools\latest\bin"
    if (Test-Path "C:\Android\cmdline-tools\latest\bin\sdkmanager.bat") {
        Write-Host "Found sdkmanager at absolute path."
        $sdkmanager = "C:\Android\cmdline-tools\latest\bin\sdkmanager.bat"
    }
    else {
        Write-Error "CRITICAL: sdkmanager not found even in absolute path. Re-check extraction."
        exit 1
    }
}

# 2. Install SDK Components with proper piping
Write-Host "Installing Platform Tools & Build Tools (Retry)..."
# PowerShell way to pipe 'y'
$yesVal = "y`ny`ny`ny`ny`ny`n" # Multiple yes just in case
$yesVal | & sdkmanager --sdk_root="C:\Android" "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# 3. Add platform-tools to PATH for Flutter (now it should exist)
$env:PATH = "$env:PATH;C:\Android\platform-tools"
if (-not (Test-Path "C:\Android\platform-tools\adb.exe")) {
    Write-Warning "Platform-tools not found. Installation might have failed."
}

# 4. Config Flutter
Write-Host "Configuring Flutter..."
flutter config --android-sdk C:\Android

# 5. Accept Licenses
Write-Host "Accepting Flutter Licenses..."
$yesVal | flutter doctor --android-licenses

# 6. Build APK
Write-Host "Building APK Release..."
flutter build apk --release

Write-Host ">>> BUILD PROCESS FINISHED <<<"
if (Test-Path "D:\fireriskasesment\fire_risk_flutter\build\app\outputs\flutter-apk\app-release.apk") {
    Write-Host "SUCCESS: APK created at D:\fireriskasesment\fire_risk_flutter\build\app\outputs\flutter-apk\app-release.apk"
    Get-Item "D:\fireriskasesment\fire_risk_flutter\build\app\outputs\flutter-apk\app-release.apk"
}
else {
    Write-Host "ERROR: APK not found."
}
