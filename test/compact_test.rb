require "test_helper"
require 'boundedstack'

class CompactTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Compact::VERSION
  end

  def setup
    @contract = Compact::Modular.new(
        object_does: {
            push: {
                postcond: {
                    size_increased_by_one: proc { |obj, old|
                        obj.size == old.size + 1
                    }
                }
            },
            pop: {
                postcond: {
                    returns_old_top: -> (obj, old, result) {
                        result == old.top
                    }
                }
            },
            size: {},
            top: {},
        },
        invariant: {
            max_size_not_exceeded: -> (obj) { obj.size <= obj.max_size }
        }
    )
  end

  def test_bounded_stack
    stack_class = @contract.bind(BoundedStack)
    stack = stack_class.new
    stack.push 1
    stack.push 2
    assert stack.size == 2
    assert stack.pop == 2
    assert stack.size == 1
  end

  def test_bounded_stack_bad_top
    stack_class = @contract.bind(BoundedStackBadTop)
    stack = stack_class.new
    stack.push 1
    stack.push 2
    assert_raises Compact::Violation do
      stack.pop == 2
    end
  end
end
