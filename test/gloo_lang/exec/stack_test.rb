require 'test_helper'

class StackTest < BaseEngineTest

  def test_debug_file
    o = GlooLang::Exec::Stack.new( @engine, 'test' )
    assert o
    assert o.out_file.start_with? @engine.settings.debug_path
    assert o.out_file.end_with? 'test'
  end

  def test_pushing_poping
    o = GlooLang::Exec::Stack.new( @engine, 'test' )
    assert o
    assert_equal 0, o.size

    o.push GlooLang::Verbs::Run.new( @engine, nil )
    assert_equal 1, o.size
    o.pop
    assert_equal 0, o.size
  end

  def test_getting_out_data
    o = GlooLang::Exec::Stack.new @engine, 'test'
    assert_equal '', o.out_data

    o.push GlooLang::Verbs::Run.new( @engine, nil )
    assert_equal 'run', o.out_data
  end

end
