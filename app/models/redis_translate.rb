class RedisTranslate
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :id, :locale, :key, :value
  attr_accessor :attributes, :persisted

  validates :id, :locale, :key, :presence => true
  #validates :id, :unique => true

  class << self
    def backend
      case I18n.backend
        when TranslationPanel::RedisBackend then I18n.backend
        when I18n::Backend::Chain then I18n.backend.backends.first
      else raise 'wrong backend'
      end
    end

    def find(find_what, options = {})
      if options.present? || find_what.is_a?(Symbol)
        # if id and options in params, first find for all ids for options and next find id in results
        unless find_what.is_a? Symbol
          options.merge! :id => find_what.to_s
          find_what = :first
        end

        # First, look for all matched keys
        search_locale = options[:locale] || '*'
        search_key = options[:key] || '*'
        search_ids = Array.wrap options[:id]
        result_keys = store.keys "#{search_locale}.#{search_key}"
        result_keys = result_keys.select{ |k| search_ids.include? k } if search_ids.present?

        # then look for matched values if necessary
        real_results = nil
        if options[:value]
          real_results = result_keys.map{ |key| find key }.select do |t|
            t.value == options[:value] || options[:value].is_a?(Regexp) && t.value =~ options[:value]
          end
        end

        case find_what
          when :all   then real_results || result_keys.map{ |key| find key }
          when :first then real_results ? real_results.first : find(result_keys.first)
          when :last  then real_results ? real_results.last  : find(result_keys.last)
        else raise "wrong first argument"
        end

      else
        value = store[find_what]
        if value
          record = self.new :id => find_what, :value => ActiveSupport::JSON.decode(value)
          record.persisted = true
          record
        else
          nil
        end
      end
    end

    def store
      @store ||= backend.store
    end
  end  # self

  def ==(other)
    id == other.id
  end

  def attributes=(value = {})
    value.each do |name, value|
      send("#{name}=", value)
    end
  end

  def id=(value)
    @id = value.to_s
    @locale, @key = value.partition('.').values_at(0, 2)
  end

  def initialize(attributes = {})
    self.attributes = attributes
  end

  def key=(value)
    @key = value.to_s
    reset_id
  end

  def locale=(value)
    @locale = value.to_s
    reset_id
  end

  def persisted?
    !!@persisted
  end

  def reset_id
    @id = "#{@locale}.#{@key}"
  end

  def save
    if valid?
      self.class.store[@id] = ActiveSupport::JSON.encode(@value)
      self.persisted = true
    else
      false
    end
  end

  def update_attributes(attributes = {})
    self.attributes = attributes
    save
  end
end
