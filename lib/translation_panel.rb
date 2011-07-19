require "translation_panel/filter"
require "translation_panel/redis_backend"

# Using with Redis:
# 1. Run redis-server
# 2. Set up redis connection settings and register RedisTranslator::Backend as
# i18n backend in initializers:
#     require 'redis_translator'
#     I18n.backend = RedisTranslator::Backend.new(Redis.new)
#     # or in chain with another backend
# 3. Create action which receive translation pair and saves it. Don't forget to
# create route for GET-requests to this action
#     class Admin::TranslationsController < ApplicationController
#       def new
#         I18n.backend.store_translations params[:locale], {params[:key] => params[:value]},
#             :escape => false
#         render :text => 'ok', :content_type => "text/plain"
#       end
#     end
# 4. Create around filter for actions, where needed to show TranslationPanel
# frontend panel. Initializator receives path for action and condition. 
#     around_filter TranslationPanel::Filter.new('/admin/translations/new', :show_panel?)
# 5. TranslationPanel's javascript and stylesheet can be customized by copying
# necessary files from +app/assets+ to app's +vendor/assets+. It can be done
# automatically by run:
#     $ rails generate redis_translator:install

module TranslationPanel
  class << self
    def show!
      Thread.current[:translations_list] = []
      Thread.current[:collect_translation_data] = true
    end

    def kill!
      Thread.current[:translations_list] = nil
      Thread.current[:collect_translation_data] = nil
    end

    def show?
      Thread.current[:collect_translation_data]
    end

    def push value
      Thread.current[:translations_list] << value
    end

    def values
      Thread.current[:collect_translation_data] = false
      Thread.current[:translations_list].uniq.map do |key|
        value = get_value(key)
        {:key => key, :value => value} if value.is_a?(String)
      end.compact
    end

    def get_value(key)
      I18n.translate! key
    rescue
      ""
    end
  end
end
