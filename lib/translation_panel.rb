require "translation_panel/filter"
require "translation_panel/redis_backend"
require "translation_panel/engine"

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
