---
name: Thinkpad X13s
layout: laptop
status-audio: N/A
status-audio-displayportaudio: N
status-audio-mic: 6.5
status-audio-mic-comment: "
    Some capture issues
"
status-audio-speakers: 6.5
status-audio-speakers-comment: "
    - Active speaker protection not enabled, volume limited for now,<br>
    - Pops and clicks <br>
    - Pipewire playback issues (switch to Pulseaudio as workaround)<br>
    - Reducing quantum size appears to help with playback issues - <br>
    <code>pw-metadata -n settings 0 clock.max-quantum 1024</code>
"
status-camera: 6.12
status-camera-comment: "
    - libcamera needs acccess to /dev/udmabuf (e.g. user must be in the kvm group)
"
status-connectivity: N/A
status-connectivity-bluetooth: 6.4
status-connectivity-bluetooth-comment: "
    - Connectivity issues due to missing board-specific firmware (e.g. very limited range) (fixed in wip branch and linux-firmware)<br>
    - Device address needs to be set manually for now:
    <code>btmgmt --index 0 public-addr 00:11:22:33:44:55</code>
"
status-connectivity-modem: 6.2
status-connectivity-wifi: 6.4
status-connectivity-wifi-comment: '
    - MAC address not static, can be worked around using udev (e.g. in /etc/udev/rules.d/90-net-address.rules):<br>
    <code>ACTION=="add", SUBSYSTEM=="net", KERNELS=="0006:01:00.0", RUN+="/usr/bin/ip link set dev $name address xx:xx:xx:xx:xx:xx"</code><br>
    - Wi-Fi breaks due to ring-buffer corruption (infrequent)
'
status-cpufreq: 6.0
status-efivariables: 6.7
status-hid: N/A
status-hid-backlight: 6.0
status-hid-fingerprintreader: 6.10
status-hid-keyboard: 6.0
status-hid-specialkeys: N
status-hid-specialkeys-comment: "
    Support for some functions like mic mute is missing
"
status-hid-touchpad: 6.0
status-hid-touchscreen: 6.0
status-pcie: 6.2
status-power: N/A
status-power-battery: 6.3
status-power-hibernation: N
status-power-suspend: 6.1
status-power-suspend-comment: "
    - All displays fail to resume if suspending after disconnecting external display in X.<br>
    - Crash on resume if disconnecting external display while suspended.<br>
    - Not yet hitting deepest low-power state during suspend.<br>
    - USB disconnect triggers wakeup (disconnect before suspending as workaround)
"
status-remoteproc: 6.0
status-remoteproc-comment: "
    aDSP fails to register its services (e.g. sound, battery, USB-C orientation) (very infrequent)
"
status-rtc: 6.4
status-storage: N/A
status-storage-nvmessd: 6.2
status-storage-ufs: N/A
status-thermalsensors: 6.2
status-tpm: N
status-usb: N/A
status-usb-usba: 6.0
status-usb-usbc: 6.0
status-usb-usbcdpaltmode: 6.3
status-usb-usbcdpaltmode-comment: "
    Display driver does not yet support 4-lane DisplayPort Alt Mode
"
status-usb-usbpd: WIP
status-video: N/A
status-video-display: 6.3
status-video-display-comment: "
    Link training fails during resume (very infrequent)
"
status-video-gpu: 6.5
status-video-hdmi: N/A
status-video-videoacceleration: Branch
status-virtualisation: N
status-watchdog: 6.0
---

## Step-by-step install guides
- [Debian](../laptops/thinkpad_x13s/debian_guide.html)

## Distro-specific information

- [Arch Linux ARM](https://github.com/ironrobin/archiso-x13s/wiki/Feature-Support)
- [Debian](https://wiki.debian.org/InstallingDebianOn/Thinkpad/X13s)
- [Gentoo](https://wiki.gentoo.org/wiki/ThinkPad_X13s)
- [Ubuntu](https://launchpad.net/~ubuntu-concept/+archive/ubuntu/x13s)

## Work-in-progress branches

Important fixes and support for new features (once stable enough) can be found
in my X13s (sc8280xp) wip branches, for example:

https://github.com/jhovold/linux/tree/wip/sc8280xp-6.13-rc1

These branches also include a minimal (but functional) johan_defconfig that
serves as documentation for the configuration options that need to be enabled
for the X13s.

## Kernel command line
To boot Linux the following kernel parameters need to be provided:
```
clk_ignore_unused pd_ignore_unused arm64.nopauth efi=noruntime
```
due to a generic resource handover issue and a couple of firmware bugs, respectively.

With recent UEFI firmware `efi=noruntime` can be left out when the `Linux Boot` option is enabled.

## Userspace dependencies
* alsa-ucm-conf 1.2.11
* libcamera 0.3.0
* linux-firmware-20230919
  * Bluetooth NVM config (hpnv21.b8c and hpnv21g.b8c) from latest [linux-firmware](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/qca)
  * Video acceleration firmware (qcvss8280.mbn) with wip branch
* Mesa 23.1.4
* ModemManager 1.20 + [fcc-unlock](https://modemmanager.org/docs/modemmanager/fcc-unlock/) symlink
* ~Qualcomm protection-domain mapper daemon ([pd-mapper](https://github.com/andersson/pd-mapper))~ (not needed since 6.11)

## Information collected and more information

See <https://github.com/jhovold/linux/wiki/X13s>
