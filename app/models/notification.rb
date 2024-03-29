# frozen_string_literal: true

class Notification < ApplicationRecord
  # Associations

  belongs_to :notified_by, class_name: 'User'
  belongs_to :user
  belongs_to :post

  # Validations

  validates :user_id, :notified_by_id, :post_id, :identifier, :notice_type, presence: true
end
