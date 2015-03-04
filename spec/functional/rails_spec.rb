require 'spec_helper'

describe "Documents with the Rails plugin" do
  let(:doc) { Doc {
    key :foo, String
    key :long_field, String, :alias => "lf"
   }}

  context "with values from the DB" do
    subject { doc.create(:foo => "bar", :long_field => "long value") }
    it "should have x_before_type_cast" do
      subject.foo_before_type_cast.should == "bar"
    end

    it "should have x_before_type_cast for aliased fields" do
      subject.long_field_before_type_cast.should == "long value"
    end

    it "should honor app-set values over DB-set values" do
      subject.foo = nil
      subject.foo_before_type_cast.should == nil
    end
  end

  context "when blank" do
    subject { doc.create() }
    it "should have x_before_type_cast" do
      subject.foo_before_type_cast.should == nil
    end

    it "should honor app-set values over DB-set values" do
      subject.foo = nil
      subject.foo_before_type_cast.should == nil

      subject.foo = :baz
      subject.foo_before_type_cast.should == :baz

      subject.save
      subject.reload.foo_before_type_cast.should == "baz"
    end
  end

  context "#has_one" do
    subject do
      Doc do
        has_one :foo
      end
    end

    it "should create a one association" do
      subject.associations.should have_key :foo
      subject.associations[:foo].should be_a MarkMapper::Plugins::Associations::OneAssociation
    end
  end
end
