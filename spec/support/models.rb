# custom type
class WindowSize
  attr_reader :width, :height

  def self.to_marklogic(value)
    value.to_a
  end

  def self.from_marklogic(value)
    value.is_a?(self) ? value : WindowSize.new(value)
  end

  def initialize(*args)
    @width, @height = args.flatten
  end

  def to_a
    [width, height]
  end

  def ==(other)
    other.is_a?(self.class) && other.width == width && other.height == height
  end
end

module AccountsExtensions
  def inactive
    all(:last_logged_in => nil)
  end
end

class Post
  include MarkMapper::Document

  key :title, String
  key :body, String

  many :comments, :as => :commentable, :class_name => 'PostComment'

  timestamps!

  index :body, :type => String
end

class PostComment
  include MarkMapper::Document

  key :username, String, :default => 'Anonymous'
  key :body, String

  key :commentable_id, ObjectId
  key :commentable_type, String
  belongs_to :commentable, :polymorphic => true

  timestamps!

  index :name, :type => String
end

class Address
  include MarkMapper::EmbeddedDocument

  key :address, String
  key :city,    String
  key :state,   String
  key :zip,     Integer
end

class Message
  include MarkMapper::Document

  key :body, String
  key :position, Integer
  key :room_id, ObjectId

  belongs_to :room
  index :position, :type => Integer
end

class Enter < Message; end
class Exit < Message;  end
class Chat < Message;  end

class Room
  include MarkMapper::Document

  key :name, String
  many :messages, :polymorphic => true, :order => 'position' do
    def older
      all(:position => {'$gt' => 5})
    end
  end
  many :latest_messages, :class_name => 'Message', :order => 'position desc', :limit => 2

  many :accounts, :polymorphic => true, :extend => AccountsExtensions
end

class Account
  include MarkMapper::Document

  key :room_id, ObjectId
  key :last_logged_in, Time

  belongs_to :room
end
class AccountUser < Account; end
class Bot < Account; end

class Answer
  include MarkMapper::Document

  key :body, String
end

module CollaboratorsExtensions
  def top
    first
  end
end

class Project
  include MarkMapper::Document

  key :name, String

  many :collaborators, :extend => CollaboratorsExtensions
  many :statuses, :order => 'position' do
    def open
      all(:name => %w(New Assigned))
    end
  end

  many :addresses
end

class Collaborator
  include MarkMapper::Document
  key :project_id, ObjectId
  key :name, String
  belongs_to :project
end

class Status
  include MarkMapper::Document

  scope :complete, where(:name => 'Complete')

  def self.by_position(position)
    where(:position => position)
  end

  key :project_id, ObjectId
  key :target_id, ObjectId
  key :target_type, String
  key :name, String, :required => true
  key :position, Integer

  belongs_to :project
  belongs_to :target, :polymorphic => true
  index :position, :type => Integer
end

class Media
  include MarkMapper::EmbeddedDocument

  key :file, String
  key :visible, Boolean
end

class Video < Media
  key :length, Integer
end

class Image < Media
  key :width, Integer
  key :height, Integer
end

class Music < Media
  key :bitrate, String
end

class Catalog
  include MarkMapper::Document

  many :medias, :polymorphic => true do
    def visible
      # for some reason we can't use select here
      find_all { |m| m.visible? }
    end
  end
end

module TrModels
  class Transport
    include MarkMapper::EmbeddedDocument

    key :license_plate, String
    key :purchased_on, Date
  end

  class Car < TrModels::Transport
    include MarkMapper::EmbeddedDocument

    key :model, String
    key :year, Integer
  end

  class Bus < TrModels::Transport
    include MarkMapper::EmbeddedDocument

    key :max_passengers, Integer
  end

  class Ambulance < TrModels::Transport
    include MarkMapper::EmbeddedDocument

    key :icu, Boolean
  end

  class Fleet
    include MarkMapper::Document

    module TransportsExtension
      def to_be_replaced
        # for some reason we can't use select
        find_all { |t| t.purchased_on < 2.years.ago.to_date }
      end
    end

    many :transports, :polymorphic => true, :class_name => "TrModels::Transport", :extend => TransportsExtension
    key :name, String
  end
end

module News
  class Paper
    include MarkMapper::Document
  end

  class Article
    include MarkMapper::Document
  end
end

class AltUser
  include MarkMapper::Document
end

class Human
  include MarkMapper::EmbeddedDocument

  key :name, String
  embedded_in :post
end

class Robot
  include MarkMapper::EmbeddedDocument

  key :serial_number, String
  embedded_in :post
end
