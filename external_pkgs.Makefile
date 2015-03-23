DISTRATO_RPMS_TO_INSTALL = \
   

YUM_CACHE = http://localhost:1012/
EXTERNAL_RPMS = \
	mirrors.kernel.org/fedora-epel/7/x86_64/p/python-netifaces-0.5-4.el7.x86_64.rpm

EXTERNAL_RPMS_CHROOT_PATH = /tmp/external_pkgs/
EXTERNAL_RPMS_TO_INSTALL = $(addprefix $(EXTERNAL_RPMS_CHROOT_PATH),$(notdir $(EXTERNAL_RPMS)))
