require 'simplecov'
SimpleCov.start

require 'erlectricity'
require 'stringio'

$stdout.sync = true

RSpec.configure do |c|
  def run_erl(code)
    cmd = %Q{erl -noshell -eval "A = #{code.split.join(' ')}, io:put_chars(binary_to_list(A))." -s erlang halt}
    `#{cmd}`
  end

  def word_length
    (1.size * 8) - 2
  end
end

class FakePort < Erlectricity::Port
  attr_reader :sent
  attr_reader :terms

  def initialize(*terms)
    @terms = terms
    @sent = []
    super(StringIO.new(""), StringIO.new(""))
  end

  def send(term)
    sent << term
  end

  private

  def read_from_input
    @terms.shift
  end
end
