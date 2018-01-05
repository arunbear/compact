module BoundedStack
    def initialize()
        @stack = []
    end

    def push(item)
        @stack << item
    end

    def pop
        @stack.pop
    end

    def size
        @stack.size
    end

    def top
        @stack.last
    end
end

module BoundedStackBadTop
    include BoundedStack

    def top
        @stack.first
    end
end
