require 'spec_helper'

class Address; end

describe "MarkMapper" do
  it "should be able to write and read connection" do
    conn = MarkLogic::Connection.new(HOST, PORT)
    MarkMapper.connection = conn
    MarkMapper.connection.should == conn
  end

  it "should default connection to new marklogic ruby driver" do
    MarkMapper.connection = nil
    MarkMapper.connection.should be_instance_of(MarkLogic::Connection)
  end

  it "should be able to write and read default database" do
    MarkMapper.database = 'test'
    MarkMapper.database.should be_instance_of(MarkLogic::Database)
    MarkMapper.database.database_name.should == 'test'
  end

  it "should have document not found error" do
    lambda {
      MarkMapper::DocumentNotFound
    }.should_not raise_error
  end

  it "should be able to read/write config" do
    config = {
      'development' => {'host' => '127.0.0.1', 'port' => 8006, 'database' => 'test'},
      'production'  => {'host' => '127.0.0.1', 'port' => 8006, 'database' => 'test-prod'}
    }
    MarkMapper.config = config
    MarkMapper.config.should == config
  end
end
