require 'spec_helper'

context "When packing to a binary stream" do
  before do
    @out = StringIO.new('', 'w')
    @encoder = Erlectricity::Encoder.new(@out)
  end

  specify "A symbol should be encoded to an erlang atom" do
    expect(get{@encoder.write_symbol :haha}).to eq(get_erl("haha"))
    expect(write_any(:haha)).to eq(get_erl_with_magic("haha"))
  end

  specify "A boolean should be encoded to an erlang atom" do
    expect(get{@encoder.write_boolean true}).to eq(get_erl("true"))
    expect(get{@encoder.write_boolean false}).to eq(get_erl("false"))
    expect(write_any(true)).to eq(get_erl_with_magic("true"))
    expect(write_any(false)).to eq(get_erl_with_magic("false"))
  end

  specify "A number to be encoded should be properly broken into bytes" do
    expect(@encoder.break_into_bytes(12549760679).length).to eq(5)
    expect(@encoder.break_into_bytes(12549760679)).to eq([167, 38, 6, 236, 2])
  end

  specify "A number should be encoded as an erlang number would be" do
    #SMALL_INTS
    expect(get{@encoder.write_fixnum 0}).to eq(get_erl("0"))
    expect(get{@encoder.write_fixnum 255}).to eq(get_erl("255"))
    expect(write_any(0)).to eq(get_erl_with_magic("0"))
    expect(write_any(255)).to eq(get_erl_with_magic("255"))

    #INTS
    expect(get{@encoder.write_fixnum 256}).to eq(get_erl("256"))
    expect(get{@encoder.write_fixnum((1 << 27) - 1)}).to eq(get_erl("#{(1 << 27) - 1}"))
    expect(get{@encoder.write_fixnum(-1)}).to eq(get_erl("-1"))
    expect(get{@encoder.write_fixnum(-(1 << 27))}).to eq(get_erl("#{-(1 << 27)}"))
    expect(get{@encoder.write_fixnum(1254976067)}).to eq(get_erl("1254976067"))
    expect(get{@encoder.write_fixnum(-1254976067)}).to eq(get_erl("-1254976067"))
    expect(write_any(256)).to eq(get_erl_with_magic("256"))
    expect(write_any((1 << 27) - 1)).to eq(get_erl_with_magic("#{(1 << 27) - 1}"))
    expect(write_any(-1)).to eq(get_erl_with_magic("-1"))
    expect(write_any(-(1 << 27))).to eq(get_erl_with_magic("#{-(1 << 27)}"))

    # #SMALL_BIGNUMS
    expect(get{@encoder.write_fixnum(10_000_000_000_000_000_000)}).to eq(get_erl("10000000000000000000"))
    expect(get{@encoder.write_fixnum(12549760679)}).to eq(get_erl("12549760679"))
    # get{@encoder.write_fixnum((1 << word_length))}.should == get_erl("#{(1 << word_length)}")
    # get{@encoder.write_fixnum(-(1 << word_length) - 1)}.should == get_erl("#{-(1 << word_length) - 1}")
    # get{@encoder.write_fixnum((1 << (255 * 8)) - 1)}.should == get_erl("#{(1 << (255 * 8)) - 1}")
    # get{@encoder.write_fixnum(-((1 << (255 * 8)) - 1))}.should == get_erl("#{-((1 << (255 * 8)) - 1)}")
    #
    # write_any((1 << word_length)).should == get_erl_with_magic("#{(1 << word_length)}")
    # write_any(-(1 << word_length) - 1).should == get_erl_with_magic("#{-(1 << word_length) - 1}")
    # write_any((1 << (255 * 8)) - 1).should == get_erl_with_magic("#{(1 << (255 * 8)) - 1}")
    # write_any(-((1 << (255 * 8)) - 1)).should == get_erl_with_magic("#{-((1 << (255 * 8)) - 1)}")
    #
    # #LARGE_BIGNUMS
    x = 1254976067 ** 256
    expect(get{@encoder.write_fixnum(x)}).to eq(get_erl("#{x}"))
    expect(get{@encoder.write_fixnum(-x)}).to eq(get_erl("-#{x}"))
    # get{@encoder.write_fixnum((1 << (255 * 8)))}.should == get_erl("#{(1 << (255 * 8))}")
    # get{@encoder.write_fixnum(-(1 << (255 * 8))}.should == get_erl("#{-(1 << (255 * 8)}")
    # get{@encoder.write_fixnum((1 << (512 * 8))}.should == get_erl("#{(1 << (512 * 8))}")
    # get{@encoder.write_fixnum(-((1 << (512 * 8)) - 1))}.should == get_erl("#{-((1 << (512 * 8)) - 1)}")
    #
    # write_any((1 << (255 * 8))).should == get_erl_with_magic("#{(1 << (255 * 8))}")
    # write_any(-(1 << (255 * 8)).should == get_erl_with_magic("#{-(1 << (255 * 8)}")
    # write_any((1 << (512 * 8))).should == get_erl_with_magic("#{(1 << (512 * 8))}")
    # write_any(-((1 << (512 * 8)) - 1)).should == get_erl_with_magic("#{-((1 << (512 * 8)) - 1)}")
  end

  # specify "A float (that is within the truncated precision of ruby compared to erlang) should encode as erlang does" do
  #   get{@encoder.write_float 1.0}.should == get_erl("1.0")
  #   get{@encoder.write_float -1.0}.should == get_erl("-1.0")
  #   get{@encoder.write_float 123.456}.should == get_erl("123.456")
  #   get{@encoder.write_float 123.456789012345}.should == get_erl("123.456789012345")
  # end

  specify "An Erlectiricity::NewReference should encode back to its original form" do
    ref_bin = run_erl("term_to_binary(make_ref())")
    ruby_ref = Erlectricity::Decoder.decode(ref_bin)

    expect(get{@encoder.write_new_reference(ruby_ref)}).to eq(ref_bin[1..-1])
    expect(write_any(ruby_ref)).to eq(ref_bin)
  end

  specify "An Erlectiricity::Pid should encode back to its original form" do
    pid_bin = run_erl("term_to_binary(spawn(fun() -> 3 end))")
    ruby_pid = Erlectricity::Decoder.decode(pid_bin)

    expect(get{@encoder.write_pid(ruby_pid)}).to eq(pid_bin[1..-1])
    expect(write_any(ruby_pid)).to eq(pid_bin)
  end

  specify "An array written with write_tuple should encode as erlang would a tuple" do
    expect(get{@encoder.write_tuple [1,2,3]}).to eq(get_erl("{1,2,3}"))
    expect(get{@encoder.write_tuple [3] * 255}).to eq(get_erl("{#{([3] * 255).join(',')}}"))
    expect(get{@encoder.write_tuple [3] * 256}).to eq(get_erl("{#{([3] * 256).join(',')}}"))
    expect(get{@encoder.write_tuple [3] * 512}).to eq(get_erl("{#{([3] * 512).join(',')}}"))
  end

  specify "An array should by default be written as a tuple" do
    expect(write_any([1,2,3])).to eq(get_erl_with_magic("{1,2,3}"))
    expect(write_any([3] * 255)).to eq(get_erl_with_magic("{#{([3] * 255).join(',')}}"))
    expect(write_any([3] * 256)).to eq(get_erl_with_magic("{#{([3] * 256).join(',')}}"))
    expect(write_any([3] * 512)).to eq(get_erl_with_magic("{#{([3] * 512).join(',')}}"))
  end

  specify "An Erlectricity::List should by default be written as a list" do
    expect(write_any(Erl::List.new([1,2,300]))).to eq(get_erl_with_magic("[1,2,300]"))
    expect(write_any(Erl::List.new([300] * 255))).to eq(get_erl_with_magic("[#{([300] * 255).join(',')}]"))
    expect(write_any(Erl::List.new([300] * 256))).to eq(get_erl_with_magic("[#{([300] * 256).join(',')}]"))
    expect(write_any(Erl::List.new([300] * 512))).to eq(get_erl_with_magic("[#{([300] * 512).join(',')}]"))
  end

  specify "An array written with write_list should encode as erlang would a list" do
    expect(get{@encoder.write_list [1,2,300]}).to eq(get_erl("[1,2,300]"))
    expect(get{@encoder.write_list [300] * 255}).to eq(get_erl("[#{([300] * 255).join(',')}]"))
    expect(get{@encoder.write_list [300] * 256}).to eq(get_erl("[#{([300] * 256).join(',')}]"))
    expect(get{@encoder.write_list [300] * 512}).to eq(get_erl("[#{([300] * 512).join(',')}]"))
  end

  specify "a string should be encoded as a erlang binary would be" do
    expect(get{@encoder.write_binary "hey who"}).to eq(get_erl("<< \"hey who\" >>"))
    expect(get{@encoder.write_binary ""}).to eq(get_erl("<< \"\" >>"))
    expect(get{@encoder.write_binary "c\000c"}).to eq(get_erl("<< 99,0,99 >>"))

    expect(write_any("hey who")).to eq(get_erl_with_magic("<< \"hey who\" >>"))
    expect(write_any("")).to eq(get_erl_with_magic("<< \"\" >>"))
  end

  specify "a hash should be encoded as a erlang map would be" do
    expect(get{@encoder.write_hash({:options => {:struct => {[1,2,3] => "I'm chargin' mah lazer"}}, "passage" => "Why doesn't this work?"})}).to eq(
      get_erl(%Q-\#{options => \#{struct => \#{{1,2,3} => <<"I'm chargin' mah lazer">>}}, <<"passage">> => <<"Why doesn't this work?">>}-))
  end

  specify "an empty hash should be encoded as a erlang map would be" do
    expect(get{@encoder.write_hash({})}).to eq(
      get_erl(%Q-\#{}-))
  end

  def get
    @encoder.out = StringIO.new('', 'w')
    yield
    @encoder.out.string
  end

  def write_any(term)
    @encoder.out = StringIO.new('', 'w')
    @encoder.write_any term
    @encoder.out.string
  end

  def get_erl(str)
    get_erl_with_magic(str)[1..-1] #[1..-1] to chop off the magic number
  end

  def get_erl_with_magic(str)
    run_erl("term_to_binary(#{str.gsub(/"/, '\\\"')})")
  end
end
