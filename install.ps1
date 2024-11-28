# An installation script of the agda2hs SDK for Windows.
# Installs GHC, agda2hs and Qt with the necessary libraries and options.

# The original working directory (we'll switch here back in the end):
$ORIGINAL_PWD = $PWD

# GHCup
Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; try { & ([ScriptBlock]::Create((Invoke-WebRequest https://www.haskell.org/ghcup/sh/bootstrap-haskell.ps1 -UseBasicParsing))) -Interactive -DisableCurl } catch { Write-Error $_ }

Write-Host "Please note that the installation of GHC continues in a separate command line window."

$QT_VERSION="6.7.3"

$is_done=$false
while (-not($is_done)) {
    $SDK_PATH = Read-Host -Prompt "Provide the path into which to install resources"

    if (-not(Test-Path "$SDK_PATH" -IsValid)) {
        Write-Error "Invalid path: $SDK_PATH. Try again."
    } elseif (Test-Path "$SDK_PATH" -PathType leaf) {
        Write-Error "Error: the given path points to a file"
    } else {
        # for folders, -Force does _not_ overwrite the existing one
        New-Item -Path "$SDK_PATH" -ItemType Directory -Force
        # conversion to absolute path
        $SDK_PATH = [System.IO.Path]::GetFullPath($SDK_PATH + '\')
        $is_done = $true
    }
}

cd "$SDK_PATH"
git clone "https://github.com/viktorcsimma/agda2hs"
cd agda2hs
git checkout the-agda-sdk
cabal install --overwrite-policy=always


# adding the agda2hs library to the Agda type checker
mkdir "$HOME\AppData\Roaming\agda"
Write-Output "$SDK_PATH\agda2hs\agda2hs.agda-lib"  | Out-File "$HOME\AppData\Roaming\agda\libraries" -Append -Encoding utf8

$TEMP_PATH=[System.IO.Path]::GetTempPath()
$ProgressPreference = 'SilentlyContinue' # this makes Invoke-WebRequest much faster by turning off the progress indicator

cd "$SDK_PATH"

# installing Qt via online installer
Write-Host "Downloading the Qt online installer..."
Invoke-WebRequest -Uri "https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/qt-online-installer-windows-x64-4.8.1.exe" -OutFile "$TEMP_PATH\installer.exe"
cd "$TEMP_PATH"
$version_without_dots = $QT_VERSION.split('.') -join ''   # the version number without dots
.\installer.exe --root "$SDK_PATH\Qt" --no-default-installations --accept-licenses install qt.qt6.${version_without_dots}.win64_llvm_mingw qt.tools.ninja qt.tools.cmake qt.tools.qtcreator_gui

# finally:
cd "$ORIGINAL_PWD"
