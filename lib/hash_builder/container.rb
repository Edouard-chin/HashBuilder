require 'active_support/all'

module HashBuilder
  class Container
    attr_reader :storage, :method_names, :context

    RECOGNIZED_OPTIONS = [:delegate_to, :from, :nest_under, :if]
    AFFIX = [:key_prefix, :key_suffix, :accessor_prefix, :accessor_suffix]

    def add(method_name, elements, options = {})
      delegate_to, from, nest_under, condition = options.values_at(*RECOGNIZED_OPTIONS)
      method_names << method_name.to_sym

      keys, attributes = prepare_hash(elements, from, options)
      build_hash_structure(method_name, keys, attributes, nest_under)

      add_delegation(delegate_to, attributes) if delegate_to
      add_condition(condition, method_name) if condition
    end

    def prepare_hash(elements, from, options)
      key_prefix, key_suffix, accessor_prefix, accessor_suffix = options.values_at(*AFFIX)
      keys = elements.map { |el| "#{key_prefix}#{el}#{key_suffix}" }
      attributes = elements.map { |el| from ? from : "#{accessor_prefix}#{el}#{accessor_suffix}" }

      [keys, attributes]
    end

    def build_hash_structure(method_name, keys, attributes, nest_under)
      data = keys.zip(attributes)

      deep_access(Array.wrap(nest_under), storage[method_name]) do |storage_pointer|
        storage_pointer.merge!(Hash[data])
      end
    end

    def deep_access(nest_under, pointer, &block)
      return yield(pointer) if nest_under.empty?
      nest_under.each_with_index do |parent, index|
        if nest_under[index + 1]
          nest_under.shift
          deep_access(nest_under, pointer[parent], &block)
        else
          block.call(pointer[parent])
        end
      end
    end

    def initialize(object)
      @context = ContextDelegator.new(object)
      @storage = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      @method_names = []
    end

    private

    def add_condition(condition, method_name)
      if condition.is_a?(Proc)
        @context.singleton_class.set_callback :transform, condition, if: ->(o) { method_name == o.called_method }
      elsif condition.is_a?(Symbol)
        @context.singleton_class.set_callback :transform, :around, make_lambda(condition), if: ->(o) { method_name == o.called_method }
      end
    end

    def make_lambda(condition)
      lambda { |o, block| raise ContextDelegator::UnsatisfiedCondition unless block.call.send(condition) }
    end

    def add_delegation(delegate_to, methods)
      @context.singleton_class.delegate *methods, to: delegate_to
    end

    def transform(hash, scope = [])
      hash.each do |key, value|
        if value.is_a?(Hash)
          transform(value, scope + [key])
        else
          begin
            @context.run_callbacks :transform do
              hash[key] = @context.send(value)
            end
          rescue ContextDelegator::UnsatisfiedCondition
            hash.delete(key)
          end
        end
      end
    end

    def method_missing(method_name, *args)
      if method_names.include?(method_name)
        @context.__setobj__(*args)
        @context.called_method = method_name

        transform(storage[method_name].deep_dup).with_indifferent_access
      else
        super
      end
    end

    def respond_to_missing?(method_name)
      method_names.include?(method_name)
    end
  end
end
