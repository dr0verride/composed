
class Composed
  class Keywords
    def initialize
      @injected = {}
    end

    def []=(keyword, value)
      raise ArgumentError, <<~ERROR if @injected.key?(keyword)
        Cannot inject keyword argument \"#{keyword}\" more than once."
      ERROR
      @injected[keyword] = value
    end

    def merge(args)
      @injected.each do |key, value|
        args[key] = value.call unless args.key?(key)
      end

      args
    end

    def empty?
      @injected.empty?
    end
  end
end
