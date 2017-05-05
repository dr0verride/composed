require 'spec_helper'

describe Composed do
  let(:target) do
    klass = Class.new do
      def initialize(first, second, third); end
    end

    allow(klass).to receive(:new).and_call_original
    klass
  end

  subject! { target }

  describe "#new" do
    context "when using the override strategy" do
      context "when injecting all positions" do
        let(:composed) do
          Composed(target) do
            dep 1 { 2 }
            dep { 3 }
            dep 0 { 1 }
          end
        end

        context "when overriding no arguments" do
          before { composed.new }
          it { is_expected.to have_received(:new).with(1,2,3) }
        end

        context "when overriding some arguments" do
          before { composed.new(9) }
          it { is_expected.to have_received(:new).with(9,2,3) }
        end

        context "when overriding all arguments" do
          before { composed.new(9,8,7) }
          it { is_expected.to have_received(:new).with(9,8,7) }
        end
      end

      context "when injecting some positions" do
        let(:composed) do
          Composed(target) do
            dep 2 { 13 }
            dep 1 { 12 }
          end
        end

        context "when overriding no arguments" do
          it { expect{composed.new}.to raise_error(ArgumentError) }
        end

        context "when overriding some arguments" do
          before { composed.new(9) }
          it { is_expected.to have_received(:new).with(9,12,13) }
        end

        context "when overriding all arguments" do
          before { composed.new(9,8,7) }
          it { is_expected.to have_received(:new).with(9,8,7) }
        end
      end
    end

    context "when using the skip strategy" do
      before { Composed::Positional.strategy = :skip }
      context "when injecting all positions" do
        let(:composed) do
          Composed(target) do
            dep 1 { 2 }
            dep { 3 }
            dep 0 { 1 }
          end
        end

        context "when passing no arguments" do
          before { composed.new }
          it { is_expected.to have_received(:new).with(1,2,3) }
        end

        context "when passing too many arguments" do
          it { expect{ composed.new(9) }.to raise_error(ArgumentError) }
          it { expect{composed.new(9,8,7)}.to raise_error(ArgumentError) }
        end
      end

      context "when injecting middle positions" do
        let(:composed) do
          Composed(target) do
            dep 1 { 12 }
          end
        end

        context "when passing not enough arguments" do
          it { expect{composed.new}.to raise_error(ArgumentError) }
          it { expect{composed.new(9)}.to raise_error(ArgumentError) }
        end

        context "when passing enough" do
          before { composed.new(9,8) }
          it { is_expected.to have_received(:new).with(9,12,8) }
        end
      end

      context "when injecting tail positions" do
        let(:composed) do
          Composed(target) do
            dep 1 { 12 }
            dep { 13 }
          end
        end

        context "when passing not enough arguments" do
          it { expect{composed.new}.to raise_error(ArgumentError) }
          it { expect{composed.new(9,8)}.to raise_error(ArgumentError) }
        end

        context "when passing enough" do
          before { composed.new(9) }
          it { is_expected.to have_received(:new).with(9,12,13) }
        end
      end
    end
  end

end
