require 'spec_helper'

context "When unpacking from a binary stream" do
  specify "an erlang atom should decode to a ruby symbol" do
    expect(get("haha")).to eq(:haha)
  end

  specify "an erlang number encoded as a small_int (< 255) should decode to a fixnum" do
    expect(get("0")).to eq(0)
    expect(get("255")).to eq(255)
  end

  specify "an erlang number encoded as a int (signed 27-bit number) should decode to a fixnum" do
    expect(get("256")).to eq(256)
    expect(get("#{(1 << 27) -1}")).to eq((1 << 27) -1)
    expect(get("-1")).to eq(-1)
    expect(get("#{-(1 << 27)}")).to eq(-(1 << 27))
  end

  specify "an erlang number encoded as a small bignum (1 byte length) should decode to fixnum if it can" do
    expect(get("#{(1 << 27)}")).to eq(1 << 27)
    expect(get("#{-(1 << 27) - 1}")).to eq(-(1 << 27) - 1)
    expect(get("#{(1 << word_length) - 1}")).to eq((1 << word_length) - 1)
    expect(get("#{-(1 << word_length)}")).to eq(-(1 << word_length))
  end

  specify "an erlang number encoded as a small bignum (1 byte length) should decode to bignum if it can't be a fixnum" do
    expect(get("#{(1 << word_length)}")).to eq(1 << word_length)
    expect(get("#{-(1 << word_length) - 1}")).to eq(-(1 << word_length) - 1)
    expect(get("#{(1 << (255 * 8)) - 1}")).to eq((1 << (255 * 8)) - 1)
    expect(get("#{-((1 << (255 * 8)) - 1)}")).to eq(-((1 << (255 * 8)) - 1))
  end

  specify "an erlang number encoded as a big bignum (4 byte length) should decode to bignum" do
    expect(get("#{(1 << (255 * 8)) }")).to eq(1 << (255 * 8))
    expect(get("#{-(1 << (255 * 8))}")).to eq(-(1 << (255 * 8)))
    expect(get("#{(1 << (512 * 8)) }")).to eq(1 << (512 * 8))
    expect(get("#{-(1 << (512 * 8))}")).to eq(-(1 << (512 * 8)))
  end

  specify "an erlang float should decode to a Float" do
    expect(get("#{1.0}")).to eq(1.0)
    expect(get("#{-1.0}")).to eq(-1.0)
    expect(get("#{123.456}")).to eq(123.456)
    expect(get("#{123.456789012345}")).to eq(123.456789012345)
  end

  specify "an erlang reference should decode to a Reference object" do
    ref = get("make_ref()")
    expect(ref).to be_instance_of Erlectricity::NewReference
    expect(ref.node).to be_instance_of Symbol
  end

  specify "an erlang pid should decode to a Pid object" do
    pid = get("spawn(fun() -> 3 end)")
    expect(pid).to be_instance_of Erlectricity::Pid
    expect(pid.node).to be_instance_of Symbol
  end

  specify "an erlang tuple encoded as a small tuple (1-byte length) should decode to an array" do
    ref = get("{3}")
    expect(ref.length).to eq(1)
    expect(ref.first).to eq(3)

    ref = get("{3, a, make_ref()}")
    expect(ref.length).to eq(3)
    expect(ref[0]).to eq(3)
    expect(ref[1]).to eq(:a)
    expect(ref[2].class).to eq(Erlectricity::NewReference)

    tuple_meat = (['3'] * 255).join(', ')
    ref = get("{#{tuple_meat}}")
    expect(ref.length).to eq(255)
    ref.each{|r| expect(r).to eq(3)}
  end

  specify "an erlang tuple encoded as a large tuple (4-byte length) should decode to an array" do
    tuple_meat = (['3'] * 256).join(', ')
    ref = get("{#{tuple_meat}}")
    expect(ref.length).to eq(256)
    ref.each{|r| expect(r).to eq(3)}

    tuple_meat = (['3'] * 512).join(', ')
    ref = get("{#{tuple_meat}}")
    expect(ref.length).to eq(512)
    ref.each{|r| expect(r).to eq(3)}
  end

  specify "an empty erlang list encoded as a nil should decode to an array" do
    expect(get("[]").class).to eq(Erl::List)
    expect(get("[]")).to eq([])
  end

  specify "an erlang list encoded as a string should decode to an array of bytes (less than ideal, but consistent)" do
    expect(get("\"asdasd\"").class).to eq(Erl::List)
    expect(get("\"asdasd\"")).to eq("asdasd".each_char.map(&:ord))
    expect(get("\"#{'a' * 65534}\"")).to eq(['a'.ord] * 65534)
  end

  specify "an erlang list encoded as a list should decode to an erl::list" do
    expect(get("[3,4,256]").class).to eq(Erl::List)
    expect(get("[3,4,256]")).to eq([3,4,256])
    expect(get("\"#{'a' * 65535 }\"")).to eq([97] * 65535)
    expect(get("[3,4, foo, {3,4,5,bar}, 256]")).to eq([3,4, :foo, [3,4,5,:bar], 256])
  end

  specify "an erlang binary should decode to a string" do
    expect(get("<< 3,4,255 >>")).to eq("\003\004\377".force_encoding("ASCII-8BIT"))
    expect(get("<< \"whatup\" >>")).to eq("whatup")
    expect(get("<< 99,0,99 >>")).to eq("c\000c".force_encoding("ASCII-8BIT"))
  end

  specify "the empty atom should decode to the empty symbol" do
    expect(get("''")).to eq(:"")
  end

  specify "erlang atomic booleans should decode to ruby booleans" do
    expect(get("true")).to eq(true)
    expect(get("false")).to eq(false)
    expect(get("falsereio")).to eq(:falsereio)
    expect(get("t")).to eq(:t)
    expect(get("f")).to eq(:f)
  end

  specify "massive binaries should not overflow the stack" do
    bin = [131,109,0,128,0,0].pack('c*') + ('a' * (8 * 1024 * 1024))
    expect(Erlectricity::Decoder.decode(bin).size).to eq(8 * 1024 * 1024)
  end

  specify "a good thing should be awesome" do
    expect(get(%Q-[{options,{struct,[{test,<<"I'm chargin' mah lazer">>}]}},{passage,<<"Why doesn't this work?">>}]-)).to eq(
    [[:options, [:struct, [[:test, "I'm chargin' mah lazer"]]]], [:passage, "Why doesn't this work?"]]
    )
  end

  def get(str)
    x = "term_to_binary(#{str.gsub(/"/, '\\\"')})"
    bin = run_erl(x)
    Erlectricity::Decoder.decode(bin)
  end
end
