# WD-DX4000-Installer
## A solderless Debian installer for the WD DX4000. No case removal, soldering or serial ports required!

Work In Progress

---

Credit goes to @1000001101000 for https://github.com/1000001101000/Debian_on_Intel_Terastations/

---

The released version is a prerelease, however it should be suitable for production use. The difference between this prerelease and the intended final product will be automation of certain tasks which usually require manual work, namely:
- LCDProc for LCD control
- Fancontrol
- Automated startup script placement (explained below)

The final installer will also have some useful features like displaying the IP address on the network on the LCD during the installer and showing the current installer status too.

---

To use the latest prerelease, you will want to write (balena Etcher, Win32DiskImager, DD etc) the ISO image to a USB drive and insert it into any of the ports on the back of your DX4000.

Avoid using Rufus to write the image unless you know what you're doing (you need to write raw instead of letting Rufus install a bootloader). Using Rufus without disabling its "assistive" bootloader features will cause incorrect parameters to be specified to boot the installer, resulting in the installer USB not working, or even more likely, it working but the emergency serial console being disabled both on the installer and in the final Debian installation, since the final installation appears to be affected by the installer's boot parameters.

With the DX4000 powered down but plugged in, hold the reset button on the back (for example with a pen. Avoid metal objects) and press the power button. Continue to hold the button until the LCD shows the Loading Recovery message.

The LCD will stay on Loading Recovery for the remainder of the installation as there is no software in the installer to drive the LCD at this time.

Use a tool like Advanced IP Scanner or NMAP to scan your network for the DX4000. It should automatically retrieve an IP address when it has fully started.

Connect via SSH to the IP address of the DX4000 using the SSH CLI or a tool like PuTTY or RoyalTS.

When asked for the details to log in, the username is `installer` and the password is `dx4000`

NOTE: Make sure to enable SSH Server and basic system utilities when prompted to select software. You should probably disable the graphical desktop environment too, as the DX4000 has not video output and will just waste resources. You may wish to install a graphical environment and use VNC or XDRP later.

---

After the install is complete, the system will fail to boot. You must press and hold the reset button again to boot the installer. Log back in.

Go to the bottom of the action list and choose Start shell.

Run the `disk-detect` command to ensure all disk device nodes have been populated.

Mount your installation's boot partition (usually the very first partition on the newly installed disk) and copy `startup.nsh` from the root of the installer USB to the root of your boot partition. You may now reboot and the system should come online on it's own.

---

Notes:

- If you have existing data on your DX4000, please take a backup. I am not liable for any data loss you endure as a result of using this software.
- If you had a stock Windows installation RAID, it should be possible to retain this as MDADM should detect it an use it, as MDADM appears to support Intel Rapid RAID.
- You will need to follow the old guide (the soldered install one, but don't worry, no soldering needed!) for the Fan and LCD setup. Find it at https://github.com/alexhorner/WD-DX000 .
- If you have soldered wires to your DX4000 and want to use the serial console for the install instead of SSH, this has been enabled for you. Soldering to access the serial port is COMPLETELY OPTIONAL for this installer, as this installer is intended to work without even opening your DX4000's cover.
