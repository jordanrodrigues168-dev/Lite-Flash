# -- Functions
ui_printInfo() { echo "[Info] $1"; }
ui_printAction() { echo "[Action] $1"; }
ui_printSuccess() { echo "[Success] $1"; }

ui_printError() {
  echo "[Error] $1"
  echo "[Error Handler] Killing ADB Server..."
  adb kill-server
  echo "[Error Handler] Aborting..."
  exit 1
}

ui_printErrorDK() {
  echo "[Error] $1"
  echo "[Error Handler] Aborting..."
  exit 1
}

# -- Start the ADB Server
ui_printAction "Starting ADB Server..."
if ! adb start-server > /dev/null 2>&1; then
    ui_printErrorDK "Could not start ADB Server! Ensure android-tools is installed."
fi
ui_printSuccess "Started ADB Server"

# -- Device Verification
ui_printAction "Verifying device status..."
if ! adb get-state > /dev/null 2>&1; then
    [ui_printError "Device not found, not authorized, or in incorrect mode!"
fi
ui_printSuccess "Verified device status as clean"

scriptVersion="v1.0.0-release"

# -- Combined properties check
data=$(adb shell "getprop ro.product.marketname; getprop ro.product.model; getprop ro.build.version.release; getprop ro.board.platform; getprop ro.product.cpu.abi; getprop ro.boot.flash.locked" | tr '\n' '|')

deviceName=$(echo "$data" | cut -d'|' -f1)
deviceModel=$(echo "$data" | cut -d'|' -f2)
androidVersion=$(echo "$data" | cut -d'|' -f3)
deviceCPU=$(echo "$data" | cut -d'|' -f4)
deviceABI=$(echo "$data" | cut -d'|' -f5)
bootStatus=$(echo "$data" | cut -d'|' -f6)

# -- Root Check
if adb shell "which su" > /dev/null 2>&1; then
    rootStatus="Already Rooted"
else
    rootStatus="Not Rooted"
fi

# -- Device Info Display
echo ""
echo "[Info Section] Target Device Info"
echo "--------------------------------------"
ui_printInfo "Script Version: $scriptVersion"
ui_printInfo "Target Device: $deviceName ($deviceModel)"
ui_printInfo "Android Version: $androidVersion"
ui_printInfo "Architecture: $deviceABI"
ui_printInfo "Current Root Status: $rootStatus"
echo "--------------------------------------"
read -p "Verify the info above. Press ENTER to start or CTRL+C to abort..."

# -- Rooting Process
echo "-------------------------------------"
ui_printAction "Checking bootloader status..."
if [ "$bootStatus" = "1" ] || [ "$bootStatus" = "locked" ]; then
    ui_printError "Bootloader is locked! Root cannot be installed."
fi
ui_printSuccess "Bootloader is unlocked"

# -- Ensure Images directory exists before proceeding
if [ ! -d "Images" ]; then
  ui_printErrorDK "Directory 'Images' not found! Please create it and add your files."[span_10](end_span)
fi

ui_printAction "Rebooting to Bootloader..."
adb reboot bootloader /dev/null 2>&1

ui_printAction "Waiting for Fastboot..."
until fastboot devices | grep -q "fastboot"; do
  sleep 1
done
ui_printSuccess "Device detected in Fastboot!"

cd Images
# -- Image detection
bootImg=$(ls boot.img 2>/dev/null)
initImg=$(ls init_boot.img 2>/dev/null)
vbmImg=$(ls vbmeta.img 2>/dev/null)

if [ -n "$initImg" ]; then
    targetPart="init_boot"
    finalImg="$initImg"
elif [ -n "$bootImg" ]; then
    targetPart="boot"
    finalImg="$bootImg"
else
    ui_printErrorDK "No boot or init_boot images found in Images directory!"
fi

ui_printInfo "Targeting Partition: $targetPart"

# -- Handle VBMeta for Android 10+
if [ "${androidVersion%%.*}" -ge 10 ]; then
    ui_printInfo "Android $androidVersion detected."
    if [ -z "$vbmImg" ]; then
        ui_printInfo "Note: No vbmeta.img found in folder. Verification won't be disabled."
    fi
fi

ui_printAction "Flashing $finalImg..."
fastboot flash "$targetPart" "$finalImg" || ui_printError "Flash failed!"

if [ -n "$vbmImg" ]; then
    ui_printAction "Flashing VBMeta and disabling verification..."
    fastboot --disable-verity --disable-verification flash vbmeta "$vbmImg" || ui_printError "VBMeta flash failed!"
fi

ui_printSuccess "Flashing complete!"
fastboot reboot
echo "-------------------------------------"
ui_printInfo "Congrats! Process finished."
