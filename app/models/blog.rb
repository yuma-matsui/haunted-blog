# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    sql_statement = sanitize_sql("%#{term}%")
    where('title LIKE ? OR content LIKE ?', sql_statement, sql_statement)
  }

  scope :owned, lambda { |id|
    where('user_id = ?', id)
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end
end
