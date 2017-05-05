require 'spec_helper'

__END__
describe Composed do
  let(:compose_pos) do
    Composed(target_pos) do
      dep { 1 }
      dep { 2 }
      dep { 3 }
      
      specialize(:with_w) do
        dep { 5 }
      end
    end
  end

  let(:target_pos) do
    Class.new do
      def initialize(first, second, third)
      end
    end.tap do |doub|
      allow(doub).to receive(:new).and_call_original
    end
  end

  let(:compose_kw) do
    Composed(target) do
      dep :a { 'a' }
      dep :b { 'b' }
      dep :c { 'c' }

      specialize(:with_w) do
        dep :a { 'w' }
        dep :w { 'w' }
      end
    end
  end

  let(:compose_mixed) do
    Composed(target) do
      dep { 1 }
      dep { 2 }
      dep { 3 }
      dep :a { 'a' }
      dep :b { 'b' }
      dep :c { 'c' }

      specialize(:with_w) do
        dep { 'w' }
        dep :a { 'w' }
      end

      constructor do
        self.in_ctor
      end
    end
  end

  let(:target) do
    double("TARGET", in_ctor: true).tap do |dub|
      allow(dub).to receive(:new).and_return(dub)
    end
  end

  subject! { target }

  context "when using positional params" do
    let(:composed) do
      Composed(target) do
        dep { 1 }
        dep { 2 }
        dep { 3 }
        
        specialize(:with_w) do
          dep { 5 }
        end
      end
    end

    describe "#new" do
      context "when overriding no arguments" do
        before { composed.new }
        it { is_expected.to have_received(:new).with(1,2,3) }
      end

      context "when overriding positional arguments" do
        before { composed.new(9,8) }
        it { is_expected.to have_received(:new).with(9,8,3) }
      end

      context "when overriding keyword arguments" do
        before { composed.new(a: 'z') }
        it { is_expected.to have_received(:new).with(1,2,3,a: 'z') }
      end

      context "when overriding both arguments" do
        before { composed.new(9,8,a: 'z') }
        it { is_expected.to have_received(:new).with(9,8,3,a: 'z') }
      end
    end

    describe "#specialize" do
      context "when overriding no arguments" do
        before { composed.with_w }
        it { is_expected.to have_received(:new).with(5,2,3) }
      end

      context "when overriding positional arguments" do
        before { composed.with_w(9,8) }
        it { is_expected.to have_received(:new).with(9,8,3) }
      end

      context "when overriding keyword arguments" do
        before { composed.with_w(a: 'z') }
        it { is_expected.to have_received(:new).with(5,2,3) }
      end

      let(:k) { {a: 'z'} }

      context "when overriding both arguments" do
        before { composed.with_w(1,9,k) }
        it { is_expected.to have_received(:new).with(1,9,a: 'z') }
      end
    end
  end
  
  context "when using keyword params" do
    describe "#new" do
      context "when overriding no arguments" do
        before { compose_kw.new }
        it { is_expected.to have_received(:new).with(a: 'a', b: 'b', c: 'c') }
      end

      context "when overriding positional arguments" do
        before { compose_kw.new(9,8) }
        it { is_expected.to have_received(:new).with(9,8,a: 'a', b: 'b', c: 'c') }
      end

      context "when overriding keyword arguments" do
        before { compose_kw.new(a: 'z') }
        it { is_expected.to have_received(:new).with(a: 'z', b: 'b', c: 'c') }
      end

      context "when overriding both arguments" do
        before { compose_kw.new(9,8, a: 'z') }
        it { is_expected.to have_received(:new).with(9,8,a: 'z', b: 'b', c: 'c') }
      end
    end

    describe "#specialize" do
      context "when overriding no arguments" do
        before { compose_kw.with_w }
        it { is_expected.to have_received(:new).with(a: 'w', b: 'b', c: 'c', w: 'w') }
      end

      context "when overriding positional arguments" do
        before { compose_kw.with_w(9,8) }
        it { is_expected.to have_received(:new).with(9,8,a: 'w', b: 'b', c: 'c', w: 'w') }
      end

      context "when overriding keyword arguments" do
        before { compose_kw.with_w(a: 'z') }
        it { is_expected.to have_received(:new).with(a: 'z', b: 'b', c: 'c', w: 'w') }
      end

      context "when overriding both arguments" do
        before { compose_kw.with_w(9,8, a: 'z') }
        it { is_expected.to have_received(:new).with(9,8,w: 'w', a: 'z', b: 'b', c: 'c') }
      end
    end
  end

  context "when using mixed params" do
    describe "#new" do
      context "when overriding no arguments" do
        before { compose_mixed.new }
        it { is_expected.to have_received(:new).with(1,2,3,a: 'a', b: 'b', c: 'c') }
        it { is_expected.to have_received(:in_ctor) }
      end

      context "when overriding positional arguments" do
        before { compose_mixed.new(9,8) }
        it { is_expected.to have_received(:new).with(9,8,3,a: 'a', b: 'b', c: 'c') }
        it { is_expected.to have_received(:in_ctor) }
      end

      context "when overriding keyword arguments" do
        before { compose_mixed.new(a: 'z', b: 'y') }
        it { is_expected.to have_received(:new).with(1,2,3,a: 'z', b: 'y', c: 'c') }
        it { is_expected.to have_received(:in_ctor) }
      end

      context "when overriding both arguments" do
        before { compose_mixed.new(9,8,7,6,a: 'z', b: 'y') }
        it { is_expected.to have_received(:new).with(9,8,7,6,a: 'z', b: 'y', c: 'c') }
        it { is_expected.to have_received(:in_ctor) }
      end
    end
    describe "#specialize" do
      context "when overriding no arguments" do
        before { compose_mixed.with_w }
        it { is_expected.to have_received(:new).with('w',2,3,a: 'w', b: 'b', c: 'c') }
        it { is_expected.to have_received(:in_ctor) }
      end

      context "when overriding positional arguments" do
        before { compose_mixed.with_w(9,8) }
        it { is_expected.to have_received(:new).with(9,8,3,a: 'w', b: 'b', c: 'c') }
        it { is_expected.to have_received(:in_ctor) }
      end

      context "when overriding keyword arguments" do
        before { compose_mixed.with_w(a: 'z', b: 'y') }
        it { is_expected.to have_received(:new).with('w',2,3,a: 'z', b: 'y', c: 'c') }
        it { is_expected.to have_received(:in_ctor) }
      end

      context "when overriding both arguments" do
        before { compose_mixed.with_w(9,8,7,6,a: 'z', b: 'y') }
        it { is_expected.to have_received(:new).with(9,8,7,6,a: 'z', b: 'y', c: 'c') }
        it { is_expected.to have_received(:in_ctor) }
      end
    end
  end

  context "when using a different method as the interface" do
    let(:target) do
      double("TARGET", in_ctor: true).tap do |dub|
        allow(dub).to receive(:call).and_return(dub)
        allow(dub).to receive(:[]).and_return(dub)
      end
    end

    let(:compose_call) do
      Composed(target, :call) do
        dep { 1 }
        dep :two { 2 }
      end
    end

    describe "#call" do
      context "when not overriding any params" do
        before { compose_call.call }
        it { is_expected.to have_received(:call).with(1,two: 2) }
      end

      context "when overriding params" do
        before { compose_call.call(9, two: 3) }
        it { is_expected.to have_received(:call).with(9,two: 3) }
      end
    end

    describe "#[]" do
      context "when not overriding any params" do
        before { compose_call[] }
        it { is_expected.to have_received(:call).with(1,two: 2) }
      end

      context "when overriding params" do
        before { compose_call[9, two: 3] }
        it { is_expected.to have_received(:call).with(9,two: 3) }
      end
    end
  end
end
