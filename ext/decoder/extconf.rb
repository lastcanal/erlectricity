require 'mkmf'

CONFIG['warnflags'].slice!(/ -Wdeclaration-after-statement/)
CONFIG['warnflags'] << ' -Wno-sign-compare'
$CFLAGS << ' -std=c99'

create_makefile('decoder')
