# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems

# you've limited to :test, :development, or :production.

Bundler.require(*Rails.groups)

module EdukadoDesktop
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.

    config.load_defaults 6.0

    config.i18n.available_locales = %i[en fr]

    config.i18n.default_locale = :fr

    # Settings in config/environments/* take precedence over those specified here.

    # Application configuration can go into files in config/initializers

    # -- all .rb files in that directory are automatically loaded after loading

    # the framework and any gems in your application.

    config.to_prepare do
      Administrate::ApplicationController.helper EdukadoDesktop::Application.helpers
    end

    # Add views/statics to default view paths

    config.paths['app/views'].unshift("#{Rails.root}/app/views/statics/")

    # Read csv files

    require 'csv'
  end
end
