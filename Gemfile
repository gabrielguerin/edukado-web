# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'

gem 'rails', '~> 6.0.2', '>= 6.0.2.1'

# Use postgresql as the database for Active Record

gem 'pg', '>= 0.18', '< 2.0'

# Use Puma as the app server

gem 'puma', '~> 4.1'

# Use SCSS for stylesheets

gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker

gem 'webpacker', '~> 4.0'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks

gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder

gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production

# gem 'redis', '~> 4.0'

# Use Active Model has_secure_password

# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant

gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb

gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console

  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # Replace the standard Rails error page with a much better and more useful error page

  gem 'better_errors'

  # Retrieve the binding of a method's caller in MRI (>= 2.0.0) and RBX (Rubinius)

  gem 'binding_of_caller'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.

  gem 'web-console', '>= 3.3.0'

  # Open emails in the browser

  gem 'letter_opener'
end

group :test do
  # Adds support for Capybara system testing and selenium driver

  gem 'capybara', '>= 2.15'

  gem 'selenium-webdriver'

  # Easy installation and use of web drivers to run system tests with browsers

  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Kiso themes

gem 'kiso_themes', '~>1.0.2', path: 'vendor/gems/kiso_themes-1.0.2'

# Flexible authentication solution for Rails with Warden

gem 'devise'

# Adds support to Devise for sending invitations by email

gem 'devise_invitable', '~> 2.0.0'

# Votable ActiveRecord for Rails

gem 'acts_as_votable'

# pg_search builds ActiveRecord named scopes that take advantage of PostgreSQL’s full text search

gem 'pg_search'

# Adds reputation behavior to Rails apps in the form of Badges, Points, and Rankings

gem 'merit'

# "Swiss Army bulldozer" of slugging and permalink plugins for ActiveRecord.

gem 'friendly_id', '~> 5.2.4'

# Framework for creating flexible, powerful admin dashboards in Rails

gem 'administrate'

# Support Active Storage in Administrate

gem 'administrate-field-active_storage'

# Mini replacement for RMagick

gem 'mini_magick'

# A Scope & Engine based, clean, powerful, customizable and sophisticated paginator for Ruby webapps

gem 'kaminari'

# Official Twilio SendGrid Led, Community Driven Ruby API Library

gem 'sendgrid-ruby'

# Official AWS SDK for Ruby

gem 'aws-sdk-s3', require: false

# Intelligent search made easy with Rails and Elasticsearch

gem 'searchkick'

# Support for `render` with Turbolinks in Rails controllers

gem 'turbolinks_render'

# Rails Plugin that tracks impressions and page views

gem 'impressionist'

# Seed with Faker

gem 'faker'

# Provides a set of helpers which guide you in leveraging regular Ruby classes and object oriented design patterns to build a simple, robust and scalable authorization system

gem 'pundit'

# Shows objects in nicely formatted columns for easy reading

gem 'table_print'
