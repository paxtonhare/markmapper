require 'spec_helper'
require 'support/models'

module AssociationsSpec
  describe "Associations", :working => true do
    it "should allow changing class names" do
      class AwesomeUser
        include MarkMapper::Document

        many :posts, :class_name => 'AssociationsSpec::AwesomePost', :foreign_key => :creator_id
      end
      AwesomeUser.collection.remove

      class AwesomeTag
        include MarkMapper::EmbeddedDocument

        key :name, String
        key :post_id, ObjectId

        belongs_to :post, :class_name => 'AssociationsSpec::AwesomeUser'
      end

      class AwesomePost
        include MarkMapper::Document

        key :creator_id, ObjectId

        belongs_to :creator, :class_name => 'AssociationsSpec::AwesomeUser'
        many :tags, :class_name => 'AssociationsSpec::AwesomeTag', :foreign_key => :post_id
      end

      AwesomeUser.collection.remove
      AwesomePost.collection.remove

      user = AwesomeUser.create
      tag1 = AwesomeTag.new(:name => 'awesome')
      tag2 = AwesomeTag.new(:name => 'grand')
      post1 = AwesomePost.create(:creator => user, :tags => [tag1])
      post2 = AwesomePost.create(:creator => user, :tags => [tag2])

      user.reload
      user.posts.should =~ [post1, post2]

      post1 = post1.reload
      post1.tags.should == [tag1]
    end
  end
end
