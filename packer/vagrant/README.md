## Installation

1. Install Vagrant
2. Install libvirt

```bash
$ sudo apt install qemu libvirt-daemon-system libvirt-dev ebtables \
    libguestfs-tools ruby-libvirt libvirt-clients bridge-utils
$ sudo adduser [user] kvm
$ sudo adduser [user] libvirt
$ virsh list --all
```

3. Install Vagrant plugins

```bash
$ vagrant plugin install vagrant-libvirt
$ vagrant plugin install vagrant-mutate
```

4. Build Vagrant box

```bash
$ packer build .
$ vagrant box add builds/base.libvirt.box --provider libvirt --name test/debian-11.5
```

5. Start VM with libvirt provider

```bash
$ vagrant init test/debian-11.5
$ vagrant up --provider=libvirt
$ vagrant ssh
```

## Building

We build the Vagrant box with the qemu builder and Vagrant post-processor. Several
scripts are **required** for the Vagrant box to function properly with Vagrant:

- Create `vagrant` user with password `vagrant`
- Add Vagrant's insecure public key to `vagrant` user's `authorized_keys` file
- Set up password-less sudo for `vagrant` user
- Ensure `UseDNS no` is added to `sshd_config`
- Use `eth0` interface (for libvirt)
- For qemu builds, minimize the image with `minimize.sh`
