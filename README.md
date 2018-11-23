# Vagrant SailfishOS build

A simple way to get started using the HADK by Jolla. It'll download the latest SDK available.

# Getting started
1. Clone this repo `git clone https://github.com/bitrvmpd/vagrant-sailfishos-build.git`
2. Navigate to project folder `cd vagrant-sailfishos-build`
3. Start vagrant and let it do its thing `vagrant up; vagrant ssh`
4. Jump to Chapter 5 of the HADK :tada:


# Configure

It's pre-configured for the Redmi 4X (santoni), open `bootstrap.sh` and change these lines to fit your needs.

```bash
# ############################### #
# SET YOUR VENDOR AND DEVICE HERE #
# ############################### #
export VENDOR="xiaomi"
export DEVICE="santoni"
export PORT_ARCH="armv7hl"
```

Locate these lines inside the Vagrantfile to change how many Cores and RAM the VM will use.

```bash
vb.memory = 5000
vb.cpus = 4
```

# Requirements
- Vagrant
