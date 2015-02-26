require 'spec_helper'

describe "Support", :working => true do
  context "Array.to_marklogic" do
    it "should convert value to_a" do
      Array.to_marklogic([1, 2, 3, 4]).should == [1, 2, 3, 4]
      Array.to_marklogic('1').should == ['1']
      Array.to_marklogic({'1' => '2', '3' => '4'}).should include(['1', '2'], ['3', '4'])
    end
  end

  context "Array.from_marklogic" do
    it "should be array if array" do
      Array.from_marklogic([1, 2]).should == [1, 2]
    end

    it "should be empty array if nil" do
      Array.from_marklogic(nil).should == []
    end
  end

  context "Boolean.to_marklogic" do
    it "should be true for true" do
      Boolean.to_marklogic(true).should be_truthy
    end

    it "should be false for false" do
      Boolean.to_marklogic(false).should be_falsey
    end

    it "should handle odd assortment of other values" do
      Boolean.to_marklogic('true').should be_truthy
      Boolean.to_marklogic('t').should be_truthy
      Boolean.to_marklogic('1').should be_truthy
      Boolean.to_marklogic(1).should be_truthy

      Boolean.to_marklogic('false').should be_falsey
      Boolean.to_marklogic('f').should be_falsey
      Boolean.to_marklogic('0').should be_falsey
      Boolean.to_marklogic(0).should be_falsey
    end

    it "should be nil for nil" do
      Boolean.to_marklogic(nil).should be_nil
    end
  end

  context "Boolean.from_marklogic" do
    it "should be true for true" do
      Boolean.from_marklogic(true).should be_truthy
    end

    it "should be false for false" do
      Boolean.from_marklogic(false).should be_falsey
    end

    it "should be nil for nil" do
      Boolean.from_marklogic(nil).should be_nil
    end
  end

  context "Date.to_marklogic" do
    it "should be time if string" do
      date = Date.to_marklogic('2009-10-01')
      date.should == Time.utc(2009, 10, 1)
      date.should == date
      date.month.should == 10
      date.day.should == 1
      date.year.should == 2009
    end

    it "should be time if date" do
      Date.to_marklogic(Date.new(2009, 10, 1)).should == Time.utc(2009, 10, 1)
    end

    it "should be date if time" do
      Date.to_marklogic(Time.parse("2009-10-1T12:30:00")).should == Time.utc(2009, 10, 1)
    end

    it "should be nil if bogus string" do
      Date.to_marklogic('jdsafop874').should be_nil
    end

    it "should be nil if empty string" do
      Date.to_marklogic('').should be_nil
    end
  end

  context "Date.from_marklogic" do
    it "should be date if date" do
      date = Date.new(2009, 10, 1)
      from_date = Date.from_marklogic(date)
      from_date.should == date
      from_date.month.should == 10
      from_date.day.should == 1
      from_date.year.should == 2009
    end

    it "should be date if time" do
      time = Time.now
      Date.from_marklogic(time).should == time.to_date
    end

    it "should be nil if nil" do
      Date.from_marklogic(nil).should be_nil
    end
  end

  context "Float.to_marklogic" do
    it "should convert value to_f" do
      [21, 21.0, '21'].each do |value|
        Float.to_marklogic(value).should == 21.0
      end
    end

    it "should leave nil values nil" do
      Float.to_marklogic(nil).should == nil
    end

    it "should leave blank values nil" do
      Float.to_marklogic('').should == nil
    end
  end

  context "Hash.from_marklogic" do
    it "should convert hash to hash with indifferent access" do
      hash = Hash.from_marklogic(:foo => 'bar')
      hash[:foo].should  == 'bar'
      hash['foo'].should == 'bar'
    end

    it "should be hash if nil" do
      hash = Hash.from_marklogic(nil)
      hash.should == {}
      hash.is_a?(HashWithIndifferentAccess).should be_truthy
    end
  end

  context "Hash.to_marklogic instance method" do
    it "should have instance method that returns self" do
      hash = HashWithIndifferentAccess.new('foo' => 'bar')
      hash.to_marklogic.should == {'foo' => 'bar'}
    end
  end

  context "Integer.to_marklogic" do
    it "should convert value to integer" do
      [21, 21.0, '21'].each do |value|
        Integer.to_marklogic(value).should == 21
      end
    end

    it "should convert value from marklogic to integer" do
      [21, 21.0, '21'].each do |value|
        Integer.from_marklogic(value).should == 21
      end
    end

    it "should convert nil to nil" do
      Integer.to_marklogic(nil).should be_nil
    end

    it "should convert nil to nil" do
      Integer.from_marklogic(nil).should be_nil
    end

    it "should work fine with big integers" do
      [9223372036854775807, '9223372036854775807'].each do |value|
        Integer.to_marklogic(value).should == 9223372036854775807
      end
    end
  end

  context "NilClass#from_marklogic" do
    it "should return nil" do
      nil.from_marklogic(nil).should be_nil
    end
  end

  context "NilClass#to_marklogic" do
    it "should return nil" do
      nil.to_marklogic(nil).should be_nil
    end
  end

  context "ObjectId#to_marklogic" do
    it "should call class to_marklogic with self" do
      object = Object.new
      expect(object.class).to receive(:to_marklogic).with(object)
      object.to_marklogic
    end
  end

  context "ObjectId.to_marklogic" do
    it "should return nil for nil" do
      ObjectId.to_marklogic(nil).should be_nil
    end

    it "should return nil if blank string" do
      ObjectId.to_marklogic('').should be_nil
    end

    it "should return value if object id" do
      id = MarkLogic::ObjectId.new
      ObjectId.to_marklogic(id).should be(id)
    end

    it "should return value" do
      Object.to_marklogic(21).should == 21
      Object.to_marklogic('21').should == '21'
      Object.to_marklogic(9223372036854775807).should == 9223372036854775807
    end
  end

  context "ObjectId.from_marklogic" do
    it "should return value" do
      Object.from_marklogic(21).should == 21
      Object.from_marklogic('21').should == '21'
      Object.from_marklogic(9223372036854775807).should == 9223372036854775807

      id = MarkLogic::ObjectId.new
      ObjectId.from_marklogic(id).should == id
    end
  end

  context "Set.to_marklogic" do
    it "should convert value to_a" do
      Set.to_marklogic(Set.new([1,2,3])).should == [1,2,3]
    end

    it "should convert to empty array if nil" do
      Set.to_marklogic(nil).should == []
    end
  end

  context "Set.from_marklogic" do
    it "should be a set if array" do
      Set.from_marklogic([1,2,3]).should == Set.new([1,2,3])
    end

    it "should be empty set if nil" do
      Set.from_marklogic(nil).should == Set.new([])
    end
  end

  context "String.to_marklogic" do
    it "should convert value to_s" do
      [21, '21'].each do |value|
        String.to_marklogic(value).should == '21'
      end
    end

    it "should be nil if nil" do
      String.to_marklogic(nil).should be_nil
    end
  end

  context "String.from_marklogic" do
    it "should be string if value present" do
      String.from_marklogic('Scotch! Scotch! Scotch!').should == 'Scotch! Scotch! Scotch!'
    end

    it "should return nil if nil" do
      String.from_marklogic(nil).should be_nil
    end

    it "should return empty string if blank" do
      String.from_marklogic('').should == ''
    end
  end

  context "Time.to_marklogic without Time.zone" do
    before do
      Time.zone = nil
    end

    it "should be nil if blank string" do
      Time.to_marklogic('').should be_nil
    end

    it "should not be nil if nil" do
      Time.to_marklogic(nil).should be_nil
    end
  end

  context "Time.to_marklogic with Time.zone" do
    it "should be nil if blank string" do
      Time.zone = 'Hawaii'
      Time.to_marklogic('').should be_nil
      Time.zone = nil
    end

    it "should be nil if nil" do
      Time.zone = 'Hawaii'
      Time.to_marklogic(nil).should be_nil
      Time.zone = nil
    end
  end

  context "Time.from_marklogic without Time.zone" do
    it "should be time" do
      time = Time.now
      Time.from_marklogic(time).should == time
    end

    it "should be nil if nil" do
      Time.from_marklogic(nil).should be_nil
    end
  end

  context "Time.from_marklogic with Time.zone" do
    it "should be time in Time.zone" do
      Time.zone = 'Hawaii'

      time = Time.from_marklogic(Time.utc(2009, 10, 1))
      time.should == Time.zone.local(2009, 9, 30, 14)
      # time.is_a?(ActiveSupport::TimeWithZone).should be_truthy

      Time.zone = nil
    end

    it "should be nil if nil" do
      Time.zone = 'Hawaii'
      Time.from_marklogic(nil).should be_nil
      Time.zone = nil
    end
  end

  context "ObjectId" do
    context "#as_json" do
      it "should convert object id to string" do
        id = MarkLogic::ObjectId.new
        id.as_json.should == id.to_s
      end
    end

    context "#to_json" do
      it "should convert object id to string" do
        id = MarkLogic::ObjectId.new
        id.to_json.should == %Q("#{id}")
      end
    end
  end

  context "Symbol.to_marklogic" do
    it "should convert value to_sym" do
      Symbol.to_marklogic('asdfasdfasdf').should == :asdfasdfasdf
    end

    it "should convert string if not string" do
      Symbol.to_marklogic(123).should == :'123'
    end

    it "should return nil for nil" do
      Symbol.to_marklogic(nil).should be_nil
    end
  end

  context "Symbol.from_marklogic" do
    it "should convert value to_sym" do
      Symbol.from_marklogic(:asdfasdfasdf).should == :asdfasdfasdf
    end

    it "should return nil for nil" do
      Symbol.from_marklogic(nil).should be_nil
    end
  end
end
