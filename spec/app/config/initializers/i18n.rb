require 'redis'
require 'translation_panel'

MultiJson.engine = :yajl

I18n::Backend::Simple.include I18n::Backend::Pluralization
r_conf = YAML::load_file(File.join(Rails.root, '/config/redis.yml'))[Rails.env].symbolize_keys
Redis_backend = TranslationPanel::RedisBackend.new Redis.new(r_conf)
I18n.backend = I18n::Backend::Chain.new Redis_backend, I18n::Backend::Simple.new
