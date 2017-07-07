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

  describe "#factory" do
    context "when injecting all positions" do
      let(:composed) do
        Composed(target) do
          dependency(:first) { 1 }

          factory(:specialized) do
            dependency(:second) { 2 }
            dependency(:third) { 3 }
          end
          
          factory(:other_version) do
            dependency(:second) { 222 }
            dependency(:third) { 333 }
          end
        end
      end

      context "when overriding no specialized arguments" do
        before { composed.specialized }
        it { is_expected.to have_received(:new).with(first: 1, second: 2, third: 3) }
      end

      context "when overriding no other_version arguments" do
        before { composed.other_version }
        it { is_expected.to have_received(:new).with(first: 1, second: 222, third: 333) }
      end

      context "when overriding all specialized arguments" do
        before { composed.specialized(first: 9, second: 8, third: 7) }
        it { is_expected.to have_received(:new).with(first: 9, second: 8, third: 7) }
      end

      context "when overriding all other_version arguments" do
        before { composed.other_version(first: 9, second: 8, third: 7) }
        it { is_expected.to have_received(:new).with(first: 9, second: 8, third: 7) }
      end
    end
  end
end

