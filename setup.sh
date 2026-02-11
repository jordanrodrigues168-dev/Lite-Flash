# -- Functions
ui_print() {
echo "- $1"
}

ui_print "This script is for installing the required packages"
ui_print "Manual work is required to install Termux-API app"

echo ""

# -- Update and upgrade
ui_print "Updating and upgrading..."
pkg update && pkg upgrade > /dev/null 2>&1
ui_print "Finished updating and upgrading"
echo ""

# -- Install required packages
ui_print "Choose Termux-ADB if you are not rooted"
sleep 1
ui_print "Choose normal ADB if you are rooted"
sleep 1
ui_print "Input must be Normal-ADB or Termux-ADB"
ui_print "Remember to install the Termux-API app for Termux-ADB to work"
sleep 1
read -p "- Install: " adbChoice
if [ "$adbChoice" = "Normal ADB" ]; then
ui_print "Installing ADB and Fastboot..."
sleep 1
pkg install android-tools > /dev/null 2>&1
elif  [ "$adbChoice" = "Termux-ADB" ]; then
ui_print "Installing Termux-ADB and Termux-Fastboot..."
sleep 1
pkg install termux-api  > /dev/null 2>&1
curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash > /dev/null 2>&1
fi

# -- Storage setup
ui_print "Setting up storage access..."
ui_print "Please allow storage permissions if prompted"
termux-setup-storage
echo ""

# -- Final instructions
ui_print "Setup complete"
ui_print "Move back to the main folder using 'cd ..'"
ui_print "Ensure your boot.img or recovery.img is in the Images folder"
ui_print "Then run 'sh install.sh' or 'sh flash_recovery.sh'"