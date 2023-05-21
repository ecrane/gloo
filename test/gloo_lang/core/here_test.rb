require 'test_helper'

class HereTest < BaseEngineTest

  def test_includes_here_ref
    o = GlooLang::Core::Pn.new @engine, 'abc'
    refute GlooLang::Core::Here.includes_here_ref?( o.elements )

    o = GlooLang::Core::Pn.new @engine, 'z.y.x'
    refute GlooLang::Core::Here.includes_here_ref?( o.elements )

    o = GlooLang::Core::Pn.new @engine, '^^.zyx'
    assert GlooLang::Core::Here.includes_here_ref?( o.elements )

    o = GlooLang::Core::Pn.new @engine, '^.one.two'
    assert GlooLang::Core::Here.includes_here_ref?( o.elements )
  end

  def test_here_ref_in_script
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.x as int : 3'
    @engine.parser.run 'create c.s as script : "show ^.x + 2"'
    @engine.parser.run 'run c.s'
    assert_equal 5, @engine.heap.it.value
  end

  def test_here_ref_in_script_two_levels
    @engine.parser.run 'create a as can'
    @engine.parser.run 'create a.c as can'
    @engine.parser.run 'create a.x as int : 3'
    @engine.parser.run 'create a.c.s as script : "show ^^.x + 4"'
    @engine.parser.run 'run a.c.s'
    assert_equal 7, @engine.heap.it.value
  end

end
