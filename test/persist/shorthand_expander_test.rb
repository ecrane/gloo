require 'test_helper'

class ShorthandExpanderTest < BaseEngineTest

  def setup
    super
    @exp = Gloo::Persist::ShorthandExpander.new( @engine )
    @root = @engine.heap.root
  end

  def test_a_plain_name_is_returned_unchanged
    leaf, parent, roots, created = @exp.expand( 'thing', @root )
    assert_equal 'thing', leaf
    assert_same @root, parent
    assert_equal [], roots
    assert_equal [], created
  end

  def test_a_dotted_name_builds_a_container_chain
    leaf, parent, roots, created = @exp.expand( 'page.core.users.list', @root )

    assert_equal 'list', leaf
    page = @root.find_child( 'page' )
    assert_equal 'container', page.type_display
    core = page.find_child( 'core' )
    users = core.find_child( 'users' )
    assert_same users, parent
    assert_equal [ page ], roots
    assert_equal [ page, core, users ], created
  end

  def test_it_reuses_an_existing_prefix_segment
    @exp.expand( 'page.core.a', @root )
    _leaf, parent, roots, created = @exp.expand( 'page.core.b', @root )

    assert_same @root.find_child( 'page' ).find_child( 'core' ), parent
    assert_equal [ @root.find_child( 'page' ) ], roots
    assert_equal [], created, 'nothing new -- the prefix was reused'
  end

  def test_a_prefix_that_is_already_another_type_is_used_as_is
    @engine.factory.create_string( 'page', 'not a container', @root )
    leaf, parent, = @exp.expand( 'page.x', @root )

    assert_equal 'x', leaf
    assert_same @root.find_child( 'page' ), parent
    assert_equal 'string', parent.type_display
  end

end
