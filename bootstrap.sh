#!/usr/bin/env bash

# ############################### #
# SET YOUR VENDOR AND DEVICE HERE #
# ############################### #
export VENDOR="xiaomi"
export DEVICE="santoni"
export PORT_ARCH="armv7hl"

# Format second disk for persistent storage
dev='/dev/sdc'
sudo umount "$dev"
printf "o\nn\np\n1\n\n\nw\n" | sudo fdisk "$dev"
sudo mkfs.ext4 "${dev}1"

mkdir /home/vagrant/sfos
echo `blkid /dev/sdc1 | awk '{print$2}' | sed -e 's/"//g'` /home/vagrant/sfos   ext4   noatime,nobarrier   0   0 >> /etc/fstab
mount /home/vagrant/sfos

chmod -R ug+wx /home/vagrant/sfos
chown vagrant:vagrant -R /home/vagrant/sfos

# SAILFISH-HADK
export HOME="/home/vagrant"
export HADK_ROOT="$HOME/sfos"

cat <<EOF > $HOME/.hadk.env
export HADK_ROOT="/home/vagrant/sfos" 
export PLATFORM_SDK_ROOT="\$HADK_ROOT/mer" 
export ANDROID_ROOT="\$HADK_ROOT/android" 
export VENDOR="$VENDOR"
export DEVICE="$DEVICE"
# ARCH conflicts with kernel build 
export PORT_ARCH="$PORT_ARCH"
EOF

cat <<'EOF' >> $HOME/.mersdkubu.profile
function hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; }
export PS1="HABUILD_SDK [\${DEVICE}] $PS1"
hadk
EOF

# PLATFORM_SDK INSTALLATION
export PLATFORM_SDK_ROOT="$HADK_ROOT/mer"
echo "#### Downloading SDK"
wget -q --no-check-certificate http://releases.sailfishos.org/sdk/installers/latest/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 ;
sudo mkdir -p $PLATFORM_SDK_ROOT/sdks/sfossdk ;
echo "#### Unpacking SDK"
sudo tar --numeric-owner -p -xjf Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 -C $PLATFORM_SDK_ROOT/sdks/sfossdk  ;
echo "export PLATFORM_SDK_ROOT=$PLATFORM_SDK_ROOT" >> ~/.bashrc
echo 'alias sfossdk=$PLATFORM_SDK_ROOT/sdks/sfossdk/mer-sdk-chroot' >> ~/.bashrc ;
echo 'PS1="PlatformSDK $PS1"' >> ~/.mersdk.profile ;
echo '[ -d /etc/bash_completion.d ] && for i in /etc/bash_completion.d/*;do . $i;done'  >> ~/.mersdk.profile ;

cat <<'EOF' >> $HOME/.mersdk.profile
function hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; }
hadk
EOF

sudo chown vagrant:vagrant $HOME/.mersdk.profile
sudo chown vagrant:vagrant $HOME/.hadk.env
sudo chown vagrant:vagrant $HOME/.mersdkubu.profile 

# Enter to PLATFORM_SDK
echo "##### Enter to sfossdk"
runuser -l vagrant -c "printf 'c\nc\nsudo zypper -n in android-tools-hadk tar\nexit\n' | /home/vagrant/sfos/mer/sdks/sfossdk/mer-sdk-chroot"

# Installing the corresponding SDK
echo "##### Installing SDKs"
runuser -l vagrant -c "printf 'sdk-assistant create SailfishOS-latest http://releases.sailfishos.org/sdk/latest/Jolla-latest-Sailfish_SDK_Tooling-i486.tar.bz2\ny\nexit' | /home/vagrant/sfos/mer/sdks/sfossdk/mer-sdk-chroot"
runuser -l vagrant -c "printf 'sdk-assistant create ${VENDOR}-${DEVICE}-${PORT_ARCH} http://releases.sailfishos.org/sdk/latest/Jolla-latest-Sailfish_SDK_Target-armv7hl.tar.bz2\ny\nexit' | /home/vagrant/sfos/mer/sdks/sfossdk/mer-sdk-chroot"

# Installing ubuntu chroot (Android build environment)
echo "##### Installing Ubuntu Chroot"
runuser -l vagrant -c "printf 'curl -s -O https://releases.sailfishos.org/ubu/ubuntu-trusty-20180613-android-rootfs.tar.bz2 && sudo mkdir -p /home/vagrant/sfos/mer/sdks/ubuntu && sudo tar --numeric-owner -xjf ubuntu-trusty-20180613-android-rootfs.tar.bz2 -C /home/vagrant/sfos/mer/sdks/ubuntu && exit' | /home/vagrant/sfos/mer/sdks/sfossdk/mer-sdk-chroot"

# Fixing android paths
sudo mkdir -p /home/vagrant/sfos/android
sudo chown -R vagrant /home/vagrant/sfos/android
runuser -l vagrant -c "printf 'sudo ln -s /parentroot/home/vagrant/sfos/android /home/vagrant/sfos/android && sudo chown -R vagrant /home/vagrant/sfos/android && exit' | /home/vagrant/sfos/mer/sdks/sfossdk/mer-sdk-chroot"

# Fixing missing keys
# sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com A1715D88E1DF1F24
# sudo apt-get install imagemagick
# Installing repo utils

