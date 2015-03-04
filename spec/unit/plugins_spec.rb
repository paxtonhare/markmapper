require 'spec_helper'

describe "Plugins" do
  it "should default plugins to empty array" do
    Class.new { extend MarkMapper::Plugins }.plugins.should == []
  end

  context "a plugin" do
    module MyConcern
      extend ActiveSupport::Concern

      included do
        attr_accessor :from_concern
      end

      module ClassMethods
        def class_foo
          'class_foo'
        end
      end

      def instance_foo
        'instance_foo'
      end
    end

    before do
      @document = Class.new do
        extend MarkMapper::Plugins
        plugin MyConcern
      end
    end

    it "should include instance methods" do
      @document.new.instance_foo.should == 'instance_foo'
    end

    it "should extend class methods" do
      @document.class_foo.should == 'class_foo'
    end

    it "should pass model to configure" do
      @document.new.should respond_to(:from_concern)
    end

    it "should add plugin to plugins" do
      @document.plugins.should include(MyConcern)
    end

    context "Document" do
      before do
        MarkMapper::Document.plugins.delete(MyConcern)
      end

      it 'should allow plugins on Document' do
        MarkMapper::Document.plugin(MyConcern)
        Doc().should respond_to(:class_foo)
        Doc().new.should respond_to(:instance_foo)
      end

      it 'should add plugins to classes that include Document before they are added' do
        article = Doc()
        MarkMapper::Document.plugin(MyConcern)
        article.should respond_to(:class_foo)
        article.new.should respond_to(:instance_foo)
      end
    end

    context "EmbeddedDocument" do
      before do
        MarkMapper::EmbeddedDocument.plugins.delete(MyConcern)
      end

      it 'should allow plugins on EmbeddedDocument' do
        MarkMapper::EmbeddedDocument.plugin(MyConcern)
        article = EDoc()
        article.should respond_to(:class_foo)
        article.new.should respond_to(:instance_foo)
      end

      it 'should add plugins to classes that include EmbeddedDocument before they are added' do
        article = EDoc()
        MarkMapper::EmbeddedDocument.plugin(MyConcern)
        article.should respond_to(:class_foo)
        article.new.should respond_to(:instance_foo)
      end
    end
  end
end
