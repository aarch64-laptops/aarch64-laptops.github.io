---
name: Dell XPS 13 9345
layout: laptop
status-audio: N/A
status-audio-displayportaudio: N/A
status-audio-mic: N
status-audio-speakers: N
status-camera: N
status-connectivity: N/A
status-connectivity-bluetooth: N
status-connectivity-modem: N/A
status-connectivity-wifi: 6.13-rc1
status-cpufreq: Branch
status-efivariables: 6.13-rc1
status-hid: N/A
status-hid-backlight: 6.13-rc1
status-hid-fingerprintreader: N
status-hid-keyboard: WIP
status-hid-keyboard-comment: "
    Keyboard needs a quirk in HID. Patches are in the HID tree on the way to Linus. Hopefully within the 6.13-rcX cycle.<br>
    https://git.kernel.org/pub/scm/linux/kernel/git/hid/hid.git/commit/?h=for-6.13/upstream-fixes&id=e61080220ae7b52920aed292c8d399ea8ce7cfdb<br>
    https://git.kernel.org/pub/scm/linux/kernel/git/hid/hid.git/commit/?h=for-6.13/upstream-fixes&id=e02b876cf4c171fecc0f3b4910ed3029db566369<br>
"
status-hid-specialkeys: WIP
status-hid-specialkeys-comment: "
    Top touchbar keys. Fn switching works<br>
    Working keys: esc, speaker mute, volume down, volume up, keyboard backlight, screen brightness up, screen brightness down, print, pos1, end, ins, del<br>
    Non-working / WIP keys: mic mute, play/pause, external screen switch<br>
"
status-hid-touchpad: 6.13-rc1
status-hid-touchscreen: 6.13-rc1
status-pcie: 6.13-rc1
status-power: N/A
status-power-battery: 6.13-rc1
status-power-hibernation: N
status-power-suspend: 6.13-rc1
status-power-suspend-comment: "
    - Displays fail to resume (switch VT as workaround) (fixed in wip branch)<br>
    - Not yet hitting deepest low-power state during suspend<br>
    - USB disconnect triggers wakeup (disconnect before suspending as workaround)<br>
"
status-remoteproc: 6.13-rc1
status-remoteproc-comment: "
    - aDSP fails to register its services (e.g. sound, battery, USB-C orientation) (very infrequent)<br>
    - Audio service fails to register with in-kernel pd-mapper (infrequent)<br>
    - QRTR/MHI race can break boot with in-kernel pd-mapper (infrequent) (fixed in wip branch)
"
status-rtc: WIP
status-storage: N/A
status-storage-nvmessd: 6.13-rc1
status-storage-ufs: N/A
status-thermalsensors: N
status-thermalsensors-comment: "
    - CPU thermal throttling not implemented<br>
    - GPU thermal throttling not implemented
"
status-tpm: N
status-usb: N/A
status-usb-usba: N/A
status-usb-usbc: 6.13-rc1
status-usb-usbc-comment: "
    USB-C coldplug orientation detection not working (flip cable as workaround) (fixed in wip branch)
"
status-usb-usbcdpaltmode: N
status-usb-usbpd: 6.13-rc1
status-video: N/A
status-video-display: 6.13-rc1
status-video-gpu: 6.13-rc1
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
- Windows firmware (in `/lib/firmware/qcom/x1e80100/dell/xps13-9345`)
  - adsp_dtbs.elf
  - adspr.jsn
  - adsps.jsn
  - adspua.jsn
  - battmgr.jsn
  - cdsp_dtbs.elf
  - qcadsp8380.mbn
  - qccdsp8380.mbn
  - qcdxkmsuc8380.mbn

## UEFI firmware
- Boot issues with 64 GB version (disable upper 32 GB as workaround)
  - `cutmem 0x8800000000 0x8fffffffff`
- GRUB fails to start on 64 GB version ([patch](https://git.launchpad.net/~ubuntu-concept/ubuntu/+source/grub2/commit/?id=185e4420f7010c3cdd48ef2274a77f1a4e5e78c1) GRUB as workaround)
