# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# +grant_on+ accepts:

# * Nothing (always grants)

# * A block which evaluates to boolean (receives the object as parameter)

# * A block with a hash composed of methods to run on the target object with

#   expected values (+votes: 5+ for instance).

# +grant_on+ can have a +:to+ method name, which called over the target object

# should retrieve the object to badge (could be +:user+, +:self+, +:follower+,

# etc). If it's not defined merit will apply the badge to the user who

# triggered the action (:action_user by default). If it's :itself, it badges

# the created object (new user for instance).

# The :temporary option indicates that if the condition doesn't hold but the

# badge is granted, then it's removed. It's false by default (badges are kept

# forever).

module Merit
  class BadgeRules
    include Merit::BadgeRulesMethods

    def initialize
      # If it creates user, grant badge

      # Should be "current_user" after registration for badge to be granted.

      # Find badge by badge_id, badge_id takes presidence over badge

      # Registration

      grant_on 'users/confirmations#show', badge_id: 1,

                                           model_name: 'User',

                                           to: :itself do |user|
        user.email.present?
      end

      # Pioneer

      grant_on 'users/confirmations#show', badge_id: 45,

                                           level: 3,

                                           model_name: 'User',

                                           to: :itself do |user|
        User.order(confirmed_at: :asc).first(1000).include?(user)
      end

      # Contributor

      grant_on 'posts#create',
               badge_id: 2,

               level: 1,

               to: :user do |post|
        post.user && post.user.posts.count == 10
      end

      grant_on 'posts#create',
               badge_id: 3,

               level: 2,

               to: :user do |post|
        post.user && post.user.posts.count == 25
      end

      grant_on 'posts#create',
               badge_id: 4,

               level: 3,

               to: :user do |post|
        post.user && post.user.posts.count == 100
      end

      # Voter

      grant_on ['posts#like', 'posts#dislike'],
               badge_id: 5,

               level: 1,

               to: :action_user do |user|
        user.likes_sum + user.dislikes_sum == 10
      end

      grant_on ['posts#like', 'posts#dislike'],
               badge_id: 6,

               level: 3,

               to: :action_user do |user|
        user.likes_sum + user.dislikes_sum == 100
      end

      grant_on ['posts#like', 'posts#dislike'],
               badge_id: 7,

               level: 4,

               to: :action_user do |user|
        user.likes_sum + user.dislikes_sum == 500
      end

      # Representant

      grant_on 'posts#like',
               badge_id: 8,

               level: 1,

               to: :user do |post|
        post.user.posts.sum(&:likes_sum) == 10
      end

      grant_on 'posts#like',
               badge_id: 9,

               level: 2,

               to: :user do |post|
        post.user.posts.sum(&:likes_sum) == 25
      end

      grant_on 'posts#like',
               badge_id: 10,

               level: 3,

               to: :user do |post|
        post.user.posts.sum(&:likes_sum) == 100
      end

      # Critic

      grant_on 'posts#dislike',
               badge_id: 11,

               level: 1,

               to: :action_user do |user|
        user.dislikes_sum == 1
      end

      # Comments

      grant_on 'comments#create',
               badge_id: 12,

               level: 1,

               to: :user do |comment|
        comment.user && comment.user.comments.count == 10
      end

      grant_on 'comments#create',
               badge_id: 13,

               level: 2,

               to: :user do |comment|
        comment.user && comment.user.comments.count == 100
      end

      grant_on 'comments#create',
               badge_id: 14,

               level: 3,

               to: :user do |comment|
        comment.user && comment.user.comments.count == 500
      end

      # Downloads

      grant_on 'users#dashboard',
               badge_id: 15,

               level: 1,

               to: :action_user do |user|
        user.download_count >= 10
      end

      grant_on 'users#dashboard',
               badge_id: 16,

               level: 2,

               to: :action_user do |user|
        user.download_count >= 100
      end

      grant_on 'users#dashboard',
               badge_id: 17,

               level: 3,

               to: :action_user do |user|
        user.download_count >= 500
      end

      # Reputation

      grant_on 'posts#create',
               badge_id: 18,

               level: 1,

               to: :user do |post|
        post.user && post.user.points >= 100
      end

      grant_on 'posts#create',
               badge_id: 19,

               level: 2,

               to: :user do |post|
        post.user && post.user.points >= 2500
      end

      grant_on 'posts#create',
               badge_id: 20,

               level: 3,

               to: :user do |post|
        post.user && post.user.points >= 10_000
      end

      # Comments per post

      grant_on 'posts#show',
               badge_id: 30,

               level: 1,

               to: :user do |post|
        post.comments.count == 10
      end

      grant_on 'posts#show',
               badge_id: 31,

               level: 2,

               to: :user do |post|
        post.comments.count == 25
      end

      grant_on 'posts#show',
               badge_id: 32,

               level: 3,

               to: :user do |post|
        post.comments.count == 100
      end

      # Votes per post

      grant_on 'posts#like',
               badge_id: 33,

               level: 1,

               to: :user do |post|
        post.likes_sum == 10
      end

      grant_on 'posts#like',
               badge_id: 34,

               level: 2,

               to: :user do |post|
        post.likes_sum == 25
      end

      grant_on 'posts#like',
               badge_id: 35,

               level: 3,

               to: :user do |post|
        post.likes_sum == 100
      end

      # Views per post

      grant_on 'posts#show',
               badge_id: 36,

               level: 1,

               to: :user do |post|
        post.impressionist_count(filter: :ip_address) == 1000
      end

      grant_on 'posts#show',
               badge_id: 37,

               level: 2,

               to: :user do |post|
        post.impressionist_count(filter: :ip_address) == 2500
      end

      grant_on 'posts#show',
               badge_id: 38,

               level: 3,

               to: :user do |post|
        post.impressionist_count(filter: :ip_address) == 10_000
      end

      # Votes per comment

      grant_on 'comments#like',
               badge_id: 39,

               level: 1,

               to: :user do |comment|
        comment.likes_sum == 1
      end

      grant_on 'comments#like',
               badge_id: 40,

               level: 2,

               to: :user do |comment|
        comment.likes_sum == 2
      end

      grant_on 'comments#like',
               badge_id: 41,

               level: 3,

               to: :user do |comment|
        comment.likes_sum == 3
      end

      # Member

      grant_on 'users/sessions#create',
               badge_id: 46,

               level: 1,

               model_name: 'User',

               to: :itself do |user|
        (Date.today - user.created_at.to_date).to_i >= 365
      end

      grant_on 'users/sessions#create',
               badge_id: 47,

               level: 2,

               model_name: 'User',

               to: :itself do |user|
        (Date.today - user.created_at.to_date).to_i >= (365 * 3)
      end

      grant_on 'users/sessions#create',
               badge_id: 48,

               level: 3,

               model_name: 'User',

               to: :itself do |user|
        (Date.today - user.created_at.to_date).to_i >= (365 * 10)
      end

      # Invitations

      grant_on 'users/invitations#create',
               badge_id: 51,

               level: 1,

               model_name: 'User',

               to: :itself do |user|
        user.invitations_count == 10
      end

      grant_on 'users/invitations#create',
               badge_id: 52,

               level: 2,

               model_name: 'User',

               to: :itself do |user|
        user.invitations_count == 25
      end

      grant_on 'users/invitations#create',
               badge_id: 53,

               level: 3,

               model_name: 'User',

               to: :itself do |user|
        user.invitations_count == 100
      end

      # Autobiographer

      grant_on 'users#dashboard',
               badge_id: 49,

               level: 1,

               temporary: true,

               model_name: 'User',

               to: :itself do |user|
        user.description.present?
      end

      # Badges

      grant_on 'users#dashboard',
               badge_id: 42,

               level: 1,

               to: :action_user do |user|
        user.badges.select do |badge|
          badge.custom_fields[:difficulty].match?('bronze')
        end.count >= Merit::Badge.all.select do |badge|
                       badge.custom_fields[:difficulty].match?('bronze')
                     end.count * 80 / 100
      end

      grant_on 'users#dashboard',
               badge_id: 43,

               level: 2,

               to: :action_user do |user|
        user.badges.select do |badge|
          badge.custom_fields[:difficulty].match?('silver')
        end.count >= Merit::Badge.all.select do |badge|
                       badge.custom_fields[:difficulty].match?('silver')
                     end.count * 80 / 100
      end

      grant_on 'users#dashboard',
               badge_id: 44,

               level: 3,

               to: :action_user do |user|
        user.badges.select do |badge|
          badge.custom_fields[:difficulty].match?('gold')
        end.count >= Merit::Badge.all.select do |badge|
                       badge.custom_fields[:difficulty].match?('gold')
                     end.count * 80 / 100
      end

      # # Ranking

      # # Weekly

      # grant_on 'posts#create',
      #          badge_id: 21,

      #          level: 1,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 1.week.ago, limit: 500).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end

      # grant_on 'posts#create',
      #          badge_id: 22,

      #          level: 2,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 1.week.ago, limit: 100).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end

      # grant_on 'posts#create',
      #          badge_id: 23,

      #          level: 3,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 1.week.ago, limit: 10).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end

      # # Monthly

      # grant_on 'posts#create',
      #          badge_id: 24,

      #          level: 1,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 1.month.ago, limit: 500).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end

      # grant_on 'posts#create',
      #          badge_id: 25,

      #          level: 2,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 1.month.ago, limit: 100).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end

      # grant_on 'posts#create',
      #          badge_id: 26,

      #          level: 3,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 1.month.ago, limit: 10).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end

      # # Yearly

      # grant_on 'posts#create',
      #          badge_id: 27,

      #          level: 1,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 5.years.ago, limit: 500).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end

      # grant_on 'posts#create',
      #          badge_id: 28,

      #          level: 2,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 5.years.ago, limit: 100).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end

      # grant_on 'posts#create',
      #          badge_id: 29,

      #          level: 3,

      #          to: :user do |post|
      #   Merit::Score.top_scored(since_date: 5.years.ago, limit: 10).to_a.any? do |user|
      #     user['user_id'] == post.user.id
      #   end
      # end
    end
  end
end
