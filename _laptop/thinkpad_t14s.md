---
name: Thinkpad T14s
layout: laptop
status-audio: N/A
status-audio-displayportaudio: N
status-audio-mic: N
status-audio-speakers: WIP
status-audio-speakers-comment: "
    - Active speaker protection not enabled, volume limited for now,<br>
    - Pops and clicks <br>
    - Pipewire playback issues <br>
    - (switch to Pulseaudio as workaround) <br>
    - Reducing quantum size appears to help with playback issues <br>
    <code>pw-metadata -n settings 0 clock.max-quantum 1024</code>
"
status-camera: N
status-connectivity: N/A
status-connectivity-bluetooth: Branch
status-connectivity-modem: N
status-connectivity-wifi: 6.12
status-cpufreq: Branch
status-efivariables: 6.12
status-hid: N/A
status-hid-backlight: WIP
status-hid-fingerprintreader: N
status-hid-keyboard: 6.12
status-hid-specialkeys: N
status-hid-specialkeys-comment: "
    Support for some functions like mic mute is missing
"
status-hid-touchpad: 6.12
status-hid-touchscreen: 6.12
status-pcie: 6.12
status-power: N/A
status-power-battery: 6.12
status-power-hibernation: N
status-power-suspend: 6.12
status-power-suspend-comment: "
    - Active audio streams blocks suspend<br>
    - Crash on resume if disconnecting external display while suspended<br>
    - Displays fail to resume (switch VT as workaround) (fixed in wip branch)<br>
    - Not yet hitting deepest low-power state during suspend<br>
    - USB disconnect triggers wakeup (disconnect before suspending as workaround)<br>
"
status-remoteproc: 6.12
status-remoteproc-comment: "
    - aDSP fails to register its services (e.g. sound, battery, USB-C orientation) (very infrequent)<br>
    - Audio service fails to register with in-kernel pd-mapper (infrequent)<br>
    - QRTR/MHI race can break boot with in-kernel pd-mapper (infrequent) (fixed in wip branch)
"
status-rtc: WIP
status-storage: N/A
status-storage-nvmessd: 6.12
status-storage-ufs: N/A
status-thermalsensors: N
status-thermalsensors-comment: "
    - CPU thermal throttling not implemented<br>
    - GPU thermal throttling not implemented
"
status-tpm: N
status-usb: N/A
status-usb-usba: Branch
status-usb-usbc: 6.12
status-usb-usbc-comment: "
    USB-C coldplug orientation detection not working (flip cable as workaround) (fixed in wip branch)
"
status-usb-usbcdpaltmode: Branch
status-usb-usbcdpaltmode-comment: "
    Display driver does not yet support 4-lane DisplayPort Alt Mode
"
status-usb-usbpd: 6.12
status-video: N/A
status-video-display: 6.12
status-video-display-comment: "
    Link training fails during resume (very infrequent)
"
status-video-gpu: 6.12
status-video-hdmi: N/A
status-video-videoacceleration: WIP
status-virtualisation: N
status-watchdog: N
---

## Kernel command line
To boot Linux the following kernel parameters need to be provided:
```
clk_ignore_unused pd_ignore_unused
```
due to a generic resource handover issue.

## Userspace dependencies
- linux-firmware-20241017
- Mesa 24.2
- Windows firmware (in `/lib/firmware/qcom/x1e80100/LENOVO/21N1/`)
  - adsp_dtbs.elf
  - cdsp_dtbs.elf
  - qcadsp8380.mbn
  - qccdsp8380.mbn
  - qcdxkmsuc8380.mbn

## UEFI firmware
- Boot issues with 64 GB version (disable upper 32 GB as workaround)
  - `cutmem 0x8800000000 0x8fffffffff`
- GRUB fails to start on 64 GB version ([patch](https://git.launchpad.net/~ubuntu-concept/ubuntu/+source/grub2/commit/?id=185e4420f7010c3cdd48ef2274a77f1a4e5e78c1) GRUB as workaround)
- Firmware bugs can prevent GRUB and systemd-boot from starting kernel (start and exit UEFI shell as workaround)(fixed in wip branch)

## Information collected and more information

See <https://github.com/jhovold/linux/wiki/T14s>
