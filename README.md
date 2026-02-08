# Lite-Flash
Lite Flash is tool you can use in Termux to root most Android devices easily
Steps before creating the "Images" directory
- You need **Termux** from **F-Droid** or **Github**
- Update and upgrade with **pkg upgrade** and **pkg update**
- Install a package in Termux called "**android-tools**"
- Run this file with **sh** or **bash**
- But first move into the scripts folder
- The **commands** should be like this "**cd /sdcard/Shell**" as an example then "**sh(or bash) install.sh**"
## Next
- In the **directory of the file** create a folder called "**Images**"
- Place your **boot** / **init boot** image as **boot.img** / **init_boot.img** in **Images**
- Same goes for **vbmeta.img**
- The target's **bootloader** MUST be **unlocked** and I cannot say that you can unlock the **target's bootloader** in **Termux**
- You need **Termux-ADB** or **Termux-API** with **libusb** if needed for **non-root hosts**
- With **Termux-API** you can use it to **track** the **USB Connection** and then use another command to allow **Termux-API** and **Termux** to use it

## What if something goes wrong and my target device is in a bootloop?
- Go back to **fastboot** and flash the **stock boot image** in **Termux**
- This is why you should keep a **backup** of the **stock boot image**
- I am not RESPONSIBLE for any **hard-bricks** or **bootloops**
- **BROM** or **EDL** is your safety net if you can go to it but not **fastboot**
- Use **mtkclient** for **BROM**
- **BROM** is for **Mediatek** devices and **EDL** is for **Snapdragon** devices
