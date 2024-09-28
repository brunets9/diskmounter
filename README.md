# 🛠️ Disk Mount Script 🛠️
Welcome to the Disk Mount Script repository! This script simplifies the process of mounting disks on your system and ensures that they are mounted permanently using UUIDs for stable identification, even if the disk name changes between reboots or connections.

## 📋 Overview
This Bash script is designed to streamline the process of mounting a disk to a specific location on your Linux machine, and it ensures that the disk is permanently mounted by updating the /etc/fstab file.

By using this script, you will be able to:

- 🏷️ Mount disks by UUID: Ensure the disk is consistently recognized, regardless of changes to the device name (/dev/sda, /dev/sdb, etc.).
- 🔄 Automatically configure fstab: The script automatically adds an entry in /etc/fstab for permanent mounting.
- 📁 Create mount points: It ensures that the required directories for mounting are created.
- ⚡ (Optional) Configure Samba: The script includes an option to configure Samba to share the mounted disk on the network.
## 🚨 Requirements 🚨
Before running the script, please ensure the following conditions are met:

- The disk must not be mounted elsewhere on the system, such as in /run/media or any other automatic mount points.

    - ℹ️ **Why?**: If the disk is mounted in another location, the script will fail when attempting to mount it in the specified directory. You can use the command umount to unmount the disk if it is mounted.
    ```bash=
    sudo umount /dev/sdX
    ```
- You have sudo privileges to make system-level changes, such as editing /etc/fstab and mounting filesystems.

- The disk to be mounted should already be formatted and recognized by the system.

- The script assumes the disk uses UUID-based identification to ensure stable mounting across reboots.

## 🧩 Installation
No installation is necessary. You only need to clone the repository and execute the script from the terminal.

```bash=
git clone https://github.com/brunets9/diskmounter.git
cd diskmounter
chmod +x disk.sh
```
## 🚀 Usage
- 1. Run the Script:
To run the script, provide the path to the disk or partition you want to mount. This should be the path to the disk device, such as /dev/sda2, or the directory where the disk is located.
    ```bash=
    ./disk.sh /dev/sda2
    ```
- 2. Samba Configuration (Optional):
After running the script, you will be prompted if you wish to configure the mounted disk for network sharing using Samba. Simply enter y for "Yes" or n for "No".

## ⚙️ Features
- UUID-Based Mounting 🏷️
The script ensures that your disk is mounted by UUID, preventing issues caused by disk names changing between reboots or connections.

- Permanent Mounting 🖥️
It automatically adds the correct entry in /etc/fstab so that the disk remains mounted after each reboot.

- Flexible Directory Creation 🗂️
If the mount point directory does not exist (e.g., /srv/sda2), the script will create it for you automatically.

- Samba Integration 🌍
If you wish to share your mounted disk over the network, the script can configure Samba to make it accessible to other devices.

## 🔧 Prerequisites
- Linux-based system (Ubuntu, Debian, etc.)
- Bash shell
- Root privileges to modify system files and mount disks
#### Dependencies:
- **lsblk**: For obtaining disk information.
- **mount**: To mount the disk.
- **(Optional) Samba**: For network sharing configuration.
## ❗ Important Notes
- Unmount Existing Mounts:
Ensure the disk is not mounted before running the script. If the disk is mounted in a temporary location such as /run/media, you will need to unmount it first. The script will not overwrite existing mounts without unmounting them.

- Backup your /etc/fstab:
It is always a good idea to make a backup of your /etc/fstab file before making any changes, in case something goes wrong.

    ```bash=
    sudo cp /etc/fstab /etc/fstab.bak
    ```
- Permissions:
You will need root access to modify system files, so you should run the script with sudo if prompted.

## 🛡️ Security
The script is provided as is, without any warranty. Be cautious when editing critical system files like /etc/fstab. Incorrect entries in this file can prevent your system from booting.

## 📂 Directory Structure
```bash=
diskmounter/
├── README.md
├── disk.sh         # Main script for mounting the disk
└── LICENSE         # MIT License file
```
## 📝 License
This project is licensed under the MIT License. Feel free to use, modify, and distribute it as you like.

