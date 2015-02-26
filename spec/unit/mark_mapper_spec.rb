require 'spec_helper'

class Address; end

describe "MarkMapper", :skip=>true do
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
    MarkMapper.database_name = 'test'
    MarkMapper.database.should be_instance_of(MarkLogic::Database)
    MarkMapper.database.database_name.should == 'test'
  end

  it "should have document not found error" do
    lambda {
      MarkMapper::DocumentNotFound
    }.should_not raise_error
  end

  # it "should be able to read/write config" do
  #   config = {
  #     'development' => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test'},
  #     'production'  => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test-prod'}
  #   }
  #   MarkMapper.config = config
  #   MarkMapper.config.should == config
  # end

  # context "connecting to environment from config" do
  #   it "should work without authentication" do
  #     MarkMapper.config = {
  #       'development' => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test'}
  #     }
  #     expect(Mongo::MongoClient).to receive(:new).with('127.0.0.1', 27017, {})
  #     expect(MarkMapper).to receive(:database=).with('test')
  #     expect_any_instance_of(Mongo::DB).to receive(:authenticate).never
  #     MarkMapper.connect('development')
  #   end

    # it "should work without authentication using uri" do
    #   MarkMapper.config = {
    #     'development' => {'uri' => 'mongodb://127.0.0.1:27017/test'}
    #   }
    #   expect(Mongo::MongoClient).to receive(:new).with('127.0.0.1', 27017, {})
    #   expect(MarkMapper).to receive(:database=).with('test')
    #   expect_any_instance_of(Mongo::DB).to receive(:authenticate).never
    #   MarkMapper.connect('development')
    # end

    # it "should work with sinatra environment symbol" do
    #   MarkMapper.config = {
    #     'development' => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test'}
    #   }
    #   expect(Mongo::MongoClient).to receive(:new).with('127.0.0.1', 27017, {})
    #   expect(MarkMapper).to receive(:database=).with('test')
    #   expect_any_instance_of(Mongo::DB).to receive(:authenticate).never
    #   MarkMapper.connect(:development)
    # end

  #   it "should work with options" do
  #     MarkMapper.config = {
  #       'development' => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test'}
  #     }
  #     connection, logger = double('connection'), double('logger')
  #     expect(Mongo::MongoClient).to receive(:new).with('127.0.0.1', 27017, :logger => logger)
  #     MarkMapper.connect('development', :logger => logger)
  #   end

  #   it "should pass along ssl when true" do
  #     MarkMapper.config = {
  #       'development' => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test', 'ssl' => true}
  #     }
  #     connection, logger = double('connection'), double('logger')
  #     expect(Mongo::MongoClient).to receive(:new).with('127.0.0.1', 27017, :logger => logger, :ssl => true)
  #     MarkMapper.connect('development', :logger => logger)
  #   end

  #   it "should pass along ssl when false" do
  #     MarkMapper.config = {
  #       'development' => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test', 'ssl' => false}
  #     }
  #     connection, logger = double('connection'), double('logger')
  #     expect(Mongo::MongoClient).to receive(:new).with('127.0.0.1', 27017, :logger => logger, :ssl => false)
  #     MarkMapper.connect('development', :logger => logger)
  #   end

  #   it "should convert read preferences to symbols" do
  #     MarkMapper.config = {
  #       'development' => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test', 'options' =>  {'read' => 'primary'}}
  #     }
  #     connection, logger = double('connection'), double('logger')
  #     expect(Mongo::MongoClient).to receive(:new).with('127.0.0.1', 27017, :logger => logger, :read => :primary)
  #     MarkMapper.connect('development', :logger => logger)
  #   end

  #   it "should work with options from config" do
  #     MarkMapper.config = {
  #       'development' => {'host' => '192.168.1.1', 'port' => 2222, 'database' => 'test'}
  #     }
  #     connection, logger = double('connection'), double('logger')
  #     expect(Mongo::MongoClient).to receive(:new).with('192.168.1.1', 2222, :logger => logger)
  #     MarkMapper.connect('development', :logger => logger)
  #   end

  #   it "should work with options using uri" do
  #     MarkMapper.config = {
  #       'development' => {'uri' => 'mongodb://127.0.0.1:27017/test'}
  #     }
  #     connection, logger = double('connection'), double('logger')
  #     expect(Mongo::MongoClient).to receive(:new).with('127.0.0.1', 27017, :logger => logger)
  #     MarkMapper.connect('development', :logger => logger)
  #   end

  #   it "should work with authentication" do
  #     MarkMapper.config = {
  #       'development' => {'host' => '127.0.0.1', 'port' => 27017, 'database' => 'test', 'username' => 'john', 'password' => 'secret'}
  #     }
  #     expect_any_instance_of(Mongo::DB).to receive(:authenticate).with('john', 'secret')
  #     MarkMapper.connect('development')
  #   end

  #   it "should work with authentication using uri" do
  #     MarkMapper.config = {
  #       'development' => {'uri' => 'mongodb://john:secret@127.0.0.1:27017/test'}
  #     }
  #     expect_any_instance_of(Mongo::DB).to receive(:authenticate).with('john', 'secret')
  #     MarkMapper.connect('development')
  #   end

  #   it "should raise error for invalid scheme" do
  #     MarkMapper.config = {
  #       'development' => {'uri' => 'mysql://127.0.0.1:5336/foo'}
  #     }
  #     expect { MarkMapper.connect('development') }.to raise_error(MarkMapper::InvalidScheme)
  #   end

  #   it "should create a replica set connection if config contains multiple hosts in the old format" do
  #     MarkMapper.config = {
  #       'development' => {
  #         'hosts' => [ ['127.0.0.1', 27017], ['localhost', 27017] ],
  #         'database' => 'test'
  #       }
  #     }

  #     expect(Mongo::MongoReplicaSetClient).to receive(:new).with( ['127.0.0.1', 27017], ['localhost', 27017], {'read_secondary' => true} )
  #     expect(MarkMapper).to receive(:database=).with('test')
  #     expect_any_instance_of(Mongo::DB).to receive(:authenticate).never
  #     MarkMapper.connect('development', 'read_secondary' => true)
  #   end

  #   it "should create a replica set connection if config contains multiple hosts in the new format" do
  #     MarkMapper.config = {
  #       'development' => {
  #         'hosts' => ['127.0.0.1:27017', 'localhost:27017'],
  #         'database' => 'test'
  #       }
  #     }

  #     expect(Mongo::MongoReplicaSetClient).to receive(:new).with( ['127.0.0.1:27017', 'localhost:27017'], {'read_secondary' => true} )
  #     expect(MarkMapper).to receive(:database=).with('test')
  #     expect_any_instance_of(Mongo::DB).to receive(:authenticate).never
  #     MarkMapper.connect('development', 'read_secondary' => true)
  #   end
  # end

  # context "setup" do
  #   it "should work as shortcut for setting config, environment and options" do
  #     config, logger = double('config'), double('logger')
  #     expect(MarkMapper).to receive(:config=).with(config)
  #     expect(MarkMapper).to receive(:connect).with('development', :logger => logger)
  #     expect(MarkMapper).to receive(:handle_passenger_forking).once
  #     MarkMapper.setup(config, 'development', :logger => logger)
  #   end
  # end
end
