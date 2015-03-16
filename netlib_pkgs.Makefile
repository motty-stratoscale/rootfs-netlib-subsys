NETLIB_RPMS = \
	consul/consul*.rpm\
	noded/strato-noded*.rpm\
	strato-kmods/strato-kmods-[^d]*\
	log/log*.rpm

NETLIB_RPMS_CHROOT_PATH = /tmp/netlib_pkgs/
NETLIB_RPMS_TO_INSTALL = $(addprefix $(NETLIB_RPMS_CHROOT_PATH),$(NETLIB_RPMS))
$(info $(NETLIB_RPMS_TO_INSTALL))
