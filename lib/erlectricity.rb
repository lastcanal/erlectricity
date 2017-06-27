require 'stringio'

require 'erlectricity/constants'
require 'erlectricity/types/new_reference'
require 'erlectricity/types/pid'
require 'erlectricity/types/function'
require 'erlectricity/types/list'

require 'erlectricity/decoder'

require 'erlectricity/encoder'

require 'erlectricity/port'
require 'erlectricity/matcher'
require 'erlectricity/condition'
require 'erlectricity/conditions/boolean'
require 'erlectricity/conditions/hash'
require 'erlectricity/conditions/static'
require 'erlectricity/conditions/type'
require 'erlectricity/receiver'
require 'erlectricity/errors/erlectricity_error'
require 'erlectricity/errors/decode_error'
require 'erlectricity/errors/encode_error'

Erl = Erlectricity
