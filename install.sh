# -- Install packages
echo "- Updating and Upgrading (this may take a moment)..."
pkg update -y -qq > /dev/null 2>&1
pkg upgrade -y -qq > /dev/null 2>&1
echo "- Action finished"
sleep 0.5
echo "- Installing wget and unzip"
sleep 0.35
pkg install wget unzip -y > /dev/null 2>&1
echo "- Action finished"
sleep 0.35
# -- Check for root
if $(su > /dev/null 2>&1); then
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
termux-setup-storage > /dev/null 2>&1
echo "- Getting zip"
wget -q --show-progress https://github.com/jordanrodrigues168-dev/Lite-Flash/releases/download/Lite-Flash-v1.4.5/Lite-Flash-v1.4.5-release.zip > /dev/null 2>&1

unzip -o Lite-Flash-v1.4.5-release.zip -d "$HOME/lite-flash" > /dev/null 2>&1
echo "- Setup complete"
# -- Add to PATH automatically
if [[ ":$PATH:" != *":$HOME/lite-flash:"* ]]; then
    echo 'export PATH="$PATH:$HOME/lite-flash"' >> ~/.bashrc
    source ~/.bashrc
    echo "- Added to PATH"
fi
chmod +x $HOME/lite-flash/*
