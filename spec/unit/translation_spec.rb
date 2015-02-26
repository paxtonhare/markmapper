require 'spec_helper'

describe "Translation" do
  it "should translate add mark_mapper translations" do
    I18n.translate("mark_mapper.errors.messages.taken").should == "has already been taken"
  end

  it "should set i18n_scope" do
    Doc().i18n_scope.should == :mark_mapper
  end

  it "should translate document attributes" do
    I18n.config.backend.store_translations(:en, :mark_mapper => {:attributes => {:thing => {:foo => 'Bar'}}})
    doc = Doc('Thing') do
      key :foo, String
    end
    doc.human_attribute_name(:foo).should == 'Bar'
  end

  it "should translate embedded document attributes" do
    I18n.config.backend.store_translations(:en, :mark_mapper => {:attributes => {:thing => {:foo => 'Bar'}}})
    doc = EDoc('Thing') do
      key :foo, String
    end
    doc.human_attribute_name(:foo).should == 'Bar'
  end
end