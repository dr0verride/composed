require 'spec_helper'

describe Composed do
  let(:target) do
    klass = Class.new do
      def initialize(first:, second:, third:); end
    end

    allow(klass).to receive(:new).and_call_original
    klass
  end

  subject! { target }

  describe "#new" do
    context "when injecting all positions" do
      let(:composed) do
        Composed(target) do
          dependency(:second) { 2 }
          dependency(:third) { 3 }
          dependency(:first) { 1 }
        end
      end

      context "when overriding no arguments" do
        before { composed.new }
        it { is_expected.to have_received(:new).with(first: 1, second: 2, third: 3) }
      end

      context "when overriding some arguments" do
        before { composed.new(first: 9) }
        it { is_expected.to have_received(:new).with(first: 9, second: 2, third: 3) }
      end

      context "when overriding all arguments" do
        before { composed.new(first: 9, second: 8, third: 7) }
        it { is_expected.to have_received(:new).with(first: 9, second: 8, third: 7) }
      end
    end

    context "when injecting some positions" do
      let(:composed) do
        Composed(target) do
          dependency(:first) { 11 }
          dependency(:second) { 12 }
        end
      end

      context "when overriding no arguments" do
        it { expect{composed.new}.to raise_error(ArgumentError) }
      end

      context "when overriding some arguments" do
        before { composed.new(third: 9) }
        it { is_expected.to have_received(:new).with(first: 11, second: 12, third: 9) }
      end

      context "when overriding all arguments" do
        before { composed.new(first: 9, third: 8) }
        it { is_expected.to have_received(:new).with(first: 9, third: 8, second: 12) }
      end
    end

  end
end
