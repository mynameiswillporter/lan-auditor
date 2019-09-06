# How to install Kali on a Raspberry Pi without a screen
I wanted to install Kali on my Rasbperry Pi, but don't have a screen for the pi.
The following is how I did it.

## Environment Notes
I am using the following:
* HP Laptop with Ubuntu 18.04
* Rasbperry Pi 3b+
* SanDisk UltraPlus 32GB

## Instructions
1. Download balenaEtcher: https://www.balena.io/etcher/
2. Download StickyFingers Kali Pi: https://whitedome.com.au/re4son/sticky-fingers-kali-pi/

This is about 8 GB.  I am using a 32GB microSD card.

3. Flash kali pi to the SD Card using balenaEtcher.
4. Remove and reinsert the SD Card
5. Find the mounted SD Card in your `/media` folder

```
william@computer:/media/william/504fe6fa-ccc1-4354-94ea-6b40a85ef0a1$ cd /media
william@computer:/media$ ls -l
total 4
drwxr-x---+ 4 root root 4096 Sep  4 17:00 william
william@computer:/media$ cd william/
william@computer:/media/william$ ls -l
total 20
drwxr-xr-x 21 root    root     4096 May 31  2016 504fe6fa-ccc1-4354-94ea-6b40a85ef0a1
drwxr-xr-x  3 william william 16384 Dec 31  1969 8B48-3EB4
william@computer:/media/william$ cd 504fe6fa-ccc1-4354-94ea-6b40a85ef0a1/
william@computer:/media/william/504fe6fa-ccc1-4354-94ea-6b40a85ef0a1$ ls -l
total 1048684
drwxr-xr-x   2 root root       4096 Sep 22  2018 bin
drwxr-xr-x   2 root root       4096 Mar  8  2016 boot
drwxr-xr-x   4 root root       4096 Mar 15  2016 dev
drwxr-xr-x 142 root root      12288 Sep 22  2018 etc
drwxr-xr-x   4 root root       4096 May 31  2016 home
drwxr-xr-x  15 root root       4096 Sep 22  2018 lib
drwx------   2 root root      16384 Mar 15  2016 lost+found
drwxr-xr-x   2 root root       4096 Mar 15  2016 media
drwxr-xr-x   2 root root       4096 Mar 15  2016 mnt
drwxr-xr-x   4 root root       4096 Jun 23  2016 opt
drwxr-xr-x   2 root root       4096 Mar  8  2016 proc
drwx------   7 root root       4096 Sep 22  2018 root
drwxr-xr-x   7 root root       4096 Mar 15  2016 run
drwxr-xr-x   2 root root      12288 Sep 22  2018 sbin
drwxr-xr-x   2 root root       4096 Mar 15  2016 srv
-rw-------   1 root root 1073741824 May 31  2016 swapfile.img
drwxr-xr-x   2 root root       4096 Jan 18  2016 sys
drwxrwxrwt   7 root root       4096 Sep 22  2018 tmp
drwxr-xr-x  10 root root       4096 Dec  2  2017 usr
drwxr-xr-x  12 root root       4096 Mar 15  2016 var
```

6. Edit Kali's crontab to start the ssh server.

```
sudo vim etc/crontab
```

Add line to start ssh server

```
 * *    * * *   root    dpkg-reconfigure openssh-server
```

*Note: if your SD Card is read-only you may need to flip the hardware write
lock.  If it is still read-only after disabling the hardware write lock you
may need to remount as read-write.*

Remounting as read-write (only if neccesary):
`sudo mount -o remount,rw '/media/your mount location'`

7. Locate the IP address of your kali pi.

Mine was 192.168.1.131

8. SSH to your kali pi using `root:toor`

`ssh root@192.168.1.131`

`toor` is the default password, so be sure to change it!

9. Ensure you are using the full SD Disk.

Even though I have a 32GB SD Card, the flashing process has resulted in only
7.2GB being alotted to me.

```
root@kali-pi:~# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       7.2G  6.0G  743M  90% /
```

So we need to resize the partition to fill the SD card.
First we install `raspi-config`.  This would normally be available
on raspberry pi configurations, but we have kali so...

```
apt-get update
apt install lua5.1 alsa-utils psmisc && apt --fix-broken install

wget https://archive.raspberrypi.org/debian/pool/main/r/raspi-config/raspi-config_20180406+1_all.deb
wget https://archive.raspberrypi.org/debian/pool/main/r/rpi-update/rpi-update_20140705_all.deb
dpkg -i raspi-config_20180406+1_all.deb
dpkg -i rpi-update_20140705_all.deb
```
Now we run `raspi-config`.

This has one of those weird command line gui's so choose `7 Advanced Options` and then `A1 Expand Filesystem`.

Then choose `Reboot`.

Once it reboots, ssh back in and check the disk availability.

```
root@kali-pi:~# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        30G  6.0G   22G  22% /
```

# LAN Auditor
This is where this actually becomes a project. I want the raspberry pi to periodically scan my home network and enumerate devices and vulnerabilities.

To do so, we will install some bash scripts that run nmap on a cronjob and send the detected devices to openvas.

1. Install ansible on your desktop.

We will use ansible to setup files on the running raspberry Pi.  Ansible will set it up over ssh, which we enabled in previous steps.

On Ubunutu 18.04 I run:
```
sudo apt install ansible
sudo apt install sshpass
```

The `sshpass` program is required to ssh using a password with ansible.  
Alternatively you should setup an ssh key.

2. Edit the `infrastructure/ansible/hosts` file in this project to contain the IP address of your Kali raspberry pi.

3. Run the ansible setup:

```
cd infrastructure/ansible
ansible-playbook -i hosts lan-auditor.yml --ask-pass
```

# Using openvas

## Add a new user or change admin password
Add a new user and password:
```
openvasmd --create-user=dookie
openvasmd --user=dookie --new-password=d00ki3!
```

## Sync the NVTs
greenbone-nvt-sync

# Create a virtual env in /opt/lan-auditor
```
cd /opt/lan-auditor
virtualenv -p python3 venv
. venv/bin/activate
apt install -y libffi-dev libssl-dev libxml2-dev libxslt-dev
pip install gvm-tools
```
