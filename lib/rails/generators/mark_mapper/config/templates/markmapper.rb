MarkMapper.application.tap do |app|

  # one way to create a range index. Use this if you want to use MarkMapper's defaults
  # for your database
  # app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:age, :type => 'int'))

  # If you prefer to have finer control over what settings go into a database
  # you can configure your database(s) like so:
  # app.database('my-content-db') do

    # add range element indexes
    # add_range_element_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:age, :type => 'int'))
  # end
end
