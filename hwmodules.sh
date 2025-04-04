#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
#
# This script uses modalias info to determine which modules are
# specifically used by the currently booted hardware. Specifically by
# comparing to the running devicetree. It servces as a good reference
# for figuring out which modules need to be added to your initramfs for
# e.g. USB support.

# Get all compatible properties used on this device
compat_file=$(mktemp)
echo "Populating list of compatible properties..." >&2
find /sys/firmware/devicetree/base/ -name compatible -exec cat {} \; | tr '\0' '\n' > $compat_file

if [ -z "$(cat $compat_file)" ]; then
	printf 'No compatible properties found, are you running on the target device?\n' >&2
	exit 1
fi

printf "Finding modules required by this device..." >&2
needed_modules=""
# List all modules, skip the first line of lsmod
eval "set -- \$(lsmod | tail -n +2 | cut -d' ' -f1)"
for module; do
	aliases=$(modinfo $module -F alias -0)
	if [ -z "$aliases" ]; then
		continue
	fi
	#printf '%s: %s\n' "$module" "$aliases"
	if printf '%s' "$aliases" | grep -q -f $compat_file; then
		needed_modules="$needed_modules $module"
	fi
done

printf 'The following modules are needed by hardware, consider adding them to your initramfs:\n' >&2
printf '%s\n' $needed_modules

