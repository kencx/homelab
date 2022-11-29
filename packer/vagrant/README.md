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

- Ensure `UseDNS no` is added to `sshd_config`
- Use `eth0` interface (for libvirt)
- For qemu builds, minimize the image with `minimize.sh`

## Notes

Specify your custom SSH key pair with `ssh_private_key_file` and `ssh_public_key_file`.
The SSH public key will be added to the user's `.ssh/authorized_keys` file.

The default root password is `vagrant`. Although root login is disabled, it is
recommended to change this for non-development systems:

```hcl
# auto.pkrvars.hcl
root_password = changeme
```

or you can choose to change the root password on startup with

```bash
$ sudo passwd root
```

It is also recommmended to disable password-less sudo, which has been enabled for
easy provisioning.
