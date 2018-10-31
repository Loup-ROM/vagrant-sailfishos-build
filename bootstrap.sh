#!/usr/bin/env bash

# Format second disk for persistent storage
dev='/dev/sdc'
sudo umount "$dev"
printf "o\nn\np\n1\n\n\nw\n" | sudo fdisk "$dev"
sudo mkfs.ext4 "${dev}1"

mkdir /mnt/develop
echo `blkid /dev/sdc1 | awk '{print$2}' | sed -e 's/"//g'` /mnt/develop   ext4   noatime,nobarrier   0   0 >> /etc/fstab
mount /mnt/develop

chmod -R ug+wx /mnt/develop
chown vagrant:vagrant -R /mnt/develop

ln -s /mnt/develop /home/vagrant/develop

# SAILFISH-HADK
export HOME="/home/vagrant"
export HADK_ROOT="/mnt/develop"

cat <<'EOF' > $HOME/.hadk.env
export HADK_ROOT="/mnt/develop" 
export PLATFORM_SDK_ROOT="$HADK_ROOT/mer" 
export ANDROID_ROOT="$HADK_ROOT/hadk" 
export VENDOR="xiaomi"
export DEVICE="santoni"
# ARCH conflicts with kernel build 
export PORT_ARCH="armv7hl"
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
runuser -l vagrant -c 'printf "c\nc\nsudo zypper -n in android-tools-hadk tar\nexit\n" | /mnt/develop/mer/sdks/sfossdk/mer-sdk-chroot'

# Installing the corresponding SDK
echo "##### Installing SDKs"
runuser -l vagrant -c 'printf "sdk-assistant create SailfishOS-latest http://releases.sailfishos.org/sdk/latest/Jolla-latest-Sailfish_SDK_Tooling-i486.tar.bz2\ny\nexit" | /mnt/develop/mer/sdks/sfossdk/mer-sdk-chroot'
runuser -l vagrant -c 'printf "sdk-assistant create SailfishOS-latest-armv7hl http://releases.sailfishos.org/sdk/latest/Jolla-latest-Sailfish_SDK_Target-armv7hl.tar.bz2\ny\nexit" | /mnt/develop/mer/sdks/sfossdk/mer-sdk-chroot'

# Installing ubuntu chroot (Android build environment)
echo "##### Installing Ubuntu Chroot"
runuser -l vagrant -c 'printf "curl -s -O https://releases.sailfishos.org/ubu/ubuntu-trusty-20180613-android-rootfs.tar.bz2 && sudo mkdir -p /mnt/develop/mer/sdks/ubuntu && sudo tar --numeric-owner -xjf ubuntu-trusty-20180613-android-rootfs.tar.bz2 -C /mnt/develop/mer/sdks/ubuntu && exit" | /mnt/develop/mer/sdks/sfossdk/mer-sdk-chroot'
