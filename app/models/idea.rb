class Idea < ActiveRecord::Base
  acts_as_taggable

  belongs_to :user
  default_scope { order(created_at: :desc) }
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true

  before_save :add_hashtags_to_tag


  def add_hashtags_to_tags
    self.tag_list=Twitter::Extractor::extract_hashtags(self.content).join(",")
  end

  # Returns ideas from the users being followed by the given user.
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end
  
  include PgSearch
  pg_search_scope :search, against: [:content],
    using: {tsearch: {dictionary: "english", any_word: true}}
  
  def self.text_search(query)
    if query.present?
      unscoped.search(query)
    else
      all
    end
  end
end