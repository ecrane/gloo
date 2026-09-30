require 'test_helper'

class DateTest < BaseEngineTest

  def test_the_typename
    assert_equal 'date', Gloo::Objs::Date.typename
  end

  def test_the_short_typename
    assert_equal 'date', Gloo::Objs::Date.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Date.doc_data
    assert_equal Gloo::Objs::Date.typename, data[:name]
    assert_equal Gloo::Objs::Date.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'DAte' )
  end

  def test_messages
    msgs = Gloo::Objs::Date.messages
    assert msgs
    assert msgs.include?( 'now' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Date.new @engine
    refute o.add_children_on_create?
  end

  def test_now
    i = @engine.parser.parse_immediate 'create d as date'
    i.run
    t = @engine.heap.root.children.first
    assert t
    refute t.value

    i = @engine.parser.parse_immediate 'tell d to now'
    i.run
    refute_equal '', t.value
  end

  def test_setting_from_string
    i = @engine.parser.parse_immediate 'create d as date'
    i.run
    d = @engine.heap.root.children.first
    i = @engine.parser.parse_immediate "put 'tomorrow' into d"
    i.run

    refute_equal 'tomorrow', d.value
  end

  def test_put_dt_into_d
    i = @engine.parser.parse_immediate 'create d as date'
    i.run
    d = @engine.heap.root.children.first
    i = @engine.parser.parse_immediate 'create dt as datetime'
    i.run
    dt = @engine.heap.root.children.last

    i = @engine.parser.parse_immediate "put '1/13/1969' into dt"
    i.run
    assert dt.value
    refute d.value
    i = @engine.parser.parse_immediate "put dt into d"
    i.run
    assert d.value

    assert dt.value.start_with?( d.value )
  end

  def test_format
    i = @engine.parser.parse_immediate 'create d as date'
    i.run
    d = @engine.heap.root.children.first
    i = @engine.parser.parse_immediate "put '2025.10.15' into d"
    i.run

    i = @engine.parser.parse_immediate 'tell d to format'
    i.run
    assert_equal '2025-10-15', @engine.heap.it.value
  end

  def test_mm_of_a_value_that_is_not_a_date_is_an_error
    @engine.heap.it.set_to 'before'
    @engine.parser.run "create d as date : 'garbage'"
    @engine.parser.run 'tell d to mm'
    assert @engine.error?
    assert_includes @engine.heap.error.value.to_s, 'There is no date to work with!'
    assert_equal false, @engine.heap.it.value
  end

  def test_add_with_a_bad_unit_is_an_error
    @engine.heap.it.set_to 'before'
    @engine.parser.run "create d as date : '2026-01-01'"
    @engine.parser.run "tell d to add ( '3 dayz' )"
    assert @engine.error?
    assert_includes @engine.heap.error.value.to_s, "'3 dayz' is not an amount like '1 day' or '3 months'."
    assert_equal false, @engine.heap.it.value
  end

  def test_add_a_bare_number_is_days_with_a_warning
    @engine.parser.run "create d as date : '2026-01-01'"
    warnings = capture_warnings { @engine.parser.run 'tell d to add ( 3 )' }
    assert_includes warnings.first, "'3' has no unit; using 3 days."
    assert_equal '2026.01.04', @engine.heap.it.value
    refute @engine.error?
  end

  def test_add_with_a_unit_does_not_warn
    @engine.parser.run "create d as date : '2026-01-01'"
    warnings = capture_warnings { @engine.parser.run "tell d to add ( '2 Weeks' )" }
    assert_empty warnings
    assert_equal '2026.01.15', @engine.heap.it.value
  end

end
