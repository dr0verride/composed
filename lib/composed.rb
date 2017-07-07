require 'composed/version'
require 'composed/positional'
require 'composed/keywords'

class Composed
  def initialize(klass, interface = :new, &block)
    raise ArgumentError, "Must provide a block to define Composed Type" unless block_given?
    @klass = klass
    @injected_pos_args = Positional.new
    @injected_kw_args = Keywords.new
    @interface = interface
    @ctor = nil

    instance_eval(&block)

    singleton_class.send(:alias_method, interface, :execute_composition)
    singleton_class.send(:public, interface, :execute_composition)
    
    if interface == :call
      singleton_class.send(:alias_method, :[], :execute_composition)
      singleton_class.send(:public, :[])
    end
  end

  private

  def execute_composition(*args, **kwargs, &block)
    args = @injected_pos_args.merge(args)

    object =  if kwargs.empty? && @injected_kw_args.empty?
                @klass.send(@interface, *args, &block)
              else
                kwargs = @injected_kw_args.merge(kwargs)
                @klass.send(@interface, *args, **kwargs, &block)
              end

    object.instance_eval(&@ctor) if @ctor
    object
  end

  def dependency(keyword_or_idx = nil, &block)
    case keyword_or_idx
    when String, Symbol
      @injected_kw_args[keyword_or_idx.to_sym] = block
    when Integer
      @injected_pos_args[keyword_or_idx] = block
    else
      @injected_pos_args << block
    end
  end

  def define_kw_dependency(keyword, block)
    raise ArgumentError, <<~ERROR if @injected_kw_args.key?(keyword)
      Cannot inject keyword argument \"#{keyword}\" more than once."
    ERROR
    @injected_kw_args[keyword] = block
  end

  def constructor(&block)
    @ctor = block
  end


  def factory(method_name, &block)
    bound = self.class.new(self,&block)
    self.define_singleton_method(method_name) do |*args|
      bound.new(*args)
    end
  end

  module Macro
    def Composed(*args, &block)
      Composed.new(*args,&block)
    end
  end
end

include Composed::Macro
