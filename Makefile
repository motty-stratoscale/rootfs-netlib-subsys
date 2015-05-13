ROOTFS = build/root
ROOTFS_TMP = $(ROOTFS).tmp
PIP_INSTALL_ARGUMENTS = -i http://pip-repo/simple/ --extra-index-url http://mirrors.stratoscale.com.s3-website-us-east-1.amazonaws.com/pip/simple
DISTRATO_YAMLS = ../distrato-yamls/yamls/pkgmeta/*.yaml
LOCAL_DISTRATO_YAMLS = build/distrato-yamls

all: $(ROOTFS)

submit:
	sudo -E solvent submitproduct --force  rootfs $(ROOTFS)

bezeq_transfer:
	sudo -E osmosis transfer solvent__rootfs-netlib-subsys__rootfs__$(HASH)__dirty --transferDestination=osmosis.dc1.strato:1010

approve:
	sudo -E solvent approve --product=rootfs

clean:
	sudo rm -fr build

distrato_sync:
	-rm -rf $(LOCAL_DISTRATO_YAMLS)/pkgmeta
	mkdir -p $(LOCAL_DISTRATO_YAMLS)/pkgmeta
	cp $(DISTRATO_YAMLS) $(LOCAL_DISTRATO_YAMLS)/pkgmeta/ ; \
	DISTRATO_INPUT_DIR=$(LOCAL_DISTRATO_YAMLS) ../distrato-yamls/distrato sync;\
	
define install_external_rpms = 
	@echo "Installing $(EXTERNAL_RPMS_TO_INSTALL)"
	/usr/bin/sudo ./chroot.sh $(ROOTFS_TMP) sh -c "ls $(EXTERNAL_RPMS_TO_INSTALL) | xargs yum --assumeyes --nogpgcheck localinstall"
endef 

define wget_external_rpm =
	@echo "Going to download $1 to $(ROOTFS_TMP)$(EXTERNAL_RPMS_CHROOT_PATH)"
	sudo wget -P $(ROOTFS_TMP)$(EXTERNAL_RPMS_CHROOT_PATH) $(YUM_CACHE)$1
	@echo "Downloaded $1 to $(ROOTFS_TMP)$(EXTERNAL_RPMS_CHROOT_PATH)"
endef

$(ROOTFS): distrato_sync
#	-sudo mv $(ROOTFS) $(ROOTFS_TMP)
	echo "Bringing source"
	-mkdir $(@D)
	sudo -E solvent bring --repositoryBasename=rootfs-runtime-subsys --product=rootfs --destination=$(ROOTFS_TMP)
	sudo mkdir $(ROOTFS_TMP)$(NETLIB_RPMS_CHROOT_PATH)

	sudo -E solvent bring --repositoryBasename=strato-kmods --product=rpms --destination=$(ROOTFS_TMP)$(NETLIB_RPMS_CHROOT_PATH)strato-kmods
	sudo -E solvent bring --repositoryBasename=openstackapi --product=rpms --destination=$(ROOTFS_TMP)$(NETLIB_RPMS_CHROOT_PATH)openstackapi
	sudo -E solvent bring --repositoryBasename=loggingtools --product=rpm --destination=$(ROOTFS_TMP)$(NETLIB_RPMS_CHROOT_PATH)log
	
	sudo rm -rf $(ROOTFS_TMP)$(EXTERNAL_RPMS_CHROOT_PATH)
	sudo mkdir $(ROOTFS_TMP)$(EXTERNAL_RPMS_CHROOT_PATH)
	$(foreach rpm,$(EXTERNAL_RPMS),$(call wget_external_rpm,$(rpm)))
	$(call install_external_rpms)
	sudo ./chroot.sh $(ROOTFS_TMP) sh -c "ls $(NETLIB_RPMS_TO_INSTALL) | xargs yum --assumeyes --nogpgcheck localinstall"
	sudo rm -rf $(ROOTFS_TMP)/etc/modprobe.d/strato-kmods.conf
	
	sudo mkdir -p $(ROOTFS_TMP)/etc/stratoscale
	
	# Disable consul and noded we will start them manually after we intialize answer file during the test
	sudo rm $(ROOTFS_TMP)/etc/systemd/system/multi-user.target.wants/consul.service -f
	sudo rm $(ROOTFS_TMP)/etc/systemd/system/multi-user.target.wants/strato-noded.service -f
	sudo echo -e "{'Label': 'Goltz', 'ReleaseNotes': 'NetLib Rulezzz', 'Version': '6.6.6.deadbeef'}" | sudo tee --append  $(ROOTFS_TMP)/etc/strato-version.yaml
	sudo -E PYTHONPATH=py/:. python main.py $(ROOTFS_TMP)
	sudo mv $(ROOTFS_TMP) $(ROOTFS)

include python_pkgs.Makefile
include netlib_pkgs.Makefile
include external_pkgs.Makefile

## the code below:
## 1. is for testing purposes
## 2. uses features from lower layers, which eventually the shlompstack will replace with nice wrappers and command line flags
HASH = $(shell git log -1 | head -1 | cut -f 2 -d ' ')
# unsubmit before make submit if the hash hasn't changed
unsubmit:
	-osmosis eraselabel solvent__rootfs-netlib-subsys__rootfs__$(HASH)__dirty
	-osmosis eraselabel solvent__rootfs-netlib-subsys__rootfs__$(HASH)__dirty --objectStores=osmosis.dc1.strato:1010
	-osmosis eraselabel solvent__rootfs-netlib-subsys__rootfs__$(HASH)__dirty --objectStores=oberon:1010

# This is temporary, when all servers will be moved to bezeq this will be deprecated
ifeq ("$(RACK_SITE)","bezeq")
RACK_DOMAIN := rackattack-provider.dc1.strato
else
RACK_DOMAIN := rackattack-provider
endif
RACKATTACK_PROVIDER_PHYS = tcp://$(RACK_DOMAIN):1014@tcp://$(RACK_DOMAIN):1015@http://$(RACK_DOMAIN):1016

# playaround creates the vm and runs it locally. The first time a newely submitted image is created, this takes 3-5mins
# during which, the computer is fully utilized (so it will feel a bit slugish)
# the next take ~14sec
# once the ssh session is closed, the VM frees up automatically. the root credentials are printed on screen.
# use this to playaround yum commands and such, before writing them down to the makefile
playaround:
	RACKATTACK_PROVIDER=tcp://localhost:1014@tcp://localhost:1015@tcp://localhost:1016 PYTHONPATH=../rackattack-api/py python ../rackattack-api/py/rackattack/playaround.py --label=solvent__rootfs-netlib-subsys__rootfs__$(HASH)__dirty --user=maor
physplayaround:
	RACKATTACK_PROVIDER=$(RACKATTACK_PROVIDER_PHYS) PYTHONPATH=../rackattack-api/py python ../rackattack-api/py/rackattack/playaround.py --label=solvent__rootfs-netlib-subsys__rootfs__$(HASH)__dirty --user=maor

.PHONY: $(ROOTFS)
