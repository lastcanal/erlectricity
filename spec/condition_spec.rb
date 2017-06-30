require 'spec_helper'

context "Erlectricity::StaticConditions" do
  specify "should satisfy on the same value" do
    expect(Erlectricity::StaticCondition.new(:foo).satisfies?(:foo)).to eq(true)
    expect(Erlectricity::StaticCondition.new([:foo]).satisfies?([:foo])).to eq(true)
    expect(Erlectricity::StaticCondition.new(3).satisfies?(3)).to eq(true)
  end

  specify "should not satisfy on different values" do
    expect(Erlectricity::StaticCondition.new(:foo).satisfies?("foo")).to eq(false)
    expect(Erlectricity::StaticCondition.new([:foo]).satisfies?(:foo)).to eq(false)
    expect(Erlectricity::StaticCondition.new(Object.new).satisfies?(Object.new)).to eq(false)
    expect(Erlectricity::StaticCondition.new(3).satisfies?(3.0)).to eq(false)
  end

  specify "should not produce any bindings" do
    s = Erlectricity::StaticCondition.new(:foo)
    expect(s.binding_for(:foo)).to eq(nil)
  end
end

context "Erlectricity::TypeConditions" do
  specify "should be satisfied when the arg has the same class" do
    expect(Erlectricity::TypeCondition.new(Symbol).satisfies?(:foo)).to eq(true)
    expect(Erlectricity::TypeCondition.new(Symbol).satisfies?(:bar)).to eq(true)
    expect(Erlectricity::TypeCondition.new(String).satisfies?("foo")).to eq(true)
    expect(Erlectricity::TypeCondition.new(String).satisfies?("bar")).to eq(true)
    expect(Erlectricity::TypeCondition.new(Array).satisfies?([])).to eq(true)
    expect(Erlectricity::TypeCondition.new(Fixnum).satisfies?(3)).to eq(true)
  end

  specify "should be satisfied when the arg is of a descendent class" do
    expect(Erlectricity::TypeCondition.new(Object).satisfies?(:foo)).to eq(true)
    expect(Erlectricity::TypeCondition.new(Object).satisfies?("foo")).to eq(true)
    expect(Erlectricity::TypeCondition.new(Object).satisfies?(3)).to eq(true)
  end

  specify "should not be satisfied when the arg is of a different class" do
    expect(Erlectricity::TypeCondition.new(String).satisfies?(:foo)).to eq(false)
    expect(Erlectricity::TypeCondition.new(Symbol).satisfies?("foo")).to eq(false)
    expect(Erlectricity::TypeCondition.new(Fixnum).satisfies?(3.0)).to eq(false)
  end

  specify "should bind the arg with no transormations" do
    s = Erlectricity::TypeCondition.new(Symbol)
    expect(s.binding_for(:foo)).to eq(:foo)
    expect(s.binding_for(:bar)).to eq(:bar)
  end
end

context "Erlectricity::HashConditions" do
  specify "should satisfy an args of the form [[key, value], [key, value]]" do
    expect(Erlectricity::HashCondition.new.satisfies?(Erl::List.new([[:foo, 3], [:bar, Object.new]]))).to eq(true)
    expect(Erlectricity::HashCondition.new.satisfies?(Erl::List.new([[:foo, 3]]))).to eq(true)
  end

  specify "should satisfy on empty arrays" do
    expect(Erlectricity::HashCondition.new.satisfies?(Erl::List.new([]))).to eq(true)
  end

  specify "should nat satisfy other args" do
     expect(Erlectricity::HashCondition.new.satisfies?(:foo)).to eq(false)
     expect(Erlectricity::HashCondition.new.satisfies?("foo")).to eq(false)
     expect(Erlectricity::HashCondition.new.satisfies?(3.0)).to eq(false)
  end

  specify "should bind to a Hash" do
    s = Erlectricity::HashCondition.new()
    expect(s.binding_for([[:foo, 3], [:bar, [3,4,5]]])).to eq({:foo => 3, :bar => [3,4,5] })
  end
end
