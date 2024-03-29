# frozen_string_literal: true

class Tag < ApplicationRecord
  # Search

  searchkick

  # FriendlyId

  extend FriendlyId

  friendly_id :title, use: :slugged

  # Associations

  has_many :posts_tags, dependent: :destroy

  has_many :posts, through: :posts_tags

  has_many :blogs_tags, dependent: :destroy

  has_many :blogs, through: :blogs_tags

  has_many :tags_users, dependent: :destroy

  has_many :users, through: :tags_users

  # Validations

  validates :title, presence: true, length: {

    minimum: 2,

    too_short: '%<count> caractères est le minimum autorisé'

  }

  # Search data

  def search_data
    {

      title: title

    }
  end

  # Downcase every tag
  before_save :downcase_fields

  def downcase_fields
    self.title.downcase!
  end
end
