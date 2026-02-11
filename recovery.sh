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

# -- Start the ADB Server
ui_printAction "Starting ADB Server..."
if ! adb start-server > /dev/null 2>&1; then
  ui_printErrorDK "Could not start ADB Server!"
fi
ui_printSuccess "Started ADB Server"

# -- Variables and Device Check
ui_printAction "Verifying device status..."
if ! adb get-state > /dev/null 2>&1; then
  ui_printError "Device not found, not authorized, or in incorrect mode!"
fi
ui_printSuccess "Verified device status"

bootStatus=$(adb shell "getprop ro.boot.flash.locked")

# -- Recovery Process
echo "-------------------------------------"
ui_printAction "Checking bootloader status..."
if [ "$bootStatus" = "1" ]; then
  ui_printError "Bootloader is locked! Custom recovery cannot be installed."
fi
ui_printSuccess "Bootloader is unlocked"

ui_printAction "Rebooting to Bootloader..."
adb reboot bootloader

ui_printAction "Waiting for Fastboot connection..."
until [ -n "$(fastboot devices | awk '{print $1}')" ]; do
  sleep 1
done
ui_printSuccess "Device detected in Fastboot mode!"

# -- Flashing Logic
cd Images
ui_printAction "Scanning for recovery image..."
if [ -f "recovery.img" ]; then
    ui_printAction "Flashing recovery.img..."
    fastboot flash recovery recovery.img || ui_printError "Flash failed! Check connection."
    ui_printSuccess "Recovery flashing sequence complete!"
else
    ui_printErrorDK "recovery.img not found in Images directory!"
fi

ui_printAction "Rebooting device..."
fastboot reboot
echo "-------------------------------------"
ui_printInfo "Process complete. You can now boot into your custom recovery."
