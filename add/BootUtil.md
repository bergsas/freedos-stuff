Download BootUtil from Intel's site:

https://downloadcenter.intel.com/download/19186/Intel-Ethernet-Connections-Boot-Utility-Preboot-images-and-EFI-Drivers

# curl -OLe "https://downloadcenter.intel.com/downloads/eula/19186/Intel-Ethernet-Connections-Boot-Utility-Preboot-images-and-EFI-Drivers?httpDown=http%3A%2F%2Fdownloadmirror.intel.com%2F19186%2Feng%2FPREBOOT.EXE" http://downloadmirror.intel.com/19186/eng/PREBOOT.EXE

# Unpack:
unzip -oj PREBOOT.EXE APPS/BootUtil/DOS/BootUtil.exe

# Nice thing to do with it:
bootutil.exe -all -bootenable=pxe -setupenable -setwaittime=5 -messageenable   
