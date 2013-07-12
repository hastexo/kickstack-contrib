#!/bin/bash
set -e

CONNECT="qemu:///system"
MEMORY=1024
VCPUS=1
LOCATION="http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64"
PRESEED="../ubuntu/puppetmaster-ks.cfg"
POOL="default"
NETWORK="default"
BRIDGE=""

TEMP=`getopt -o c:n:r:l: --long connect:,ram:,vcpus:,location:,preseed:,kickstart:,pool:,network:,bridge: -n "$0" -- "$@"`

eval set -- "$TEMP"
while true ; do
  case "$1" in
    -c|--connect)  CONNECT=$2;  shift 2;;
    -r|--ram)      MEMORY=$2 ;  shift 2;;
    --vcpus)       VCPUS=$2;    shift 2;;
    -l|--location) LOCATION=$2; shift 2;;
    --preseed|--kickstart)  PRESEED=$2;  shift 2;;
    --pool)        POOL=$2;     shift 2;;
    --network)     NETWORK=$2;  shift 2;;
    --bridge)      BRIDGE=$2;   shift 2;;  
    --) shift ; break ;;
    *) echo "Internal error!" >&2 ; exit 1 ;;
  esac
done

NAME=$1

if [ -z "$NAME" ]; then
  echo "Must specify a domain name!" >&2
  exit 1
fi

nw="network=$NETWORK"
if [ -n "$BRIDGE" ]; then
  nw="bridge=$BRIDGE"
fi

virt-install \
  --connect=$CONNECT \
  --name $NAME \
  --ram=$MEMORY \
  --vcpus=$VCPUS \
  --location=$LOCATION \
  --initrd-inject="$PRESEED" \
  --extra-args="install auto=true priority=critical netcfg/hostname=$NAME preseed/file=`basename $PRESEED`" \
  --disk pool=$POOL,size=4,bus=virtio,format=qcow2 \
  --network $nw,model=virtio \
  --hvm \
  --prompt \
  --debug
