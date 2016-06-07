require 'hash_builder/context_delegator'
require 'hash_builder/container'

module HashBuilder
  extend ActiveSupport::Concern

  included do
    cattr_accessor :hash_container, instance_writer: false
  end

  module ClassMethods
    def hash_builder(*attributes)
      options = attributes.extract_options!
      raise ArgumentError unless method_name = options.delete(:method_name)

      unless method_defined?(method_name.to_sym)
        define_method(method_name.to_sym) { hash_container.send(method_name, self) }
      end

      self.hash_container ||= Container.new(self)
      self.hash_container.add(method_name, attributes, options)
    end
  end
end
