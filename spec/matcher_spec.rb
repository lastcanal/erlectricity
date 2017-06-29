require 'spec_helper'

def false_match(matcher, arg)
   expect(matcher.matches?(arg)).to eq(false)
end

context "A matcher whose condition is a String (the class object" do
  before do
    @matcher = Erlectricity::Matcher.new(nil, Erlectricity::TypeCondition.new(String), nil)
  end

  specify "should match any string" do
    expect(@matcher.matches?("foo")).to eq(true)
  end

  specify "should not match symbols" do
    expect(@matcher.matches?(:foo)).to eq(false)
  end
end

context "A matcher whose condition is Symbol (the class object)" do
  before do
    @matcher = Erlectricity::Matcher.new(nil, Erlectricity::TypeCondition.new(Symbol), nil)
  end

  specify "should match any symbol" do
    expect(@matcher.matches?(:foo)).to eq(true)
    expect(@matcher.matches?(:bar)).to eq(true)
    expect(@matcher.matches?(:baz)).to eq(true)
  end

  specify "should not match strings" do
    expect(@matcher.matches?("foo")).to eq(false)
    expect(@matcher.matches?("bar")).to eq(false)
    expect(@matcher.matches?("baz")).to eq(false)
  end

  specify "should not match a arrays" do
    expect(@matcher.matches?([:foo])).to eq(false)
    expect(@matcher.matches?([:foo, :bar])).to eq(false)
    expect(@matcher.matches?([:foo, :bar, :baz])).to eq(false)
  end
end

context "a matcher whose condition is a symbol" do
  before do
    @matcher = Erlectricity::Matcher.new(nil, Erlectricity::StaticCondition.new(:foo), nil)
  end

  specify "should match that symbol" do
    expect(@matcher.matches?(:foo)).to eq(true)
  end

  specify "should not match any other symbol" do
    expect(@matcher.matches?(:bar)).to eq(false)
    expect(@matcher.matches?(:baz)).to eq(false)
  end
end

context "a matcher whose matcher is an array" do

  specify "should match if all of its children match" do
    expect(Erlectricity::Matcher.new(nil, [Erlectricity::StaticCondition.new(:speak), Erlectricity::TypeCondition.new(Object)], nil).matches?([:paste, "haha"])).to eq(false)

    matcher = Erlectricity::Matcher.new(nil, [Erlectricity::StaticCondition.new(:foo), Erlectricity::StaticCondition.new(:bar)], nil)
    expect(matcher.matches?([:foo, :bar])).to eq(true)
  end

  specify "should not match any of its children dont match" do
    matcher = Erlectricity::Matcher.new(nil, [Erlectricity::StaticCondition.new(:foo), Erlectricity::StaticCondition.new(:bar)], nil)
    expect(matcher.matches?([:foo])).to eq(false)
    expect(matcher.matches?([:foo, :bar, :baz])).to eq(false)
    expect(matcher.matches?([:fooo, :barr])).to eq(false)
    expect(matcher.matches?([3, :bar])).to eq(false)
  end

  specify "should not match if arg isn't an array" do
    matcher = Erlectricity::Matcher.new(nil, [Erlectricity::StaticCondition.new(:foo), Erlectricity::StaticCondition.new(:bar)], nil)
    expect(matcher.matches?(:foo)).to eq(false)
  end
end
