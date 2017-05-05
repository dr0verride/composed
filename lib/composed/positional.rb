
class Composed
  class Positional
    def initialize(merge_strategy = default_strategy)
      @injected = {}
      @index = 0
      @merge_strategy = merge_strategy
    end

    def []=(idx, value)
      @index = idx
      push(value)
    end

    def push(value)
      set(@index,value)
      @index += 1
    end

    alias_method :<<, :push

    def merge(args)
      @merge_strategy.call(args,@injected)
    end

    private
    def set(idx, value)
      @injected[idx] = value
      @injected = Hash[@injected.sort]
    end

    class OverrideStrategy
      def call(args, injected)
        missing = 0
        injected.each do |idx,value|
          if args.size == idx
            args[idx] = value.call
          elsif args.size < idx
            missing += 1
          end
        end

        raise ArgumentError, <<~ERROR if missing > 0
          wrong number of arguments (given #{args.size}, expected #{args.size + missing}
        ERROR

        args
      end
    end

    class SkipStrategy
      def call(args, injected)
        missing = 0
        injected.each do |idx, value|
          missing += 1 if args.size < idx
          args.insert(idx,value.call)
        end

        raise ArgumentError, <<~ERROR if missing > 0
          wrong number of arguments (given #{args.size}, expected #{args.size + missing}
        ERROR

        args
      end
    end

    def default_strategy
      self.class.strategy
    end

    class << self
      STRATEGY_LOOKUP = {
        skip: SkipStrategy,
        override: OverrideStrategy,
        default: OverrideStrategy
      }

      def strategy=(strategy)
        @strategy = klass_for(strategy).new
      end

      def klass_for(strategy)
        return strategy if strategy.respond_to?(:new)

        STRATEGY_LOOKUP.fetch(strategy) { raise ArgumentError, <<~ERROR }
          Unsupported strategy: #{strategy}. Use one of the following:
          :skip - Skips over injected arguments. Cannot override injections at call time.
          :override - Positional arguments behave as normal function calls. Defaults are overridden in order.
          :default - Set the default. :override
        ERROR

      end
    end

    def self.strategy
      @strategy ||= klass_for(:default).new
    end

  end
end
