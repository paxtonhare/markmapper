require 'spec_helper'

describe "Logger" do
  context "with connection that has logger" do
    before do
      @output = StringIO.new
      @logger = Logger.new(@output)
      MarkLogic.logger = @logger
    end

    it "should be able to get access to that logger" do
      MarkMapper.logger.should == @logger
    end

    it "should be able to log messages" do
      MarkMapper.logger.debug 'testing'
      @output.string.include?('testing').should be_truthy
    end
  end
end
