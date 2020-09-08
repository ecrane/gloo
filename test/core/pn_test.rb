require 'test_helper'

class PnTest < Minitest::Test

  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
  end

  def test_path_name_construction
    o = Gloo::Core::Pn.new 'x'
    assert o
    assert_equal 'x', o.src
    assert_equal 1, o.elements.count
  end

  def test_construction
    o = Gloo::Core::Pn.new( nil )
    assert o
    refute o.src

    o = Gloo::Core::Pn.new( '' )
    assert o
    assert o.src
  end

  def test_setting_it
    o = Gloo::Core::Pn.root
    o.set_to 'something.or.other'
    assert_equal 'something.or.other', o.src
    assert_equal 'something.or.other', o.to_s
  end

  def test_resolve
    @engine.parser.run '` one'
    o = Gloo::Core::Pn.new( 'one' ).resolve
    assert o
    assert_equal 'one', o.name
  end

  def test_resolve_not_found
    o = Gloo::Core::Pn.new( 'one' ).resolve
    refute o
  end

  def test_resolve_root
    o = Gloo::Core::Pn.root.resolve
    assert o
    assert_equal 'root', o.name
  end

  def test_conversion_to_segments
    o = Gloo::Core::Pn.new( 'a.b.c' )
    segments = o.segments
    assert_equal 3, segments.count
    assert_equal 'a', segments[ 0 ]
    assert_equal 'b', segments[ 1 ]
    assert_equal 'c', segments[ 2 ]

    o = Gloo::Core::Pn.new( 'one' )
    segments = o.segments
    assert_equal 1, segments.count
    assert_equal 'one', segments[ 0 ]

    o = Gloo::Core::Pn.new( '' )
    assert_equal 0, o.segments.count

    o = Gloo::Core::Pn.new( nil )
    assert_equal 0, o.segments.count
  end

  def test_root_reference
    o = Gloo::Core::Pn.root
    assert o
    assert_equal 'root', o.src
  end

  def test_root_exists
    o = Gloo::Core::Pn.root
    assert o.exists?
  end

  def test_is_root
    o = Gloo::Core::Pn.root
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
    o = Gloo::Core::Pn.new( 'other' )
    assert_equal 'other', o.to_s
  end

  def test_object_exists
    i = @engine.parser.parse_immediate '` can as container'
    i.run
    i = @engine.parser.parse_immediate '` can.x'
    i.run

    o = Gloo::Core::Pn.new 'can'
    assert o.exists?
    o = Gloo::Core::Pn.new 'can.x'
    assert o.exists?
  end

  def test_obj_does_not_exist
    o = Gloo::Core::Pn.new( 'does.not.exist' )
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

    o = Gloo::Core::Pn.new 'can.x'
    parent = o.get_parent
    assert parent
    assert_same can, parent
  end

  def test_find_child_missing_parent
    o = Gloo::Core::Pn.new 'can.x'
    refute o.get_parent
    o = Gloo::Core::Pn.new 'a.b.c'
    refute o.get_parent
  end

  def test_getting_parent_for_root
    o = Gloo::Core::Pn.new 'a'
    assert_same @engine.heap.root, o.get_parent
  end

  def test_getting_name
    o = Gloo::Core::Pn.new ''
    assert_equal '', o.name

    o = Gloo::Core::Pn.new 'a'
    assert_equal 'a', o.name

    o = Gloo::Core::Pn.new 'a.b.c'
    assert_equal 'c', o.name
  end

  def test_has_name
    o = Gloo::Core::Pn.new ''
    refute o.named?

    o = Gloo::Core::Pn.new 'x'
    assert o.named?

    o = Gloo::Core::Pn.new 'x.y'
    assert o.named?
  end

  def test_has_path
    o = Gloo::Core::Pn.new ''
    refute o.includes_path?

    o = Gloo::Core::Pn.new 'x'
    refute o.includes_path?

    o = Gloo::Core::Pn.new 'x.y'
    assert o.includes_path?

    o = Gloo::Core::Pn.new 'x.y.z'
    assert o.includes_path?
  end

  def test_it_reference
    o = Gloo::Core::Pn.it
    assert o
    assert_equal 'it', o.src
  end

  def test_it_exists
    o = Gloo::Core::Pn.it
    assert o.exists?
  end

  def test_is_it
    o = Gloo::Core::Pn.it
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
    o = Gloo::Core::Pn.error
    assert o
    assert_equal 'error', o.src
  end

  def test_error_exists
    o = Gloo::Core::Pn.error
    assert o.exists?
  end

  def test_is_error
    o = Gloo::Core::Pn.error
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
    o = Gloo::Core::Pn.new '$'
    assert o.gloo_sys?
    o = Gloo::Core::Pn.new 'gloo'
    assert o.gloo_sys?
    o = Gloo::Core::Pn.new 'GLOO'
    assert o.gloo_sys?

    o = Gloo::Core::Pn.new '$.hostname'
    assert o.gloo_sys?
    o = Gloo::Core::Pn.new '$.user.name'
    assert o.gloo_sys?

    o = Gloo::Core::Pn.new 'hostname'
    refute o.gloo_sys?
    o = Gloo::Core::Pn.new 'asdf'
    refute o.gloo_sys?
    o = Gloo::Core::Pn.new 'user.name'
    refute o.gloo_sys?
  end

  def test_named_color
    o = Gloo::Core::Pn.new 'zyx'
    refute o.named_color?
    o = Gloo::Core::Pn.new 'name'
    refute o.named_color?
    o = Gloo::Core::Pn.new 'banana'
    refute o.named_color?

    o = Gloo::Core::Pn.new 'red'
    assert o.named_color?
    o = Gloo::Core::Pn.new 'black'
    assert o.named_color?
    o = Gloo::Core::Pn.new 'blue'
    assert o.named_color?
  end

end
