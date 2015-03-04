require 'spec_helper'

describe "Extensions" do
  context "DocumentNotValid" do
    it "should have document reader method" do
      doc_class = Doc()
      instance  = doc_class.new
      exception = MarkMapper::DocumentNotValid.new(instance)
      exception.document.should == instance
    end
  end
end
