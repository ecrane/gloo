require "test_helper"

class OpMultTest < Minitest::Test
  
  def setup
    @engine = Gloo::App::Engine.new( [ "--quiet" ] )
    @engine.start
  end

  def test_multipyling_two_numbers
    @engine.parser.run '= 5 * 3'
    assert_equal 15, @engine.heap.it.value
  end

  def test_multipyling_three_numbers
    @engine.parser.run '= 3 * 7 * 2'
    assert_equal 42, @engine.heap.it.value
  end
  
end
