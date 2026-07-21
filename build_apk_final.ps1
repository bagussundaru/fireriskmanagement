# Fire Risk Assessment Build Script FINAL

Write-Host ">>> STARTING BUILD PROCESS <<<"

# 1. Fix Folder Structure
if (Test-Path "C:\Android\cmdline-tools\cmdline-tools") {
    Write-Host "Renaming cmdline-tools to latest..."
    Rename-Item "C:\Android\cmdline-tools\cmdline-tools" "latest"
}

# 2. Setup Env Vars
$env:JAVA_HOME = "C:\Java\jdk-17.0.2"
$env:ANDROID_HOME = "C:\Android"
$env:PATH = "$env:JAVA_HOME\bin;C:\Android\cmdline-tools\latest\bin;$env:PATH"

Write-Host "JAVA_HOME: $env:JAVA_HOME"
Write-Host "Checking sdkmanager..."
sdkmanager --version

# 3. Install SDK Components
Write-Host "Installing Platform Tools & Build Tools (This may take a while)..."
# Using Echo Y to accept licenses automatically
cmd /c "echo y | sdkmanager --sdk_root=C:\Android ""platform-tools"" ""platforms;android-34"" ""build-tools;34.0.0"""

# 4. Add platform-tools to PATH for Flutter
$env:PATH = "$env:PATH;C:\Android\platform-tools"

# 5. Config Flutter
Write-Host "Configuring Flutter..."
flutter config --android-sdk C:\Android

# 6. Accept Licenses
Write-Host "Accepting Flutter Licenses..."
cmd /c "echo y | flutter doctor --android-licenses"

# 7. Build APK
Write-Host "Building APK Release..."
flutter build apk --release

Write-Host ">>> BUILD PROCESS FINISHED <<<"
if (Test-Path "D:\fireriskasesment\fire_risk_flutter\build\app\outputs\flutter-apk\app-release.apk") {
    Write-Host "SUCCESS: APK created at D:\fireriskasesment\fire_risk_flutter\build\app\outputs\flutter-apk\app-release.apk"
}
else {
    Write-Host "ERROR: APK not found."
}
