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
    return read_attribute(symbol) if respond_to?(symbol)
    super
  end

  def read_attribute(symbol)
    self.options[symbol]
  end

  module ClassMethods
    attr_accessor :contents, :default_options

    def enum(id, options = {}, &block)
      instance = new(id, options)
      instance.instance_eval(&block) if block_given?
      self.contents[id] = instance
      instance
    end

    def default(options = {})
      self.default_options.merge!(options)
    end

    def create_readers!
      options.each {|option| define_reader option }
    end

    def create_writers!
      options.each {|option| define_writer option }
    end

    def create_accessors!
      create_readers!
      create_writers!
    end

    def all
      self.contents.values
    end

    def find(*queries)
      queries.flatten!
      findeds = queries.map {|query|
        next self.contents[query] unless query.is_a?(Hash)
        self.contents.values.find {|instance|
          query.all? {|key, value| instance.read_attribute(key) == value }
        }
      }.compact
      queries.size == 1 ? findeds.first : findeds
    end
    alias [] find

    private
    def options
      self.contents.values.map {|e| e.options.keys }.flatten.uniq
    end

    def define_reader(symbol)
      class_eval do
        define_method(symbol) { read_attribute(symbol) }
      end
    end

    def define_writer(symbol)
      class_eval do
        define_method("#{symbol}=") {|value| self.options[symbol] = value }
      end
    end
  end
end
