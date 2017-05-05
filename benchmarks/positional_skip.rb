require 'bundler/setup'
require 'benchmark/ips'
require 'composed'

Composed::Positional.strategy = :skip

class AClass
  def initialize(a,b,c,d); end
end

class InheritedClass < AClass
  def initialize(a = 1, b = 2, c = 3, d = 4); super; end
end

module ModuleClass
  def self.new(a = 1, b = 2, c = 3, d = 4)
    AClass.new(a,b,c,d)
  end
end

HalfComposed = Composed(AClass) do
  dep 1 { 2 }
  dep 2 { 3 }
end


FullComposed = Composed(AClass) do
  dep { 0 }
  dep { 1 }
  dep { 2 }
  dep { 3 }
end

Benchmark.ips do |x|
  x.report("Normal Class") { AClass.new(1,2,3,4) }
  x.report("Inheited Class") { InheritedClass.new }
  x.report("Module Class") { ModuleClass.new }
  x.report("Half Composed") { HalfComposed.new(1,2) }
  x.report("Full Composed") { FullComposed.new }

  x.compare!
end
