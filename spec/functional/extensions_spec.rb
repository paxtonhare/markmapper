require 'spec_helper'

describe "Core Extensions" do
  describe "Time" do
    let(:doc) do
      Doc do
        key :created_at, Time
      end
    end

    it "should match the precision of Time types stored in the database" do
      d = doc.create(:created_at => Time.now)
      d.created_at.to_s.should == d.reload.created_at.to_s
    end
  end
end
