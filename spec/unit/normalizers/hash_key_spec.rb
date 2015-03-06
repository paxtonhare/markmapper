require 'spec_helper'

describe MarkMapper::Normalizers::HashKey do
  subject {
    described_class.new(:bacon => :sizzle)
  }

  it "changes defined fields" do
    subject.call(:bacon).should eq(:sizzle)
  end

  it "does not change undefined fields" do
    subject.call(:sausage).should eq(:sausage)
  end
end
