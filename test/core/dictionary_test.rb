require 'test_helper'

class DictionaryTest < BaseEngineTest

  def test_dictionary_constrution
    assert @dic
  end

  def test_obj_list
    assert @dic.objs
    assert @dic.objs.count.positive?
  end

  def test_is_obj
    assert @dic.obj?( 'string' )
    refute @dic.obj?( 'XXXX' )
    refute @dic.obj?( '' )
    refute @dic.obj?( nil )
  end

  def test_find_an_obj
    assert @dic.find_obj( 'string' )
    assert @dic.find_obj( 'string' )
    refute @dic.find_obj( nil )
    refute @dic.find_obj( '' )
    refute @dic.find_obj( 'XXX' )
  end

  def test_verb_list
    assert @dic.verbs
    assert @dic.verbs.count.positive?
  end

  def test_is_verb
    assert @dic.verb?( 'quit' )
    assert @dic.verb?( 'QUIT' )
    assert @dic.verb?( 'quIT' )
    refute @dic.verb?( 'XXXX' )
    refute @dic.verb?( '' )
    refute @dic.verb?( nil )
  end

  def test_find_a_verb
    assert @dic.find_verb( 'quit' )
    assert @dic.find_verb( 'QUIT' )
    refute @dic.find_verb( nil )
    refute @dic.find_verb( '' )
    refute @dic.find_verb( 'XXX' )
  end

  def test_getting_verbs_sorted
    verbs = @dic.get_verbs
    assert verbs
    assert verbs.count > 5
  end

  def test_getting_obj_types_sorted
    objs = @dic.get_obj_types
    assert objs
    assert objs.count > 4
  end

  def test_keyword_lookup
    refute @dic.lookup_keyword( 'aaabbbccc' )
    refute @dic.lookup_keyword( 'blark' )
    refute @dic.lookup_keyword( '' )

    assert_equal 'quit', @dic.lookup_keyword( 'quit' )
    assert_equal 'quit', @dic.lookup_keyword( 'q' )
    assert_equal 'quit', @dic.lookup_keyword( 'QUIT' )

    assert_equal 'string', @dic.lookup_keyword( 'STRING' )
    assert_equal 'string', @dic.lookup_keyword( 'STR' )
    assert_equal 'string', @dic.lookup_keyword( 'str' )
  end

  def test_unregistring_and_registring_verb
    assert_equal 'show', @dic.lookup_keyword( Gloo::Verbs::Show.keyword )
    assert_equal 'show', @dic.lookup_keyword( Gloo::Verbs::Show.keyword_shortcut )

    @dic.unregister_verb( Gloo::Verbs::Show )

    refute @dic.lookup_keyword( Gloo::Verbs::Show.keyword )
    refute @dic.lookup_keyword( Gloo::Verbs::Show.keyword_shortcut )

    @dic.register_verb_post_start( Gloo::Verbs::Show, @engine )

    assert_equal 'show', @dic.lookup_keyword( Gloo::Verbs::Show.keyword )
    assert_equal 'show', @dic.lookup_keyword( Gloo::Verbs::Show.keyword_shortcut )
  end

  def test_unregistring_and_registring_obj
    assert_equal 'text', @dic.lookup_keyword( Gloo::Objs::Text.typename )
    assert_equal 'text', @dic.lookup_keyword( Gloo::Objs::Text.short_typename )

    @dic.unregister_obj( Gloo::Objs::Text )

    refute @dic.lookup_keyword( Gloo::Objs::Text.typename )
    refute @dic.lookup_keyword( Gloo::Objs::Text.short_typename )

    @dic.register_obj_post_start( Gloo::Objs::Text, @engine )

    assert_equal 'text', @dic.lookup_keyword( Gloo::Objs::Text.typename )
    assert_equal 'text', @dic.lookup_keyword( Gloo::Objs::Text.short_typename )
  end

  def test_duplicate_obj_registration_reports_error_when_engine_given
    refute @engine.error?
    @dic.register_obj_post_start( Gloo::Objs::Text, @engine )
    assert @engine.error?
  end

  def test_duplicate_verb_registration_reports_error_when_engine_given
    refute @engine.error?
    @dic.register_verb_post_start( Gloo::Verbs::Show, @engine )
    assert @engine.error?
  end

  def test_duplicate_obj_registration_does_not_raise_without_engine
    @dic.register_obj_post_start( Gloo::Objs::Text )
  end

  def test_duplicate_verb_registration_does_not_raise_without_engine
    @dic.register_verb_post_start( Gloo::Verbs::Show )
  end

  def test_verbs_are_listed_once_each
    verbs = @dic.get_verbs
    assert_equal verbs.uniq, verbs
    # Registered under both 'clear' and 'cls', but listed once.
    assert_equal 1, verbs.count( Gloo::Verbs::Cls )
  end

  def test_obj_types_are_listed_once_each
    types = @dic.get_obj_types
    assert_equal types.uniq, types
    # Registered under both 'boolean' and 'bool', but listed once.
    assert_equal 1, types.count( Gloo::Objs::Boolean )
  end

  def test_lists_are_sorted
    verbs = @dic.get_verbs.map( &:keyword )
    assert_equal verbs.sort, verbs
    types = @dic.get_obj_types.map( &:typename )
    assert_equal types.sort, types
  end

  def test_an_unregistered_verb_is_not_listed
    @dic.unregister_verb( Gloo::Verbs::Cls )
    refute_includes @dic.get_verbs, Gloo::Verbs::Cls

    @dic.register_verb_post_start( Gloo::Verbs::Cls )
    assert_includes @dic.get_verbs, Gloo::Verbs::Cls
  ensure
    # The dictionary is shared by every test: always put it back.
    @dic.register_verb_post_start( Gloo::Verbs::Cls ) unless @dic.verb?( 'clear' )
  end

  def test_an_unregistered_obj_type_is_not_listed
    @dic.unregister_obj( Gloo::Objs::Boolean )
    refute_includes @dic.get_obj_types, Gloo::Objs::Boolean

    @dic.register_obj_post_start( Gloo::Objs::Boolean )
    assert_includes @dic.get_obj_types, Gloo::Objs::Boolean
  ensure
    # The dictionary is shared by every test: always put it back.
    @dic.register_obj_post_start( Gloo::Objs::Boolean ) unless @dic.obj?( 'boolean' )
  end

end
