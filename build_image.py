import os

IMAGE = 'ostis/ostis'
VERSION = '0.6.0'

os.system('docker build -t {}:{} .'.format(IMAGE, VERSION))

exit
