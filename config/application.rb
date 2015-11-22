require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'neo4j/railtie'
require 'rails/test_unit/railtie'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Switch
  ENV['NEO4J_URL'] = 'http://127.0.0.1:7474'
  ENV['NEO4J_URL'] || raise('no NEO4J_URL provided')

  class Application < Rails::Application
    config.autoload_paths.push(*%W(#{config.root}/lib
                                  #{config.root}/enums)
    )

    # load config
    switch_config_file = Rails.root.join('config', 'switch.yml')
    switch_config = YAML.load(ERB.new(File.read(switch_config_file)).result)[Rails.env]

    config.generators do |g|
      g.orm             :neo4j
      g.test_framework  :rspec, :fixture => false
    end

    unless switch_config['neo4j']['url'].nil?
      config.neo4j.session_type = :server_db
      config.neo4j.session_path = ENV['NEO4J_URL'] || 'http://localhost:7474'
      config.neo4j.session_options = { basic_auth: { username: 'neo4j', password: 'switch!2'} }
    end

    # jbuilder root path setting
    config.middleware.use(Rack::Config) do |env|
      env['api.tilt.root'] = Rails.root.join 'app', 'views'
    end
    #config.autoload_paths += %W(#{config.root}/app/enums)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
