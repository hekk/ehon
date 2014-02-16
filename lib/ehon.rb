require "ehon/version"

module Ehon
  def self.included(base)
    base.extend ClassMethods
    base.contents        = {}
    base.default_options = {}
  end

  def initialize(id, options = {})
    @options = options.merge(id: id)
  end

  def options
    self.class.default_options.merge(@options)
  end

  def ==(other)
    (self.class == other.class) && (self.id == other.id)
  end

  def respond_to_missing?(symbol, include_private = false)
    self.options.has_key?(symbol)
  end

  def method_missing(symbol, *args)
    return self.options[symbol] if respond_to?(symbol)
    super
  end

  module ClassMethods
    attr_accessor :contents, :default_options

    def page(id, options = {}, &block)
      instance = new(id, options)
      instance.instance_eval(&block) if block_given?
      self.contents[id] = instance
      instance
    end
    alias enum page

    def default(options = {})
      self.default_options.merge!(options)
    end

    def all
      self.contents.values
    end

    def find(*queries)
      queries.flatten!
      findeds = queries.map {|query|
        next self.contents[query] unless query.is_a?(Hash)
        self.contents.values.find {|instance|
          query.all? {|key, value| instance.options[key] == value }
        }
      }.compact
      queries.size == 1 ? findeds.first : findeds
    end
    alias [] find
  end
end

