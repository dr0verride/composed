require 'bundler/setup'
require 'benchmark/ips'
require 'composed'

class AClass
  def initialize(a:,b:,c:,d:); end
end

class InheritedClass < AClass
  def initialize(a: 1, b: 2, c: 3, d: 4); super; end
end

module ModuleClass
  def self.new(a: 1, b: 2, c: 3, d: 4)
    AClass.new(a: a,b: b, c: c, d: d)
  end
end

HalfComposed = Composed(AClass) do
  dep :a { 2 }
  dep :c { 3 }
end


FullComposed = Composed(AClass) do
  dep :a { 0 }
  dep :b { 1 }
  dep :c { 2 }
  dep :d { 3 }
end

Benchmark.ips do |x|
  x.report("Normal Class") { AClass.new(a: 1, b: 2, c: 3, d: 4) }
  x.report("Inheited Class") { InheritedClass.new }
  x.report("Module Class") { ModuleClass.new }
  x.report("Half Composed") { HalfComposed.new(b: 1, d: 2) }
  x.report("Full Composed") { FullComposed.new }

  x.compare!
end
