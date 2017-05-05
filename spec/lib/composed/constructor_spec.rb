require 'spec_helper'

describe Composed do
  let(:target) do
    double("TARGET", in_the_constructor: true).tap do |dub|
      allow(dub).to receive(:new).and_return(dub)
    end
  end

  subject! { target }

  describe "#new" do
    before { composed.new }
    
    context "when using the constructor" do
      let(:composed) do
        Composed(target) do
          constructor do
            in_the_constructor
          end
        end
      end

      it { is_expected.to have_received(:in_the_constructor) }
    end

    context "when not using the constructor" do
      let(:composed) do
        Composed(target) do
        end
      end

      it { is_expected.not_to have_received(:in_the_constructor) }
    end

  end
end
