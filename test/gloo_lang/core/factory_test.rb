require 'test_helper'

class FactoryTest < BaseEngineTest

  def test_factory_built_by_default
    eng = GlooLang::App::Engine.new( default_context )
    assert eng
    refute eng.factory
    eng.start
    assert eng.factory
  end

  # ---------------------------------------------------------------------
  #    Factory Helpers
  # ---------------------------------------------------------------------

  def test_create_untyped
    @engine.start
    o = @engine.factory.create_untyped( 'o', 'bla', nil )
    assert o
    assert_equal 'o', o.name
    assert_equal 'bla', o.value
    assert_equal 'untyped', o.type_display
  end

  def test_create_string
    @engine.start
    o = @engine.factory.create_string( 'o', 'bla', nil )
    assert o
    assert_equal 'o', o.name
    assert_equal 'bla', o.value
    assert_equal 'string', o.type_display
  end

  def test_create_int
    @engine.start
    o = @engine.factory.create_int( 'o', 31, nil )
    assert o
    assert_equal 'o', o.name
    assert_equal 31, o.value
    assert_equal 'integer', o.type_display
  end

  def test_create_bool
    @engine.start
    o = @engine.factory.create_bool( 'o', true, nil )
    assert o
    assert_equal 'o', o.name
    assert_equal true, o.value
    assert_equal 'boolean', o.type_display
  end

  def test_create_can
    @engine.start
    o = @engine.factory.create_can( 'o', nil )
    assert o
    assert_equal 'o', o.name
    assert_equal 'container', o.type_display
  end

  def test_create_script
    @engine.start
    o = @engine.factory.create_script( 'o', 'show 2 + 2', nil )
    assert o
    assert_equal 'o', o.name
    assert_equal 'show 2 + 2', o.value
    assert_equal 'script', o.type_display
  end

  # ---------------------------------------------------------------------
  #    Object Factory
  # ---------------------------------------------------------------------

  def test_known_object_creation
    @engine.start
    o = @engine.factory.create( { :name => 's', :type => 'string' } )
    assert o
    assert_equal 's', o.name
    assert_equal 'string', o.type_display
  end

  def test_parents
    @engine.start
    can = @engine.factory.create( { :name => 'can', :type => 'container' } )
    assert can.parent
    assert_equal @engine.heap.root, can.parent

    o = @engine.factory.create( { :name => 'can.s', :type => 'string' } )
    assert o.parent
    assert_equal can, o.parent
  end

  def test_unknown_object_creation
    @engine.start
    o = @engine.factory.create( { :name => 'x', :type => 'notatype' } )
    refute o
  end

  def test_untyped_object_creation
    @engine.start
    o = @engine.factory.create( { :name => 'u' } )
    assert o
    assert_equal 'u', o.name
    assert_equal 'untyped', o.type_display
  end

  def test_find_type
    @engine.start
    o = @engine.factory.find_type 'un'
    assert_equal GlooLang::Objs::Untyped, o
    o = @engine.factory.find_type ''
    assert_equal GlooLang::Objs::Untyped, o
    o = @engine.factory.find_type 'UNTYPED'
    assert_equal GlooLang::Objs::Untyped, o
    o = @engine.factory.find_type 'string'
    assert_equal GlooLang::Objs::String, o

    refute @engine.factory.find_type '24322343242'
    refute @engine.factory.find_type 'alajsl;j'
    refute @engine.factory.find_type 'xr2'
  end

end
