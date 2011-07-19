module TranslationPanel
  class RedisBackend < I18n::Backend::KeyValue
    def initialize(store)
      @subtrees = false
      @store = store
    end

  protected
    def lookup(locale, key, scope = [], options = {})
      key = normalize_flat_keys(locale, key, scope, options[:separator])
      count = options[:count]
      if !count && value = @store["#{locale}.#{key}"]
        TranslationPanel.push key if TranslationPanel.show?
        ActiveSupport::JSON.decode(value) if value
      else  # look in namespace
        store_count_keys(locale, key) if count
        full_keys = @store.keys "#{locale}.#{key}.*"
        if full_keys.empty?
          TranslationPanel.push key if TranslationPanel.show?
          nil
        else
          keys = full_keys.map{ |full_key| full_key.partition("#{locale}.")[2] }
          TranslationPanel.push keys if TranslationPanel.show?
          flatten_result = full_keys.inject({}) do |result, full_key|
            value = @store[full_key]
            value = ActiveSupport::JSON.decode(value) if value
            result.merge full_key.partition("#{locale}.#{key}.")[2] => value
          end
          expand_keys(flatten_result).deep_symbolize_keys
        end
      end
    end

    def expand_keys(flatten_hash)
      expanded_hash = {}
      flatten_hash.each do |key, value|
        key_parts = key.partition "."
        if key_parts[2].empty?
          expanded_hash.deep_merge! key => value
        else
          expanded_hash.deep_merge! key_parts[0] => expand_keys(key_parts[2] => value)
        end
      end
      expanded_hash
    end

    def store_count_keys(locale, key)
      if TranslationPanel.show?
        I18n.t!('i18n.plural.keys', :locale => locale).each do |k|
          unless translate_present?(locale, "#{key}.#{k}")
            I18n.backend.store_translations locale, {"#{key}.#{k}" => ""}, :escape => false
          end
        end
      end
    rescue
      nil
    end

    def translate_present?(locale, key)
      I18n.t!(key, :locale => locale)
    rescue
      false
    end
  end
end
