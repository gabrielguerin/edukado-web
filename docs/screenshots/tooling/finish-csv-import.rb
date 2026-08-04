# frozen_string_literal: true

# db/seeds.rb ends by importing lib/seeds/posts/posts_test.csv, whose rows
# hard-code course names ("La Promise du voyeur") that the same seed file
# generates randomly with Faker::Book.title under the :fr locale. When the random
# draw misses one, `Course.find_by(name: row['course'])` returns nil and the
# import aborts with "Course doit exister".
#
# That matters beyond tidiness: these ten rows belong to the three test accounts,
# and they are the uploads the README documents (3 / 4 / 4). Without them the
# accounts have no contributions at all.
#
# This script finishes the import idempotently: it creates any course the CSV
# references but the seed did not generate, then imports only the rows that are
# still missing. It does not modify db/seeds.rb — it replicates that file's own
# loop. Safe to run after any seed, including a successful one.

require 'csv'

ActiveRecord::Base.logger = nil

raw = File.read(Rails.root.join('lib', 'seeds', 'posts', 'posts_test.csv'))
csv = CSV.parse(raw, headers: true, col_sep: ',', encoding: 'iso-8859-1:utf-8')

# 1. Backfill courses the CSV needs but the Faker draw did not produce.
created_courses = 0
csv.map { |r| r['course'] }.compact.uniq.each do |name|
  next if Course.find_by(name: name)

  Course.create!(name: name, group: Group.all.sample, subject: Subject.all.sample)
  created_courses += 1
end
puts "[fix_csv] courses created to satisfy the CSV: #{created_courses}"

# 2. Import the rows that are not in the database yet.
imported = 0
skipped = 0
csv.each do |row|
  if Post.find_by(title: row['title'])
    skipped += 1
    next
  end

  post = Post.new
  post.user = User.find_by(email: row['email'])
  post.title = row['title']
  post.description = row['description']
  post.tags = row['tag_list'].split(',').map { |t| Tag.where(title: t.strip).first_or_create! }
  post.group = Group.find_by(name: row['group'])
  post.course = Course.find_by(name: row['course'])
  post.levels = row['levels'].split(',').map { |l| Level.find_by(level: l) }
  post.category = Category.find_by(name: row['category'])
  post.year = Year.find_by(start_year: row['start_year'], end_year: row['end_year'])
  post.file.attach(
    io: File.open(row['path']),
    filename: row['filename'],
    content_type: row['content_type'],
    identify: row['identity']
  )
  post.save!
  imported += 1
rescue StandardError => e
  puts "[fix_csv] row '#{row['title']}' failed: #{e.class}: #{e.message}"
end

puts "[fix_csv] imported #{imported}, already present #{skipped}"

# 3. seeds.rb clears merit's sashes as its very last statement; if the import
#    aborted, that never ran. Match the intended end state.
Merit::BadgesSash.delete_all
puts '[fix_csv] badges sashes cleared (as db/seeds.rb does at its end)'

# 4. Report the uploads per test account, which the README documents.
%w[superadmin@edukado.co supervisor@edukado.co user@edukado.co].each do |email|
  u = User.find_by(email: email)
  puts "[fix_csv] #{email}: #{u ? u.posts.count : 'MISSING'} uploads"
end
