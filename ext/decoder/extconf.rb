require 'mkmf'

CONFIG['warnflags'].slice!(/ -Wdeclaration-after-statement/)
CONFIG['warnflags'] << ' -Wno-sign-compare'
CONFIG['warnflags'] << ' -Wno--Wstrict-aliasing'
$CFLAGS << ' -std=c99'

create_makefile('decoder')
