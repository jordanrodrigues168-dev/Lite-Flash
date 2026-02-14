# -- Install packages
echo "- Updating and Upgrading"
sleep 0.5
pkg update && pkg upgrade > /dev/null 2>&1
echo "- Action finished"
sleep 0.5
echo "- Installing wget"
sleep 0.35
pkg install wget unzip -y > /dev/null 2>&1
echo "- Action finished"
sleep 0.35
# -- Check for root
checkRoot=$(su -c "id -u")
if [[ "$checkRoot" -eq 0 ]]; then
echo "- Found root"
sleep 0.5
echo "- Installing Android Debug Bridge"
sleep 0.35
pkg install android-tools -y > /dev/null 2>&1
echo "- Action finished"
sleep 0.1
else
echo "- Root not found"
echo "- Installing Termux-ADB and Termux-API"
sleep 0.2
curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash > /dev/null 2>&1
echo "- [1/2] Action finished"
sleep 1
pkg install termux-api -y > /dev/null 2>&1
echo "- [2/2] Action finished"
fi
# -- Get zip
echo "- Getting storage permissions"
termux-setup-storage
echo "- Getting zip"
wget -q --show-progress https://github.com/jordanrodrigues168-dev/Lite-Flash/releases/download/Lite-Flash-v1.4.5/Lite-Flash-v1.4.5.zip

unzip -o Lite-Flash-v1.4.5.zip -d "$HOME/lite-flash" > /dev/null
[span_0](start_span)mkdir -p /sdcard/lite-flash/backups[span_0](end_span)
echo "- Setup complete. Run 'sh backup-Images' before flashing."
# -- Add to PATH automatically
if [[ ":$PATH:" != *":$HOME/lite-flash:"* ]]; then
    echo 'export PATH="$PATH:$HOME/lite-flash"' >> ~/.bashrc
    source ~/.bashrc
    echo "- Added to PATH"
fi
chmod +x $HOME/lite-flash/*
