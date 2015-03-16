import os
LIBVIRT_DOMAIN = "qemu:///system"
MAX_GUESTS = 253
NET_NAME = "default"
BRIDGE_NAME = "virbr0"
IP_PREFIX = "192.168.129"
MAC_PREFIX = "28:d2:45:93"
IP_FIRST = 2
IP_TRIM = 200
IP_MASK = "255.255.255.0"
IMAGE_PATH = "/home/images"
IMAGES = [dict(name="trusty-server.img")]
TRUSTY_ROOT_CREDENTIALS = dict(username='root', password='strato')
CIRROS_VM_IMAGES = [dict(name='cirros-0.3.1-x86_64-disk.img')]
CIRROS_ROOT_CREDENTIALS = dict(username='cirros', password='cubswin:)')
SERIALS_PATH = "/var/log"
WIN_IMAGES = [dict(name="win-server-2008-re.qcow2")]
WINDOWS_ROOT_CREDENTIALS = dict(username='Administrator', password='Strato2014')
IMAGE_STORE_SERVER = '10.16.3.4' if 'RACK_SITE' in os.environ and os.environ['RACK_SITE'] == 'bezeq' else 'rackattack-provider.strato'
FTP_IMAGE_STOR = "ftp://logs:logs@%(server)s/images/" % dict(server=IMAGE_STORE_SERVER)
