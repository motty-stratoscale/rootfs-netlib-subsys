NETLIB_RPMS = \
	openstackapi/consul*.rpm\
	openstackapi/strato-noded*.rpm\
	strato-kmods/strato-kmods-[^d]*\
	log/strato_logging*.rpm 

NETLIB_RPMS_CHROOT_PATH = /tmp/netlib_pkgs/
NETLIB_RPMS_TO_INSTALL = $(addprefix $(NETLIB_RPMS_CHROOT_PATH),$(NETLIB_RPMS))
$(info $(NETLIB_RPMS_TO_INSTALL))
