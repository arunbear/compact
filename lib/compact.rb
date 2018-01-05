require 'duplicate'
require "compact/version"

module Compact
  class Violation < RuntimeError
  end

  class Modular
    def spec
        @spec
    end

    def initialize(arg)
        @spec = arg
    end

    def bind(impl)
        @impl_src = impl
        @impl = Class.new do
            include impl 
        end
        check_interface
        add_contracts
        return @impl
    end

    def check_interface
        @spec[:object_does].keys.each do |k|
            @impl.instance_method k
        end
    end

    def add_contracts
        @spec[:object_does].each do |k, v|
            add_post_conditions(k, v[:postcond])
            add_invariants(k)
        end
    end

    def add_post_conditions(meth, spec)
        spec ||= {}
        spec.each do |desc, proc| 
            orig_meth = :"orig_#{meth}"
            @impl.send(:alias_method, orig_meth, meth)
            impl_src = @impl_src
            create_method @impl, meth do |*args|
                old = duplicate(self)
                result = self.send(orig_meth, *args)
                proc.call(self, old, result) or 
                    raise Violation, "Post condition '#{desc}' on #{impl_src}##{meth} failed."
                result
            end
        end 
    end

    def add_invariants(meth)
        spec = @spec[:invariant] || {}
        spec.each do |desc, proc| 
        end 
    end

    def create_method(a_class, name, &block)
        a_class.send(:define_method, name, &block)
    end
  end
end
