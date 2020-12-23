# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.

# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# Examples:

#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])

#   Character.create(name: 'Luke', movie: movies.first)

# Use faker to seed

require 'faker'

# Seed from a CSV file

require 'csv'

# Delete everything

LevelsPost.delete_all

Level.delete_all

Notification.delete_all

Post.delete_all

User.delete_all

Tag.delete_all

Comment.delete_all

TagsUser.delete_all

PostsTag.delete_all

Blog.delete_all

Course.delete_all

Subject.delete_all

Category.delete_all

Year.delete_all

Group.delete_all

# Create groups

# French universities

universities_fr = File.read(Rails.root.join('lib', 'seeds', 'universities_fr.csv'))

csv = CSV.parse(universities_fr, headers: true, encoding: 'ISO-8859-1')

csv.take(10).each do |row|
  t = Group.new

  t.name = row['name']

  t.save
end

# Create subjects

30.times do
  Subject.create!(
    name: Faker::Educator.subject
  )
end

# Create years

(2015..2021).each do |year|
  Year.create!(
    start_year: year,

    end_year: year + 1
  )
end

# Create levels

(1..10).each do |level|
  Level.create!(
    level: level
  )
end

# Create users

Group.all.each do |group|
  20.times do
    first_name = Faker::Name.first_name

    last_name = Faker::Name.last_name

    user = User.new(
      first_name: first_name,

      last_name: last_name,

      gender: Faker::Gender.binary_type,

      email: "#{first_name}.#{last_name.parameterize(separator: '_')}@#{Faker::Internet.domain_name}",

      description: Faker::Lorem.paragraph,

      password: 'password',

      password_confirmation: 'password',

      group: group,

      terms_of_service: true
    )

    user.skip_confirmation!

    user.save!

    user.add_points(rand(2000))
  end
end

# Create tags

50.times do
  Tag.first_or_create!(
    title: Faker::Nation.language
  )
end

# Create courses

40.times do
  Course.create!(
    name: Faker::Book.title,

    group: Group.all.sample,

    subject: Subject.all.sample
  )
end

# Create categories

categories = [

  'Notes de cours',

  'Annales d\'examens',

  'Travaux pratiques',

  'Résumés',

  'Devoirs maison',

  'Travaux dirigés',

  'Dissertations',

  'Autre'

]

categories.each do |category|
  Category.create!(
    name: category
  )
end

# Create test users

gabriel_guerin_superadmin = User.new(
  first_name: 'Gabriel',

  last_name: 'Guérin',

  gender: 'Masculin',

  email: Rails.application.credentials.dig(:development, :gabriel_guerin_superadmin_email),

  password: Rails.application.credentials.dig(:development, :gabriel_guerin_superadmin_password),

  password_confirmation: Rails.application.credentials.dig(:development, :gabriel_guerin_superadmin_password),

  group: Group.first,

  superadmin_role: true,

  terms_of_service: true
)

hugo_pochet_superadmin = User.new(
  first_name: 'Hugo',

  last_name: 'Pochet',

  gender: 'Masculin',

  email: Rails.application.credentials.dig(:development, :hugo_pochet_superadmin_email),

  password: Rails.application.credentials.dig(:development, :hugo_pochet_superadmin_password),

  password_confirmation: Rails.application.credentials.dig(:development, :hugo_pochet_superadmin_password),

  group: Group.first,

  superadmin_role: true,

  terms_of_service: true
)

gabriel_guerin_supervisor = User.new(
  first_name: 'Gabriel',

  last_name: 'Guérin',

  gender: 'Masculin',

  email: Rails.application.credentials.dig(:development, :gabriel_guerin_supervisor_email),

  password: Rails.application.credentials.dig(:development, :gabriel_guerin_supervisor_password),

  password_confirmation: Rails.application.credentials.dig(:development, :gabriel_guerin_supervisor_password),

  group: Group.first,

  supervisor_role: true,

  terms_of_service: true
)

gabriel_guerin_user = User.new(
  first_name: 'Gabriel',

  last_name: 'Guérin',

  gender: 'Masculin',

  email: Rails.application.credentials.dig(:development, :gabriel_guerin_user_email),

  password: Rails.application.credentials.dig(:development, :gabriel_guerin_user_password),

  password_confirmation: Rails.application.credentials.dig(:development, :gabriel_guerin_user_password),

  group: Group.first,

  terms_of_service: true
)

testusers = [gabriel_guerin_superadmin, hugo_pochet_superadmin, gabriel_guerin_supervisor, gabriel_guerin_user]

testusers.each do |testuser|
  testuser.skip_confirmation!

  testuser.save!
end

# Create posts

Group.all.each do |group|
  10.times do
    @post = Post.create!(
      user: User.where(group: group).sample,

      title: Faker::BossaNova.song,

      description: Faker::Movies::VForVendetta.quote,

      tags: Tag.all.sample(3),

      group_id: group.id,

      category: Category.all.sample,

      course: Course.all.sample,

      year: Year.all.sample,

      levels: Level.all.sample(1)
    )

    @post.file.attach(
      io: File.open('app/assets/images/seed/SEO.pdf'),

      filename: 'SEO.pdf',

      content_type: 'application/pdf',

      identify: false
    )
  end
end

# Create comments

Post.all.each do |post|
  5.times do
    Comment.create!(
      user: User.all.sample,

      post: post,

      description: Faker::Lorem.paragraph(sentence_count: 2)
    )
  end
end

# Link levels to posts

10.times do
  LevelsPost.create!(
    level: Level.all.sample,

    post: Post.all.sample
  )
end

# Link users to tags

20.times do
  TagsUser.create!(
    user: User.all.sample,

    tag: Tag.all.sample
  )
end

# Link posts to tags

100.times do
  PostsTag.create!(
    post: Post.all.sample,

    tag: Tag.all.sample
  )
end

# Create blogs

50.times do
  @blog = Blog.create!(
    user: User.all.sample,

    title: Faker::BossaNova.song,

    tags: Tag.all.sample(3),

    description: Faker::Movies::VForVendetta.quote,

    body: Faker::Lorem.paragraphs
  )

  @blog.cover.attach(
    io: File.open('app/assets/images/seed/blog_cover.jpg'),

    filename: 'blog_cover.jpg',

    content_type: 'image/jpg',

    identify: false
  )
end

# Link articles to tags

20.times do
  BlogsTag.create!(
    blog: Blog.all.sample,

    tag: Tag.all.sample
  )
end

# Posts

posts_test = File.read(Rails.root.join('lib', 'seeds', 'posts', 'posts_test.csv'))

csv = CSV.parse(posts_test, headers: true, encoding: 'ISO-8859-1', col_sep: ';')

csv.each do |row|
  post = Post.new

  post.user = User.find_by(first_name: row['first_name'], last_name: row['last_name'])

  post.title = row['title']

  post.description = row['description']

  post.tags = row['tag_list'].split(',').map do |title|
    Tag.where(title: title.strip).first_or_create!
  end

  post.group = Group.find_by(name: row['group'])

  post.course = Course.find_by(name: row['course'])

  post.category = Category.find_by(name: row['category'])

  post.year = Year.find_by(start_year: row['start_year'], end_year: row['end_year'])

  post.save!
end

# Delete Badges Sash

Merit::BadgesSash.delete_all
