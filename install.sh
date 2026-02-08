# -- Functions

ui_printInfo() {
  echo "[Info] $1"
}

ui_printAction() {
  echo "[Action] $1"
}

ui_printSuccess() {
  echo "[Success] $1"
}

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

# -- Start the ADB Server silently

ui_printAction "Starting ADB Server..."

if ! adb start-server > /dev/null 2>&1; then
ui_printErrorDK "Could not start ADB Server!"
fi

ui_printSuccess "Started ADB Server"

# -- Variables

ui_printAction "Verifiying device status..."

if ! adb get-state > /dev/null 2>&1; then
ui_printError "Device not found, not authorized, or in incorrect mode!"
fi

ui_printSuccess "Verified device status as clean"

scriptVersion="v1.0.0-release"

data=$(adb shell "getprop ro.product.marketname; getprop ro.product.model; getprop ro.build.version.release; getprop ro.board.platform; getprop ro.product.cpu.abi; getprop ro.boot.flash.locked" | tr '\n' '|')

deviceName=$(echo $data | cut -d'|' -f1)
deviceModel=$(echo $data | cut -d'|' -f2)
androidVersion=$(echo $data | cut -d'|' -f3)
deviceCPU=$(echo $data | cut -d'|' -f4)
deviceABI=$(echo $data | cut -d'|' -f5)
bootStatus=$(echo $data | cut -d '|' -f6)
rootStatus=$(adb shell command su)


# -- Device Info

echo ""
echo "[Info Section] Target Device Info"
echo "--------------------------------------"
ui_printInfo "Script Version: $scriptVersion"
sleep 0.1

ui_printInfo "Target Device Name: $deviceName"
sleep 0.1

ui_printInfo "Target Device Model: $deviceModel"
sleep 0.1

ui_printInfo "Target Android Version: $androidVersion"
sleep 0.1

ui_printInfo "Target CPU: $deviceCPU"
sleep 0.1

ui_printInfo "Target Device ABI: $deviceABI"
sleep 0.1

echo "--------------------------------------"
read -p "Verify the info above. Press ENTER to start rooting or CTRL+C to abort..."

echo ""

# -- Rooting Process
echo  "-------------------------------------"
ui_printAction "Checking bootloader status..."
if [ "$bootStatus" = "1" ]; then
ui_printError "Bootloader is not unlocked and therefore Root can't be installed! "
fi

ui_printSuccess "Bootloader is unlocked to install Root"

ui_printAction "Rebooting to Bootloader..."
adb reboot bootloader

ui_printAction "Waiting for Fastboot connection..."

until [ -n "$(fastboot devices | awk '{print $1}')" ]; do
  sleep 1
done

ui_printSuccess "Device detected in Fastboot mode!"

cd Images
ui_printAction "Scanning for images..."
bootImg=$(ls boot.img)
initImg=$(ls init_boot.img)
vbmImg=$(ls vbmeta.img)

if [ -n "$initImg" ]; then
    targetPart="init_boot"
    finalImg="$initImg"
elif [ -n "$bootImg" ]; then
    targetPart="boot"
    finalImg="$bootImg"
else
    ui_printErrorDK "No boot or init_boot images found in directory!"
fi

ui_printInfo "Targeting Partition: $targetPart"
ui_printInfo "Selected Image: $finalImg"


if [ "${androidVersion%%.*}" -ge 10 ]; then
    ui_printInfo "Android $androidVersion detected. VBMeta may be required."
    read -p "[Action] Path to vbmeta.img (Leave empty to skip): " vbmetaPath
fi

ui_printAction "Flashing $finalImg to $targetPart..."
fastboot flash "$targetPart" "$finalImg" || ui_printError "Flash failed! Check connection."

if [ -n "$vbmImg" ]; then
    ui_printAction "Found VBMeta. Disabling verification..."
    fastboot --disable-verity --disable-verification flash vbmeta "$vbmImg" || ui_printError "VBMeta flash failed!"
fi

ui_printSuccess "Flashing sequence complete!"
fastboot reboot
echo  "-------------------------------------"

# -- End process
ui_printInfo "Congrats, your device is now rooted!"
ui_printInfo "Go and use all the root features-like modules!"