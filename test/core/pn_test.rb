require 'test_helper'

class PnTest < BaseEngineTest

  def test_path_name_construction
    o = Gloo::Core::Pn.new @engine, 'x'
    assert o
    assert_equal 'x', o.src
    assert_equal 1, o.elements.count
  end

  def test_construction
    o = Gloo::Core::Pn.new( @engine, nil )
    assert o
    refute o.src

    o = Gloo::Core::Pn.new( @engine,  '' )
    assert o
    assert o.src
  end

  def test_setting_it
    o = Gloo::Core::Pn.root @engine
    o.set_to 'something.or.other'
    assert_equal 'something.or.other', o.src
    assert_equal 'something.or.other', o.to_s
  end

  def test_resolve
    @engine.parser.run '` one'
    o = Gloo::Core::Pn.new( @engine, 'one' ).resolve
    assert o
    assert_equal 'one', o.name
  end

  def test_resolve_not_found
    o = Gloo::Core::Pn.new( @engine, 'one' ).resolve
    refute o
  end

  def test_resolve_root
    o = Gloo::Core::Pn.root( @engine ).resolve
    assert o
    assert_equal 'root', o.name
  end

  def test_conversion_to_segments
    o = Gloo::Core::Pn.new( @engine, 'a.b.c' )
    segments = o.segments
    assert_equal 3, segments.count
    assert_equal 'a', segments[ 0 ]
    assert_equal 'b', segments[ 1 ]
    assert_equal 'c', segments[ 2 ]

    o = Gloo::Core::Pn.new( @engine, 'one' )
    segments = o.segments
    assert_equal 1, segments.count
    assert_equal 'one', segments[ 0 ]

    o = Gloo::Core::Pn.new( @engine, '' )
    assert_equal 0, o.segments.count

    o = Gloo::Core::Pn.new( @engine, nil )
    assert_equal 0, o.segments.count
  end

  def test_root_reference
    o = Gloo::Core::Pn.root @engine
    assert o
    assert_equal 'root', o.src
  end

  def test_root_exists
    o = Gloo::Core::Pn.root @engine
    assert o.exists?
  end

  def test_is_root
    o = Gloo::Core::Pn.root @engine
    assert o.root?
    o.set_to 'ROOT'
    assert o.root?
    o.set_to 'rOOt'
    assert o.root?
    o.set_to 'root '
    assert o.root?
    o.set_to 'not_root'
    refute o.root?
    o.set_to 'root!'
    refute o.root?
    o.set_to 'something.else'
    refute o.root?
  end

  def test_to_s
    o = Gloo::Core::Pn.new( @engine, 'other' )
    assert_equal 'other', o.to_s
  end

  def test_object_exists
    i = @engine.parser.parse_immediate '` can as container'
    i.run
    i = @engine.parser.parse_immediate '` can.x'
    i.run

    o = Gloo::Core::Pn.new @engine, 'can'
    assert o.exists?
    o = Gloo::Core::Pn.new @engine, 'can.x'
    assert o.exists?
  end

  def test_obj_does_not_exist
    o = Gloo::Core::Pn.new( @engine, 'does.not.exist' )
    refute o.exists?
    o.set_to 'root'
    assert o.exists?
  end

  def test_getting_parent_for_child
    i = @engine.parser.parse_immediate '` can as container'
    i.run
    can = @engine.heap.root.find_child 'can'
    assert can
    assert_equal 'can', can.name

    o = Gloo::Core::Pn.new @engine, 'can.x'
    parent = o.get_parent
    assert parent
    assert_same can, parent
  end

  def test_find_child_missing_parent
    o = Gloo::Core::Pn.new @engine, 'can.x'
    refute o.get_parent
    o = Gloo::Core::Pn.new @engine, 'a.b.c'
    refute o.get_parent
  end

  def test_getting_parent_for_root
    o = Gloo::Core::Pn.new @engine, 'a'
    assert_same @engine.heap.root, o.get_parent
  end

  def test_getting_name
    o = Gloo::Core::Pn.new @engine, ''
    assert_equal '', o.name

    o = Gloo::Core::Pn.new @engine, 'a'
    assert_equal 'a', o.name

    o = Gloo::Core::Pn.new @engine, 'a.b.c'
    assert_equal 'c', o.name
  end

  def test_has_name
    o = Gloo::Core::Pn.new @engine, ''
    refute o.named?

    o = Gloo::Core::Pn.new @engine, 'x'
    assert o.named?

    o = Gloo::Core::Pn.new @engine, 'x.y'
    assert o.named?
  end

  def test_has_path
    o = Gloo::Core::Pn.new @engine, ''
    refute o.includes_path?

    o = Gloo::Core::Pn.new @engine, 'x'
    refute o.includes_path?

    o = Gloo::Core::Pn.new @engine, 'x.y'
    assert o.includes_path?

    o = Gloo::Core::Pn.new @engine, 'x.y.z'
    assert o.includes_path?
  end

  def test_it_reference
    o = Gloo::Core::Pn.it( @engine )
    assert o
    assert_equal 'it', o.src
  end

  def test_it_exists
    o = Gloo::Core::Pn.it( @engine )
    assert o.exists?
  end

  def test_is_it
    o = Gloo::Core::Pn.it( @engine )
    assert o.it?
    o.set_to 'IT'
    assert o.it?
    o.set_to 'iT'
    assert o.it?
    o.set_to ' it '
    assert o.it?
    o.set_to 'something.else'
    refute o.it?
  end

  def test_error_reference
    o = Gloo::Core::Pn.error( @engine )
    assert o
    assert_equal 'error', o.src
  end

  def test_error_exists
    o = Gloo::Core::Pn.error( @engine )
    assert o.exists?
  end

  def test_is_error
    o = Gloo::Core::Pn.error( @engine )
    assert o.error?
    o.set_to 'ERROR'
    assert o.error?
    o.set_to 'eRRor'
    assert o.error?
    o.set_to ' erroR '
    assert o.error?
    o.set_to 'something.else'
    refute o.error?
  end

  def test_is_gloo_sys
    o = Gloo::Core::Pn.new @engine, '$'
    assert o.gloo_sys?
    o = Gloo::Core::Pn.new @engine, 'gloo'
    assert o.gloo_sys?
    o = Gloo::Core::Pn.new @engine, 'GLOO'
    assert o.gloo_sys?

    o = Gloo::Core::Pn.new @engine, '$.hostname'
    assert o.gloo_sys?
    o = Gloo::Core::Pn.new @engine, '$.user.name'
    assert o.gloo_sys?

    o = Gloo::Core::Pn.new @engine, 'hostname'
    refute o.gloo_sys?
    o = Gloo::Core::Pn.new @engine, 'asdf'
    refute o.gloo_sys?
    o = Gloo::Core::Pn.new @engine, 'user.name'
    refute o.gloo_sys?
  end

  def test_named_color
    o = Gloo::Core::Pn.new @engine, 'zyx'
    refute o.named_color?
    o = Gloo::Core::Pn.new @engine, 'name'
    refute o.named_color?
    o = Gloo::Core::Pn.new @engine, 'banana'
    refute o.named_color?

    o = Gloo::Core::Pn.new @engine, 'red'
    assert o.named_color?
    o = Gloo::Core::Pn.new @engine, 'black'
    assert o.named_color?
    o = Gloo::Core::Pn.new @engine, 'blue'
    assert o.named_color?
  end

  def test_includes_context
    o = Gloo::Core::Pn.error( @engine )
    o.set_to 'something.else'
    refute o.includes_context?
    o.set_to 'root'
    refute o.includes_context?
    o.set_to 'a.b.c'
    refute o.includes_context?
    o.set_to ''
    refute o.includes_context?

    o.set_to '@.something.else'
    assert o.includes_context?
    o.set_to '@.a.b.c'
    assert o.includes_context?
    o.set_to '@.x'
    assert o.includes_context?
  end

  def test_context_reference
    i = @engine.parser.parse_immediate '` can as container'
    i.run
    i = @engine.parser.parse_immediate '` can.x'
    i.run

    x = Gloo::Core::Pn.new( @engine, 'can.x' ).resolve
    assert x

    i = @engine.parser.parse_immediate '@ can'
    i.run

    y = Gloo::Core::Pn.new( @engine, '@.x' ).resolve
    assert y
    assert_equal x,y
  end

  def test_context_reference_reset
    i = @engine.parser.parse_immediate '` can as container'
    i.run
    i = @engine.parser.parse_immediate '` can.sub as container'
    i.run
    i = @engine.parser.parse_immediate '` can.sub.x'
    i.run

    x = Gloo::Core::Pn.new( @engine, 'can.sub.x' ).resolve
    assert x

    i = @engine.parser.parse_immediate '@ can.sub'
    i.run

    y = Gloo::Core::Pn.new( @engine, '@.x' ).resolve
    assert y
    assert_equal x,y

    i = @engine.parser.parse_immediate '@ root'
    i.run

    z = Gloo::Core::Pn.new( @engine, 'can.sub.x' ).resolve
    assert_equal x,z
    assert_equal y,z
  end

end
