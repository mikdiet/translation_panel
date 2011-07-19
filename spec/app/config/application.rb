require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"

Bundler.require(:default, Rails.env) if defined?(Bundler)

module App
  class Application < Rails::Application
    config.i18n.default_locale = :ru
    config.encoding = "utf-8"
    config.assets.enabled = true
    config.generators do |g|
      g.test_framework      :rspec
    end
  end
end
