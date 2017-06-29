require 'spec_helper'

def simple_receiver_and_port(*terms, &block)
  port = FakePort.new(*terms)
  receiver = if block
      Erlectricity::Receiver.new(port, &block)
    else
      Erlectricity::Receiver.new(port) do |f|
        f.when Erl.any do
          :matched
        end
      end
    end
end

context "When a receiver is passed a message that matches two match blocks it" do
  before do
    @port = FakePort.new([:foo, :foo])
    @receiver = Erlectricity::Receiver.new(@port) do |f|
      f.when([:foo, :foo]) do
        :first
      end

      f.when([:foo, Erl.any]) do
        :second
      end
    end
  end

  specify "should run the first matching receiver's block" do
    expect(@receiver.run).to eq(:first)
  end
end

context "A receiver" do
  specify "should return the result of the match block when finished" do
    expect(simple_receiver_and_port(:foo).run).to eq(:matched)
    expect(simple_receiver_and_port(:bar).run).to eq(:matched)
    expect(simple_receiver_and_port(:bar, :baz).run).to eq(:matched)
  end

  specify "should process another message if the matched block returns the results of receive_loop" do
    recv = simple_receiver_and_port(:foo, :bar, :baz) do |f|
      f.when(:bar) {  }
      f.when(Erl.any) { f.receive_loop }
    end

    recv.run
    expect(recv.port.terms).to eq([:baz])
  end

  specify "should properly nest" do
    @port = FakePort.new(:foo, :bar, :baz)
    @receiver = Erlectricity::Receiver.new(@port) do |f|
      f.when(:foo) do
        f.receive do |g|
          g.when(:bar){ :ok }
        end
        f.receive_loop
      end

      f.when(:baz) do
        :done
      end
    end

    expect(@receiver.run).to eq(:done)
    expect(@port.terms).to eq([])
  end

  specify "should queue up skipped results and restore them when a match happens" do
    @port = FakePort.new(:foo, :baz, :bar)
    @receiver = Erlectricity::Receiver.new(@port) do |f|
      f.when(:foo) do
        f.receive do |g|
          g.when(:bar){ :ok }
        end
        f.receive_loop
      end

      f.when(:baz) do
        :done
      end
    end

    expect(@receiver.run).to eq(:done)
    expect(@port.terms).to eq([])
  end

  specify "should expose bindings to the matched block" do
    @port = FakePort.new(:foo, :bar, :baz)
    results = []
    @receiver = Erlectricity::Receiver.new(@port) do |f|
      f.when(Erl.atom) do |bindinated|
        results << bindinated
        f.receive_loop
      end
    end

    expect(@receiver.run).to eq(nil)
    expect(results).to eq([:foo, :bar, :baz])
  end
end
