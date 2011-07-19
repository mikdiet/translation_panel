require 'redis'
require 'translation_panel'

MultiJson.engine = :yajl

redis = Redis.new(YAML::load_file(File.join(Rails.root, '/config/redis.yml'))[Rails.env].symbolize_keys)

I18n.backend = TranslationPanel::RedisBackend.new(redis)
