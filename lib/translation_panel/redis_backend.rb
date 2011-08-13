module TranslationPanel
  class RedisBackend < I18n::Backend::KeyValue
    include I18n::Backend::Pluralization

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
        pluralization_result = count ? get_count_keys(locale, key) : {}
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
          expand_keys(pluralization_result.merge(flatten_result)).deep_symbolize_keys
        end
      end
    end

    # Transforms flatten hash into nested hash
    #   expand_keys "some.one" => "a", "some.another" => "b"
    #   # => "some" => {"one" => "a", "another" => "b"}
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

    # Creates empty translations for absented pluralization keys.
    # Returns hash with plural keys and their values (even from another backend)
    def get_count_keys(locale, key)
      I18n.t!('i18n.plural.keys', :locale => locale).inject({}) do |result, plural_key|
        full_key = "#{key}.#{plural_key}"
        value = get_translate(locale, full_key)
        unless value
          I18n.backend.store_translations locale, {full_key => ""}, :escape => false
          value = ""
        end
        result.merge plural_key.to_s => value
      end
    rescue
      {}
    end

    # returns translation key if any, otherwise nil
    def get_translate(locale, key)
      I18n.t!(key, :locale => locale)
    rescue
      nil
    end
  end
end
