describe "The Examples" do

  before do
    @previous = MarkMapper::Plugins::IdentityMap.enabled
  end

  after do
    MarkMapper::Plugins::IdentityMap.enabled = @previous
  end

  file = File.dirname(__FILE__) + "/../examples/**/*.rb"
  puts file
  Dir[file].each do |f|
    it "should run #{f}" do

      expect {

        Object.send(:remove_const, :User) if Object.constants.include?(:User)

        require f
      }.to_not raise_error

    end
  end
end
