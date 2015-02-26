require 'spec_helper'

module KeyOverride
  def other_child
    self[:other_child] || "special result"
  end

  def other_child=(value)
    super(value + " modified")
  end
end

describe "EmbeddedDocument", :working => true do
  context "EmbeddedDocuments" do
    before do
      class ::Grandparent
        include MarkMapper::EmbeddedDocument
        key :grandparent, String
      end

      class ::Parent < ::Grandparent
        include MarkMapper::EmbeddedDocument
        key :parent, String
      end

      class ::Child < ::Parent
        include MarkMapper::EmbeddedDocument
        key :child, String
      end

      class ::OtherChild < ::Parent
        include MarkMapper::EmbeddedDocument
        include KeyOverride

        key :other_child, String
      end

      class ::EDocWithAValidation
        include MarkMapper::EmbeddedDocument
        key :name, String, :required => true
      end

      class ::DocWithAValidation
        include MarkMapper::Document
        key :name, String, :required => true
        many :e_doc_with_a_validations
      end
    end

    after do
      Object.send :remove_const, 'Grandparent'         if defined?(::Grandparent)
      Object.send :remove_const, 'Parent'              if defined?(::Parent)
      Object.send :remove_const, 'Child'               if defined?(::Child)
      Object.send :remove_const, 'OtherChild'          if defined?(::OtherChild)
      Object.send :remove_const, 'EDocWithAValidation' if defined?(::EDocWithAValidation)
      Object.send :remove_const, 'DocWithAValidation'  if defined?(::DocWithAValidation)
    end

    context "Including MarkMapper::EmbeddedDocument in a class" do
      before do
        @klass = EDoc()
      end

      it "should add _id key" do
        @klass.keys['_id'].should_not be_nil
      end

      it "should know it is using object id" do
        @klass.using_object_id?.should be_truthy
      end

      it "should know it is not using object id if _id type is changed" do
        @klass.key :_id, String
        @klass.using_object_id?.should be_falsey
      end
    end

    context "Class Methods" do
      it "should include logger" do
        @klass = EDoc()
        @klass.logger.should == MarkMapper.logger
        @klass.logger.should be_instance_of(Logger)
      end

      it "should return false for embeddable" do
        EDoc().embeddable?.should be_truthy
      end

      context "#to_marklogic" do
        before { @klass = EDoc() }

        it "should be nil if nil" do
          @klass.to_marklogic(nil).should be_nil
        end

        it "should convert to_marklogic for other values" do
          doc = @klass.new(:foo => 'bar')
          to_marklogic = @klass.to_marklogic(doc)
          to_marklogic.is_a?(Hash).should be_truthy
          to_marklogic['foo'].should == 'bar'
        end
      end

      context "#from_marklogic" do
        before { @klass = EDoc() }

        it "should be nil if nil" do
          @klass.from_marklogic(nil).should be_nil
        end

        it "should be instance if instance of class" do
          doc = @klass.new
          @klass.from_marklogic(doc).should == doc
        end

        it "should be instance if hash of attributes" do
          doc = @klass.from_marklogic({:foo => 'bar'})
          doc.instance_of?(@klass).should be_truthy
          doc.foo.should == 'bar'
        end
      end

      context "defining a key" do
        before do
          @document = EDoc()
        end

        it "should work with name" do
          key = @document.key(:name)
          key.name.should == 'name'
        end

        it "should work with name and type" do
          key = @document.key(:name, String)
          key.name.should == 'name'
          key.type.should == String
        end

        it "should work with name, type and options" do
          key = @document.key(:name, String, :required => true)
          key.name.should == 'name'
          key.type.should == String
          key.options[:required].should be_truthy
        end

        it "should work with name and options" do
          key = @document.key(:name, :required => true)
          key.name.should == 'name'
          key.options[:required].should be_truthy
        end

        it "should be tracked per document" do
          @document.key(:name, String)
          @document.key(:age, Integer)
          @document.keys['name'].name.should == 'name'
          @document.keys['name'].type.should == String
          @document.keys['age'].name.should == 'age'
          @document.keys['age'].type.should == Integer
        end

        it "should be redefinable" do
          @document.key(:foo, String)
          @document.keys['foo'].type.should == String
          @document.key(:foo, Integer)
          @document.keys['foo'].type.should == Integer
        end

        it "should create reader method" do
          @document.new.should_not respond_to(:foo)
          @document.key(:foo, String)
          @document.new.should respond_to(:foo)
        end

        it "should create reader before type cast method" do
          @document.new.should_not respond_to(:foo_before_type_cast)
          @document.key(:foo, String)
          @document.new.should respond_to(:foo_before_type_cast)
        end

        it "should create writer method" do
          @document.new.should_not respond_to(:foo=)
          @document.key(:foo, String)
          @document.new.should respond_to(:foo=)
        end

        it "should create boolean method" do
          @document.new.should_not respond_to(:foo?)
          @document.key(:foo, String)
          @document.new.should respond_to(:foo?)
        end
      end

      context "keys" do
        it "should be inherited" do
          Grandparent.keys.keys.sort.should == ['_id', '_type', 'grandparent']
          Parent.keys.keys.sort.should == ['_id', '_type', 'grandparent', 'parent']
          Child.keys.keys.sort.should  == ['_id', '_type', 'child', 'grandparent', 'parent']
        end

        it "should propogate to descendants if key added after class definition" do
          Grandparent.key :foo, String

          Grandparent.keys.keys.sort.should == ['_id', '_type', 'foo', 'grandparent']
          Parent.keys.keys.sort.should      == ['_id', '_type', 'foo', 'grandparent', 'parent']
          Child.keys.keys.sort.should       == ['_id', '_type', 'child', 'foo', 'grandparent', 'parent']
        end

        it "should not add anonymous objects to the ancestor tree" do
          OtherChild.ancestors.any? { |a| a.name.blank? }.should be_falsey
        end

        it "should not include descendant keys" do
          lambda { Parent.new.other_child }.should raise_error
        end
      end

      context "descendants" do
        it "should default to an empty array" do
          Child.descendants.should == []
        end

        it "should be recorded" do
          Grandparent.direct_descendants.should == [Parent]
          Grandparent.descendants.to_set.should == [Parent, Child, OtherChild].to_set

          Parent.descendants.should      == [Child, OtherChild]
        end
      end
    end

    context "An instance of an embedded document" do
      before do
        @document = EDoc do
          key :name, String
          key :age, Integer
        end
      end

      it "should respond to cache_key" do
        @document.new.should respond_to(:cache_key)
      end

      it "should have access to class logger" do
        doc = @document.new
        doc.logger.should == @document.logger
        doc.logger.should be_instance_of(Logger)
      end

      it "should automatically have an _id key" do
        @document.keys.keys.should include('_id')
      end

      it "should create id during initialization" do
        @document.new._id.should be_instance_of(MarkLogic::ObjectId)
      end

      it "should have id method returns _id" do
        id = MarkLogic::ObjectId.new
        doc = @document.new(:_id => id)
        doc.id.should == id
      end

      it "should convert string object id to marklogic object id when assigning id with _id object id type" do
        id = MarkLogic::ObjectId.new
        doc = @document.new(:id => id.to_s)
        doc._id.should == id
        doc.id.should  == id
        doc = @document.new(:_id => id.to_s)
        doc._id.should == id
        doc.id.should  == id
      end

      context "_parent_document" do
        it "should default to nil" do
          @document.new._parent_document.should be_nil
          @document.new._root_document.should be_nil
        end

        it "should set _root_document when setting _parent_document" do
          root = Doc().new
          doc  = @document.new(:_parent_document => root)
          doc._parent_document.should be(root)
          doc._root_document.should be(root)
        end

        it "should set _root_document when setting _parent_document on embedded many" do
          root   = Doc().new
          klass  = EDoc { many :children }
          parent = klass.new(:_parent_document => root, :children => [{}])
          child  = parent.children.first
          child._parent_document.should be(parent)
          child._root_document.should   be(root)
        end
      end

      context "being initialized" do
        it "should accept a hash that sets keys and values" do
          doc = @document.new(:name => 'John', :age => 23)
          doc.attributes.keys.sort.should == ['_id', 'age', 'name']
          doc.attributes['name'].should == 'John'
          doc.attributes['age'].should == 23
        end

        it "should be able to assign keys dynamically" do
          doc = @document.new(:name => 'John', :skills => ['ruby', 'rails'])
          doc.name.should == 'John'
          doc.skills.should == ['ruby', 'rails']
        end

        it "should not throw error if initialized with nil" do
          expect { @document.new(nil) }.to_not raise_error
        end
      end

      context "initialized when _type key present" do
        before do
          @klass = EDoc('FooBar') { key :_type, String }
        end

        it "should set _type to class name" do
          @klass.new._type.should == 'FooBar'
        end

        it "should ignore _type attribute and always use class" do
          @klass.new(:_type => 'Foo')._type.should == 'FooBar'
        end
      end

      context "attributes=" do
        it "should update values for keys provided" do
          doc = @document.new(:name => 'foobar', :age => 10)
          doc.attributes = {:name => 'new value', :age => 5}
          doc.attributes[:name].should == 'new value'
          doc.attributes[:age].should == 5
        end

        it "should not update values for keys that were not provided" do
          doc = @document.new(:name => 'foobar', :age => 10)
          doc.attributes = {:name => 'new value'}
          doc.attributes[:name].should == 'new value'
          doc.attributes[:age].should == 10
        end

        it "should work with pre-defined methods" do
          @document.class_eval do
            attr_writer :password

            def passwd
              @password
            end
          end

          doc = @document.new(:name => 'foobar', :password => 'secret')
          doc.passwd.should == 'secret'
        end

        it "should type cast key values" do
          doc = @document.new(:name => 1234, :age => '21')
          doc.name.should == '1234'
          doc.age.should == 21
        end
      end

      context "attributes" do
        it "should default to hash with all keys" do
          doc = @document.new
          doc.keys.keys.sort.should == ['_id', 'age', 'name']
          doc.attributes.keys.sort.should == ['_id']
        end

        it "should return all keys with values" do
          doc = @document.new(:name => 'string', :age => nil)
          doc.attributes.keys.sort.should == ['_id', 'name']
          doc.keys.keys.sort.should == ['_id', 'age', 'name']
          doc.attributes.values.should include('string')
          doc.attributes.values.should_not include(nil)
        end

        it "should have indifferent access" do
          doc = @document.new(:name => 'string')
          doc.attributes[:name].should == 'string'
          doc.attributes['name'].should == 'string'
        end
      end

      context "to_marklogic" do
        it "should default to hash with _id key" do
          doc = @document.new
          doc.to_marklogic.keys.sort.should == ['_id']
          doc.keys.keys.sort.should == ['_id', 'age', 'name']
        end

        it "should return all keys" do
          doc = @document.new(:name => 'string', :age => nil)
          doc.keys.keys.sort.should == ['_id', 'age', 'name']
          doc.to_marklogic.keys.sort.should == ['_id','name']
          doc.to_marklogic.values.should include('string')
          doc.to_marklogic.values.should_not include(nil)
        end
      end

      context "key shorcut access" do
        context "[]" do
          it "should work when key found" do
            doc = @document.new(:name => 'string')
            doc[:name].should == 'string'
          end

          it "should return nil when not found" do
            doc = @document.new(:name => 'string')
            doc[:not_here].should be_nil
          end
        end

        context "[]=" do
          it "should write key value for existing key" do
            doc = @document.new
            doc[:name] = 'string'
            doc[:name].should == 'string'
          end

          it "should create key and write value for missing key" do
            doc = @document.new
            doc[:foo] = 'string'
            doc.class.keys.include?('foo').should be_truthy
            doc[:foo].should == 'string'
          end

           it "should share the new key with the class" do
             doc = @document.new
             doc[:foo] = 'string'
             @document.keys.should include('foo')
           end
        end
      end

      context "reading a key" do
        it "should work for defined keys" do
          doc = @document.new(:name => 'string')
          doc.name.should == 'string'
        end

        it "should raise no method error for undefined keys" do
          doc = @document.new
          lambda { doc.fart }.should raise_error(NoMethodError)
        end

        it "should be accessible for use in the model" do
          @document.class_eval do
            def name_and_age
              "#{self[:name]} (#{self[:age]})"
            end
          end

          doc = @document.new(:name => 'John', :age => 27)
          doc.name_and_age.should == 'John (27)'
        end

        it "should set instance variable" do
          @document.key :foo, Array
          doc = @document.new
          doc.instance_variable_get("@foo").should be_nil
          doc.foo
          doc.instance_variable_get("@foo").should == []
        end

        it "should be overrideable by modules" do
          @document = Doc do
            key :other_child, String
          end

          child = @document.new
          child.other_child.should be_nil

          @document.send :include, KeyOverride

          overriden_child = @document.new
          overriden_child.other_child.should == 'special result'
        end
      end

      context "reading a key before typcasting" do
        it "should work for defined keys" do
          doc = @document.new(:name => 12)
          doc.name_before_type_cast.should == 12
        end

        it "should raise no method error for undefined keys" do
          doc = @document.new
          lambda { doc.foo_before_type_cast }.should raise_error(NoMethodError)
        end

        it "should be accessible for use in a document" do
          doc = @document.new(:name => 12)
          doc.name.should == '12'
          doc.name_before_type_cast.should == 12
        end
      end

      context "writing a key" do
        it "should work for defined keys" do
          doc = @document.new
          doc.name = 'John'
          doc.name.should == 'John'
        end

        it "should raise no method error for undefined keys" do
          doc = @document.new
          lambda { doc.fart = 'poof!' }.should raise_error(NoMethodError)
        end

        it "should type cast value" do
          doc = @document.new
          doc.name = 1234
          doc.name.should == '1234'
          doc.age = '21'
          doc.age.should == 21
        end

        it "should be accessible for use in the model" do
          @document.class_eval do
            def name_and_age=(new_value)
              new_value.match(/([^\(\s]+) \((.*)\)/)
              write_key :name, $1
              write_key :age, $2
            end
          end

          doc = @document.new
          doc.name_and_age = 'Frank (62)'
          doc.name.should == 'Frank'
          doc.age.should == 62
        end

        it "should be overrideable by modules" do
          @document = Doc do
            key :other_child, String
          end

          child = @document.new(:other_child => 'foo')
          child.other_child.should == 'foo'

          @document.send :include, KeyOverride

          overriden_child = @document.new(:other_child => 'foo')
          overriden_child.other_child.should == 'foo modified'
        end
      end # writing a key

      context "checking if a keys value is present" do
        it "should work for defined keys" do
          doc = @document.new
          doc.name?.should be_falsey
          doc.name = 'John'
          doc.name?.should be_truthy
        end

        it "should raise no method error for undefined keys" do
          doc = @document.new
          lambda { doc.fart? }.should raise_error(NoMethodError)
        end
      end

      context "equality" do
        before do
          @oid = MarkLogic::ObjectId.new
        end

        it "should delegate hash to _id" do
          doc = @document.new
          doc.hash.should == doc._id.hash
        end

        it "should delegate eql to ==" do
          doc = @document.new
          other = @document.new
          doc.eql?(other).should == (doc == other)
          doc.eql?(doc).should == (doc == doc)
        end

        it "should know if same object as another" do
          doc = @document.new
          doc.should equal(doc)
          doc.should_not equal(@document.new)
        end

        it "should allow set operations on array of documents" do
          doc = @document.new
          ([doc] & [doc]).should == [doc]
        end

        it "should be equal if id and class are the same" do
          (@document.new('_id' => @oid) == @document.new('_id' => @oid)).should be_truthy
        end

        it "should not be equal if class same but id different" do
          (@document.new('_id' => @oid) == @document.new('_id' => MarkLogic::ObjectId.new)).should be_falsey
        end

        it "should not be equal if id same but class different" do
          another_document = Doc()
          (@document.new('_id' => @oid) == another_document.new('_id' => @oid)).should be_falsey
        end
      end

      context "reading keys with default values" do
        before do
          @document = EDoc do
            key :name,      String,   :default => 'foo'
            key :age,       Integer,  :default => 20
            key :net_worth, Float,    :default => 100.00
            key :active,    Boolean,  :default => true
            key :smart,     Boolean,  :default => false
            key :skills,    Array,    :default => [1]
            key :options,   Hash,     :default => {'foo' => 'bar'}
          end

          @doc = @document.new
        end

        it "should work for strings" do
          @doc.name.should == 'foo'
        end

        it "should work for integers" do
          @doc.age.should == 20
        end

        it "should work for floats" do
          @doc.net_worth.should == 100.00
        end

        it "should work for booleans" do
          @doc.active.should == true
          @doc.smart.should == false
        end

        it "should work for arrays" do
          @doc.skills.should == [1]
          @doc.skills << 2
          @doc.skills.should == [1, 2]
        end

        it "should work for hashes" do
          @doc.options['foo'].should == 'bar'
          @doc.options['baz'] = 'wick'
          @doc.options['baz'].should == 'wick'
        end
      end

      context "#save!" do
         before do
           @root = DocWithAValidation.create(:name => "Root")
           @doc = @root.e_doc_with_a_validations.build :name => "Embedded"
         end

         it "should should save when valid" do
           @doc.save!
           @root.reload.e_doc_with_a_validations.first.should == @doc
         end

         it "should should raise errors when invalid" do
           @doc.name = ''
           expect { @doc.save! }.to raise_error(MarkMapper::DocumentNotValid)
         end

         it "should should raise errors when root document is invalid" do
           @root.name = ''
           @root.save(:validate => false)
           expect{ @doc.save! }.to raise_error(MarkMapper::DocumentNotValid)
         end
       end
    end # instance of a embedded document
  end
end

