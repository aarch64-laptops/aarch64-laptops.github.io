---
title: Distro Integration
layout: page
---

This is a companion guide for distro integrators who want to add support for
aarch64 (particularly Snapdragon X1) devices to their distro. It assumes that
you are already familiar with your distro's process for building kernels, the
initramfs and options to override the devicetree selection. It should be used in
conjunction with your distro's documentation.

It is recommended that you read through the whole guide before attempting
bring-up and then use it as a reference while you do. This will help you get a
better understanding of the whole picture and how each part of the process fits
in.

## Background

Why is it so much harder to get distros up and running on ARM laptops?
**Especially** considering the (seemingly) good support in the Linux kernel?

This is a complicated question, but largely boils down to a few things which are
worth considering as your work to add ARM laptop support to your distro:

1. Devicetree (the hardware descriptor used instead of ACPI for most ARM
   platforms) is much lower level and does not contain arbitrary logic. Linux
   must be aware of much lower level details of the hardware. Additionally,
   there are still growing pains with devicetree and missing features that make
   it undesirable to separate the devicetree and kernel versions.
2. Historically, ARM has been almost entirely in embedded devices which have
   extremely tight vertical integration. There is a lot of momentum in this
   direction and as a result much of the firmware interfaces, architecture
   designs and software practises lean into this expectation that the
   devicetree, kernel, and userspace will all be tied together tightly. This
   causes a lot of friction for distros.
3. The ACPI provided on Qualcomm Snapdragon laptops is not supported by Linux
   (and likely won't be for the current gen), but vendors don't provide
   devicetree firmware instead. There is no definitive answer on where to store
   and how to retrieve the devicetree so that the kernel can consume it.

### What is devicetree?

For those uninitiated, the devicetree is a descriptive format that is used to
inform the kernel of what hardware is available and how to communicate with it.
For example, the following snippet describes a `gpio-keys` device, made up of
volume down and volume up keys which are connected to GPIO's 5 and 6 on the
`pm8998_gpios` device.

```dts
/{
    gpio-keys {
        compatible = "gpio-keys";
        label = "Volume keys";
        autorepeat;

        key-vol-down {
            label = "Volume down";
            linux,code = <KEY_VOLUMEDOWN>;
            gpios = <&pm8998_gpios 5 GPIO_ACTIVE_LOW>;
            debounce-interval = <15>;
        };

        key-vol-up {
            label = "Volume up";
            linux,code = <KEY_VOLUMEUP>;
            gpios = <&pm8998_gpios 6 GPIO_ACTIVE_LOW>;
            debounce-interval = <15>;
        };
    };
}
```

This method of mapping out hardware components and how they refer to each other
has a long and fairly intriguing history - one that we're really just scratching
the surface of. If you're interested in learning more, check out these
resources:

* [eLinux Devicetree Usage](https://elinux.org/Device_Tree_Usage)
* [A whole lot of resources about
  DT](https://elinux.org/Device_Tree_presentations_papers_articles)

The only other significant information to know about devicetrees, is that the
de-facto source for them is in the kernel itself. While they are meant to be
forwards AND backwards compatible with the kernel, this is not always the case.
It's also common that drivers and associated DT are added at the same time,
meaning that if you have an old devicetree that predates displayport alt-mode
support, it's unlikely that you'll be able to use the feature even on a newer
kernel until you update your DT.

### Drivers

Expanding on the point of devicetree being lower level than ACPI (and ARM
platforms generally requiring tighter kernel integration); on an ACPI system
when the kernel wants to power up e.g. a USB controller, it uses the ACPI to do
it and usually doesn't need to consider low level details like what power rails
must be turned on. On devicetree systems, the kernel needs to model all of these
power rails and control them itself.

Drivers for things like "usb repeaters" (chips which help reduce signal
degredation across the mainboard) aren't needed on ACPI - the ACPI itself can
program these chips or offload it to the embedded controller. On Snapdragon
laptops this is not usually the case, we need to model the repeater in
devicetree AND write a driver for it (and wire that driver up to properly
receive events).

The consequence of all of this is that you need to both enable the USB repeater
driver in your kernel config and ensure the module is included in your initramfs
(otherwise you won't be able to boot from a USB drive).

If you don't do this correctly, you /should/ get some clear error messages from
the kernel, and be able to inspect `/sys/kernel/debug/devices_deferred` to
determine what's missing, however there are many situations where missing
components like this aren't so easy to narrow down.

## Part 1 - The missing kernel config

For Snapdragon laptops, the mandate of the upstream kernel developers is to
ensure that the arm64 defconfig (`arch/arm64/configs/defconfig` for those
following along at home) has everything needed to boot on at least the
well-supported laptops (like the ThinkPad T14s and X13s). Though patches
enabling drivers for other laptops (like display panel drivers) would likely be
welcome.

Where possible, it's recommended that your distro kernel picks up drivers that
are enabled in defconfig or even derives itself from the defconfig. This will
ensure that as new devices are enabled upstream they will trickle down and may
become supported in your distro without any intentional effort.

### Config fragments

A good approach for e.g. a linux-next kernel variant is to use kernel config
fragments, this allows you to maintain a list of config options to enable or
disable on top of the defconfig. An example of this can be seen in the
[postmarketOS linux-next
package](https://gitlab.postmarketos.org/postmarketOS/pmaports/-/tree/082b6f1908db1cf15daacf862e7bfd21d9f2bf57/device/testing/linux-next)
which uses a fragment for distro options and another for device options. These
are simply copied into the kernel config directory and [applied by the kernel
build system
here](https://gitlab.postmarketos.org/postmarketOS/pmaports/-/blob/082b6f1908db1cf15daacf862e7bfd21d9f2bf57/device/testing/linux-next/APKBUILD#L36).

### Device porting best practise

Porting a device to your distro kernel **should** be a relatively
straightforward process, unfortunately there are a lot of easy mistakes that can
waste hours of your time. In general if you're feeling stuck don't hesitate to
head over to the `#aarch64-laptops` IRC channel over on OFTC.

In broad strokes, these are the things to look out for:

1. Pick the LATEST kernel! While support is getting better, Snapdragon laptops
   are getting bug fixes and new features with every single kernel release. If
   your distro offers multiple kernel versions, always use the latest.
2. Ensure your DT is being picked up. For development purposes it is totally
   fine to hardcode this in your GRUB or systemd-boot config (though how exactly
   to do this will depend on your distro).
3. Ensure your DT is the one that came with your kernel. If you made a copy of
   your DT (for example moving it to a generic path so that
   [dtbloader](https://github.com/TravMurav/dtbloader/) would see it) and then
   later moved to a newer kernel or made changes to the DT, it can be easy to
   forget and keep using the old one instead.
4. Set `clk_ignore_unused pd_ignore_unused` in the kernel cmdline. Since
   schematics are often not available, some clocks and power domains may be
   modelled incorrectly. These options ensure that the resources won't be turned
   off even if the kernel thinks they're unused. If you want to experiment with
   them, do so after everything is up and running.
5. If in doubt, `uname -v`. Make sure you're not somehow running an older
   kernel. Checking `zcat /proc/config.gz | grep CONFIG_MY_OPTION` is also a
   good way to sanity check any changes you made.
6. For now, put **ALL** kernel modules into the initramfs. This will avoid any
   weird race conditions, missing drivers, or probe failures that aren't retried
   for whatever reason. We'll whittle this down to just the necessary modules
   later on.

### Actually finding the config options

While it's unlikely that kernel config options get renamed, especially for
device drivers, it's still difficult to produce a definitive list of "here's
what to enable". However there are a few tricks we can use.

First is to catch the obvious options, look in `arch/arm64/configs/defconfig`
for all options with `QCOM` or `X1E` in the name, not all of these will be
needed but those that aren't can be checked later. It's important to note that
the options with `=y` in the defconfig are required to be `=y` due to platform
limitations, without interconnects (for example) it's likely that the platform
will crash before making it to the initramfs.

With the above exceptions, you should aim to use `=m` for most options, with all
modules in the initramfs this shouldn't cause any issues.

Just taking these (or applying your distro config options on top of the
defconfig as mentioned above) should get you a booting kernel.

There is a tool `scripts/dtc/dt_to_config` in the kernel sources, this does not
produce reliable or definitive output, but it can be helpful for point you in
the right direction and to check that you didn't miss anything from the
defconfig.

It can be run like this:

```sh
./scripts/dtc/dt_to_config \
    --config /path/to/dot-config \
    --exclude-flag H,y,m --include-flag c \
    --short-name \
    arch/arm64/boot/dts/qcom/x1e78100-lenovo-thinkpad-t14s.dts
```

Where `/path/to/dot-config` is the path to a `.config` (this will either be
tracked in your distro packaging or produced as part of the build process).

Running the above will output a list of devicetree nodes, the `compatible`
properties (this is how drivers match against the devicetree) and associated
driver and kernel config option if known.

For example if you see

```txt
-d-c-----n--F : clock-controller@100000 : qcom,x1e80100-gcc : drivers/clk/qcom/gcc-x1e80100.c : CONFIG_CLK_X1E80100_GCC : n
```

This tells you that the `clock-controller@100000` node with compatible
`qcom,x1e80100-gcc` matched to driver `gcc-x1e80100.c` which is enabled by
`CONFIG_CLK_X1E80100_GCC` which has a current value of `n`...

**In other words**, `CONFIG_CLK_X1E80100_GCC` needs to be enabled.

Please note that some generic nodes will produce incorrect and spurious output.
This tool should be treated with caution, and its output should be validated
with a second source of truth - in this case the driver is clearly specific to
Qualcomm X1E, so it makes sense to enable it. Config options with `MTK`
(Mediatek) or `IMX` in the name are probably false matches. If in doubt, ask on
IRC.

The include/exclude flags are explained in the `--help` output of the tool, it's
a good idea to spend some time reading this since it is not particularly obvious
or intuitive (the tool may not have been intended for this usecase). The
settings in that example should cause the tool to only output options that are
disabled but should be enabled.

#### Display panels

Display panels are a special case, they might be picked up by the `dt_to_config`
tool, but just in case, here's how you find it manually (this process also
applies to any other driver).

1. Open the DTS (devicetree source) file for your device, we'll take
   `dts/upstream/src/arm64/qcom/x1e80100-lenovo-yoga-slim7x.dts` as an example.
2. Search for `panel` and look for a node with that name, in this case it looks
   like:
<!-- Avoid a blank line so the code block below will be part of the list -->
```dts
&mdss_dp3 {
    compatible = "qcom,x1e80100-dp";
    /delete-property/ #sound-dai-cells;

    status = "okay";

    aux-bus {
        panel {
            compatible = "samsung,atna45dc02", "samsung,atna33xc20";
            enable-gpios = <&pmc8380_3_gpios 4 GPIO_ACTIVE_HIGH>;
            power-supply = <&vreg_edp_3p3>;
...
```
<!-- Continue the numbered list -->
1. Copy the `compatible` property strings (if there are multiple then do this
   for both) and grep the drivers directory for them: `grep -rnwI drivers
   -e "samsung,atna45dc02"`, you may only get a hit on one of them, this is normal.
2. Open the Makefile in the same directory as the C file that grep points you to (we got `drivers/gpu/drm/panel/panel-samsung-atna33xc20.c:335` so open `drivers/gpu/drm/panel/Makefile`) and find the reference to the file (it won't have the `.c` suffix).

```makefile
obj-$(CONFIG_DRM_PANEL_SAMSUNG_ATNA33XC20) += panel-samsung-atna33xc20.o
```

There you go, `CONFIG_DRM_PANEL_SAMSUNG_ATNA33XC20` is what we need to enable for the panel driver in the Yoga Slim 7x.

#### The pesky last few

There are always a few things missing that are a total pain to track down, you
can check if there's anything in `/sys/kernel/debug/devices_deferred`, though
note that missing firmware (a likelihood if you aren't on a ThinkPad) will cause
some drivers not to probe, we'll come back to these later.

Don't be afraid to `grep` for compatible strings in the `drivers/` directory of
the kernel, you can also usually work backwards from a C file, through the
`Makefile` in the same directory and to the associated kernel config option
which you need.

And of course, head over to the IRC where folks can probably help you translate
your error message or missing functionality into the necessary config options.

## Part 2 - Firmware

Many of the benefits of ARM systems come from their heavy use of co-processors
for hardware-accelerated tasks like audio processing, compute or video decoding (notably things
that the x86 world has been trying to catch up with in the last few years).

These co-processors all need to run firmware and that firmware is usually
tied to your specific device. Some of these are packaged in
[linux-firmware](https://web.git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/)
but for most devices there is no clear license and such packaging isn't
possible. Instead the firmware must be pulled from the Windows partition (and
dual booting is the only way to get firmware updates). The only "correct" way to
handle this is to have your users dual-boot and to periodically boot back into
Windows for updates, before then copying over new firmware versions.

For X1E laptops, the
[woa-firmware-yoinker](https://github.com/CadmiumLinux/woa-firmware-yoinker/blob/main/yoink-firmware)
or
[qcom-firmware-extract](https://salsa.debian.org/debian/qcom-firmware-extract)
scripts can be used to fetch this firmware for you after installing. The
process is fairly straightforward and can be applied to other Snapdragon
laptops too (non-X1E), however it requires disabling BitLocker
encryption on the Windows partition in order to mount the Windows
partition from Linux.

The best approach today is probably to come up with a manual or semi-manual
process that users can follow to extract the firmware from windows and put it in
the right place during or after the installation.

Solving the current licensing issues of firmware distribution is outside
the scope of this guide.

## Part 3 - Kernel modules and the initramfs

The eternal battle of every device enablement is getting things to work properly
in the initramfs. This is such a hated process that we have mostly given up and
just run udevd or even systemd itself in the ramdisk. However one thing we still
don't do (most of the time anyway) is pull in all the kernel modules.

On typical x86/ACPI devices, the list of modules required for hardware support
is usually quite generic and mkinitfs implementations have gained the ability
to automatically figure out what modules are needed for the device you're
booting on. But - as is the running theme here - ARM devices usually require way
more modules for basic stuff like display output and keyboard input (the bare
necessities for full disk encryption!).

The author of this guide recommends that you make your life as simple as
possible by doing the following:

1. Install **ALL** kernel modules in the initramfs, especially for initial
   bring-up while you're tracking down all the kernel config options.
2. Once your system is up and running with all the expected
   functionality working, you can use [the hwmodules.sh script in this repository](/hwmodules.sh)
   to find a list of modules that are loaded AND are specific to your
   hardware. This serves as a good starting point to add to the
   initramfs.

It's worth noting that modules relating to sound (`snd`, `q6apm`, `lpass`)
and things like `qcom_stats` and `fastrpc` aren't generally required for the
functionality you'd expect in the initramfs and can be safely skipped.

Additionally, some modules may not be picked up this way (e.g. those probed via
auxiliary busses such as `qcom_battmgr`). These may not be vital (usually you
don't need to know your battery percentage in the initramfs) but it is usually
still worth looking over `lsmod` manually.

## Part 4 - Devicetree

By this point, you should have documented the process for installing firmware on
your device and come up with a list of kernel config options to enable and
modules that must be included in the initramfs.

The last step is to correctly pick the devicetree. Since vendors don't ship
devicetrees with their devices, we must install the devicetree files into the
ESP and somehow load the right one based on which device you're booting on. This
is especially necessary for the installer, but also generally nice to do on the
final image too (just in case someone installs to a USB drive!).

This problem is still a massive pain point with no ideal solutions. Listed below
are two of the ways that folks are currently solving this.

### UKI dtbauto

In systemd v257 it is now possible to build UKIs (Unified Kernel Images) with
multiple DTBs that can be picked based on EFI hwids. Refer to the
`DeviceTreeAuto=` and `HWIDs=` documentation in
[ukify(1)](https://man.archlinux.org/man/ukify.1). A list of configurations for
existing devices can be found in [this
repository](https://github.com/anonymix007/systemd-stub/tree/master/json).

The systemd-stub in the UKI image will automatically perform HWID matching and
pick the appropriate DTB. The primary benefit to this approach is that it
enables secureboot by embedding the DTB inside the PE binary (which can be
signed and validated).

### dtbloader

[dtbloader](https://github.com/TravMurav/dtbloader/) is an EFI driver that can
be used in conjunction with systemd-boot, it loads dtbs from a well-known
directory (`/dtbs/` on the ESP and has it's own internal database of HWIDs). It
is currently used by the postmarketOS trailblazer generic ARM64 EFI target.

To use it, you must package it in your distro and install it into the ESP as a
driver for systemd-boot.

## Part 5 - Community buy-in & Conclusion

There are still a lot of pain points for both distro integrators and end-users
on these devices. Things like audio and external displays are still not always
working great (or at all). While there is plenty of work going on in the kernel,
a lot of effort is still needed in distros and middleware to make these devices
properly nice to install and use.

Adding support for new distros is one of the best ways to help with this effort.
Documenting your process (and more generally the state of support for specific
devices) also goes a long way to spread broader community knowledge and
awareness.

As we collectively become more familiar with ARM platforms and begin to solve
some of the more infuriating issues (e.g. more awareness of how they differ to x86,
what a "devicetree" is) will help us continue bringing the entire stack
together and making the experience of working with and using Linux on these
devices better for everyone.
