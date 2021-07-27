# mpdpackage

The build.sh script builds a upgrade package for the Music Player Daemon (MPD) for Raspberry Pi on the Raspberry Pi OS operating system (Formally called Raspbian).
As it is an upgrade, the MPD and MPC package and required libraries must already have been installed

To do this run
sudo apt-get install mpd mpc (and if necessary python{3}-mpd)

To build the package:
Edit the build.sh BUILD_DIR to point to the directory where you built the
latest version of MPD using the instructions https://www.musicpd.org/doc/html/user.html

For example:
BUILD_DIR=/home/pi/mpd-0.22.8

The run ./build.sh as user pi.
This will produce a debian package called mpd_<version>_armhf.deb 
for example mpd_0.22.8_armhf.deb

To install it run
sudo dpkg -i mpd_0.22.8_armhf.deb

Bob Rathbone
Web site: www.bobrathbone.com
Email: bob@bobrathbone.com

