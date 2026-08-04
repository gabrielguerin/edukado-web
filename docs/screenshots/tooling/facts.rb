# frozen_string_literal: true

# Emits a JSON description of the seeded database so the Playwright capture
# script never has to guess a URL. Run with `rails runner`.
require 'json'

ActiveRecord::Base.logger = nil

# Only read attributes the model actually has: not every model uses friendly_id,
# and `slice` on a missing attribute raises.
def pick(record, *attrs)
  return nil if record.nil?

  attrs.each_with_object({}) do |a, h|
    h[a] = record.public_send(a) if record.respond_to?(a)
  end
end

# A post is "safe" for the reciprocity-gate screenshot only if it has no
# comments: the gated branches of app/views/active_storage/_file.html.erb do not
# guard with `file.attached?`, so a comment without an attachment crashes
# _file-card.html.erb at `object.file.filename`.
safe = Post.left_joins(:comments)
           .where(comments: { id: nil })
           .select { |p| p.file.attached? }

# A student with zero uploads is required to trigger the gate at all
# (the gate condition is `download_count >= 3 && posts.count < 1`).
freeloader = User.left_joins(:posts).where(posts: { id: nil }).order(:id).first

# Rich posts (many comments + votes) make the best document-detail screenshot.
rich = Post.left_joins(:comments)
           .group('posts.id')
           .order(Arel.sql('COUNT(comments.id) DESC'))
           .limit(6)
           .select { |p| p.file.attached? }

out = {
  base: 'http://localhost:3000',
  counts: {
    users: User.count, posts: Post.count, comments: Comment.count,
    blogs: Blog.count, courses: Course.count, subjects: Subject.count,
    groups: Group.count, categories: Category.count, tags: Tag.count,
    levels: Level.count, years: Year.count,
    badges: Merit::Badge.all.to_a.size
  },
  safe_post_slugs: safe.first(6).map(&:slug),
  rich_post_slugs: rich.map(&:slug),
  freeloader: freeloader && { email: freeloader.email, id: freeloader.id,
                              name: "#{freeloader.first_name} #{freeloader.last_name}" },
  # Pick entities that actually have associated documents, so detail pages are
  # populated rather than empty.
  course: pick(Course.joins(:posts).group('courses.id')
                .order(Arel.sql('COUNT(posts.id) DESC')).first, :id, :slug, :name),
  subject: pick(Subject.first, :id, :slug, :name),
  category: pick(Category.joins(:posts).group('categories.id')
                    .order(Arel.sql('COUNT(posts.id) DESC')).first, :id, :slug, :name),
  group: pick(Group.joins(:posts).group('groups.id')
              .order(Arel.sql('COUNT(posts.id) DESC')).first, :id, :slug, :name),
  tag: pick(Tag.joins(:posts).group('tags.id')
          .order(Arel.sql('COUNT(posts.id) DESC')).first, :id, :slug, :title),
  level: pick(Level.joins(:posts).group('levels.id')
              .order(Arel.sql('COUNT(posts.id) DESC')).first, :id, :slug, :level),
  blog: pick(Blog.order(:id).first, :id, :slug, :title),
  # The dashboard is the signed-in account's own page, so it must be that account.
  student_ref: pick(User.find_by(email: 'user@edukado.co'), :id, :slug, :first_name, :last_name),
  # For the public profile, prefer a generated French student over the "John Doe"
  # test accounts: same populated page, more representative name.
  profile_user: pick(User.joins(:posts).where.not(first_name: 'John')
                .group('users.id')
                .order(Arel.sql('COUNT(posts.id) DESC')).first, :id, :slug, :first_name, :last_name),
  badge_ids: Merit::Badge.all.to_a.first(3).map(&:id),
  accounts: {
    superadmin: 'superadmin@edukado.co',
    supervisor: 'supervisor@edukado.co',
    student: 'user@edukado.co'
  },
  admin_resources: %w[
    users posts comments groups courses subjects categories tags blogs years levels
  ]
}

puts JSON.pretty_generate(out)
