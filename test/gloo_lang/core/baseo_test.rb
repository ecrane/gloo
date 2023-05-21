require 'test_helper'

class BaseoTest < BaseEngineTest

  def test_that_all_objects_have_names
    o = GlooLang::Core::Baseo.new @engine
    assert o
    assert o.name
  end

end
