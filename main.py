import os
import sys

RPC_CONF = """
[DEFAULT]
ignoreRPC = True
"""

def _ensure_dir(f):
    d = os.path.dirname(f)
    if not os.path.exists(d):
        os.makedirs(d)


def _initRPCConf(rootDir):
    _ensure_dir('%s/etc/stratoscale/' % rootDir)
    with open('%s/etc/stratoscale/rpc.conf' % rootDir, 'w') as f:
        f.writelines(RPC_CONF)

if __name__ == "__main__":
    assert len(sys.argv) == 2
    _initRPCConf(sys.argv[1])
