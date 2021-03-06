#!/bin/sh

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hv] [-k] [KERNEL VERSION]
Do stuff with FILE and write the result to standard output. With no FILE
or when FILE is -, read standard input.

    -h          display this help and exit
    -k          use the kernel version for search configuration file.
    -v          verbose mode. Can be used multiple times for increased
                verbosity.
EOF
}

# Initialize our own variables:
kernel_version=""
verbose=0

OPTIND=1
# Resetting OPTIND is necessary if getopts was used previously in the script.
# It is a good idea to make OPTIND local if you process options in a function.

while getopts hvk: opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        v)  verbose=$((verbose+1))
            ;;
        k)  kernel_version=$OPTARG
            ;;
        *)
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

# End of file
for i in ../linux-patches/*.patch; do 
	echo ${i}
	yes ""|patch -p1 --no-backup-if-mismatch -f -N -s -d linux-*/ < $i; 
done
cd linux-*/
if [ ! -z "$kernel_version" ]; then
	echo "searching configuration in ~/kernel-config/config-${kernel_version}"
	if [ ! -f ~/kernel-config/config-${kernel_version} ]; then
		echo "File not found!"
		echo "searching configuration in /proc/config.gz"
		if [ ! -f ~/kernel-config ]; then
			echo "Using /proc/config.gz"
			zcat /proc/config.gz > .config
		else
			echo "using defconfig"
			make defconfig
		fi
	else
		echo "Using ~/kernel-config/config-${kernel_version}"
		cp ~/kernel-config/config-${kernel_version} .config
	fi
fi
yes ""|make oldconfig
cat Makefile |head
