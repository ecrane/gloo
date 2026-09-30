require 'test_helper'

class ContainerTest < BaseEngineTest

  def test_the_typename
    assert_equal 'container', Gloo::Objs::Container.typename
  end

  def test_the_short_typename
    assert_equal 'can', Gloo::Objs::Container.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Container.doc_data
    assert_equal Gloo::Objs::Container.typename, data[:name]
    assert_equal Gloo::Objs::Container.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'container' )
    assert @dic.find_obj( 'CONTAINER' )
    assert @dic.find_obj( 'can' )
    assert @dic.find_obj( 'CAN' )
  end

  def test_messages
    msgs = Gloo::Objs::Container.messages
    assert msgs
    assert msgs.include?( 'count' )
    assert msgs.include?( 'delete_children' )
    assert msgs.include?( 'unload' )
    assert msgs.include?( 'show_key_value_table' )
  end

  def test_count_msg
    o = Gloo::Objs::Container.new @engine
    assert_equal 0, o.msg_count
    o.add_child o
    assert_equal 1, o.msg_count
  end

  def test_doesnt_add_children_on_create
    o = Gloo::Objs::Container.new @engine
    refute o.add_children_on_create?
  end

  def test_running_evaluated_string
    s = 'create c as can'
    @engine.parser.parse_immediate( s ).run
    can = @engine.heap.root.children.first

    s = 'create c.x as int'
    @engine.parser.parse_immediate( s ).run
    s = 'create c.y as int'
    @engine.parser.parse_immediate( s ).run
    s = 'create c.z as int'
    @engine.parser.parse_immediate( s ).run

    assert_equal 3, can.child_count

    s = 'tell c to delete_children'
    @engine.parser.parse_immediate( s ).run
    assert_equal 0, can.child_count
  end

  def test_child_exists_msg
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.x as int'
    @engine.parser.run "check c for child_exists ('x')"
    assert @engine.heap.it.value

    @engine.parser.run "check c for child_exists ('z')"
    refute @engine.heap.it.value
  end

  def test_child_exists_with_a_number
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.3 as int'
    @engine.parser.run 'create i as int : 3'
    @engine.parser.run 'check c for child_exists ( i )'
    assert @engine.heap.it.value
    refute @engine.error?
  end

  def test_that_it_is_a_container
    o = Gloo::Objs::Container.new @engine
    assert o.is_container?
  end

  # ---------------------------------------------------------------------
  #    Child value and path messages
  # ---------------------------------------------------------------------

  #
  # A container with two simple children and a container child.
  #
  def make_list
    @engine.parser.run 'create c as can'
    @engine.parser.run "create c.x as string : 'ex'"
    @engine.parser.run 'create c.y as int : 7'
    @engine.parser.run 'create c.z as can'
    @engine.parser.run "create c.z.title as string : 'zed'"
  end

  def run_it( cmd )
    @engine.parser.run cmd
    return @engine.heap.it.value
  end

  def test_child_value_at
    make_list
    assert_equal 'ex', run_it( 'tell c to child_value_at (0)' )
    assert_equal 7, run_it( 'tell c to child_value_at (1)' )
    refute @engine.error?
  end

  def test_child_value_at_takes_a_numeric_string
    make_list
    assert_equal 7, run_it( "tell c to child_value_at ('1')" )
  end

  def test_child_value_at_container_child_is_an_error
    make_list
    assert_equal false, run_it( 'tell c to child_value_at (2)' )
    assert @engine.error?
  end

  def test_child_value_at_resolves_an_alias_child
    make_list
    @engine.parser.run "create c.p as alias : 'c.x'"
    assert_equal 'ex', run_it( 'tell c to child_value_at (3)' )
  end

  def test_child_path_at
    make_list
    assert_equal 'c.x', run_it( 'tell c to child_path_at (0)' )
    assert_equal 'c.z', run_it( 'tell c to child_path_at (2)' )
    refute @engine.error?
  end

  def test_child_path_at_into_alias_reaches_fields
    make_list
    @engine.parser.run 'create ptr as alias'
    @engine.parser.run 'create result as string'
    @engine.parser.run 'tell c to child_path_at (2)'
    @engine.parser.run 'put it into ptr*'
    @engine.parser.run 'put ptr.title into result'
    assert_equal 'zed', @engine.heap.root.find_child( 'result' ).value
  end

  def test_child_at_out_of_range
    make_list
    assert_equal false, run_it( 'tell c to child_value_at (3)' )
    assert @engine.error?
  end

  def test_child_at_negative_is_out_of_range
    make_list
    assert_equal false, run_it( 'tell c to child_path_at (-1)' )
    assert @engine.error?
  end

  def test_child_at_non_numeric_is_an_error
    make_list
    assert_equal false, run_it( "tell c to child_path_at ('abc')" )
    assert @engine.error?
  end

  def test_child_at_missing_index_is_a_syntax_error
    make_list
    assert_equal false, run_it( 'tell c to child_value_at' )
    assert @engine.error?
  end

  def test_random_child_path
    make_list
    20.times do
      assert_includes [ 'c.x', 'c.y', 'c.z' ], run_it( 'tell c to random_child_path' )
    end
    refute @engine.error?
  end

  def test_random_child_value
    @engine.parser.run 'create c as can'
    @engine.parser.run "create c.x as string : 'ex'"
    @engine.parser.run "create c.y as string : 'why'"
    20.times do
      assert_includes [ 'ex', 'why' ], run_it( 'tell c to random_child_value' )
    end
    refute @engine.error?
  end

  def test_random_child_empty_is_an_error
    @engine.parser.run 'create c as can'
    assert_equal false, run_it( 'tell c to random_child_path' )
    assert @engine.error?
  end

  def test_random_child_value_on_empty_is_an_error
    @engine.parser.run 'create c as can'
    assert_equal false, run_it( 'tell c to random_child_value' )
    assert @engine.error?
  end

  def test_new_messages_listed
    msgs = Gloo::Objs::Container.messages
    %w[child_value_at child_path_at random_child_value random_child_path].each do |m|
      assert_includes msgs, m
    end
  end

  def test_child_exists_with_no_name_is_a_syntax_error
    @engine.parser.run 'create c as can'
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'check c for child_exists'
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

end
