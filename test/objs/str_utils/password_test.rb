require 'test_helper'

class PasswordTest < BaseEngineTest

  def test_the_typename
    assert_equal 'password', Gloo::Objs::Password.typename
  end

  def test_the_short_typename
    assert_equal 'hash', Gloo::Objs::Password.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Password.doc_data
    assert_equal Gloo::Objs::Password.typename, data[:name]
    assert_equal Gloo::Objs::Password.short_typename, data[:shortcut]
  end

  def test_messages
    msgs = Gloo::Objs::Password.messages
    assert msgs
    assert msgs.include?( 'hash' )
    assert msgs.include?( 'check' )
    assert msgs.include?( 'generate' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Password.new( @engine )
    assert o.add_children_on_create?
  end

  def test_creating_with_children
    i = @engine.parser.parse_immediate 'create p as password'
    i.run
    assert_equal 1, @engine.heap.root.child_count

    p = @engine.heap.root.children.first
    assert p
    assert_equal 3, p.child_count

    salt = p.children.first
    pwd = p.children.second
    hash = p.children.last

    assert_equal 'salt', salt.name
    assert_equal 'password', pwd.name
    assert_equal 'hash', hash.name
  end

  def test_generating_a_password
    i = @engine.parser.parse_immediate 'create p as password'
    i.run
    p = @engine.heap.root.children.first
    pwd = p.children.second
    assert pwd.value.blank?

    i = @engine.parser.parse_immediate 'tell p to generate'
    i.run
    refute pwd.value.blank?
  end

  def test_hashing_a_password
    i = @engine.parser.parse_immediate 'create p as password'
    i.run
    p = @engine.heap.root.children.first
    hash = p.children.last
    assert hash.value.blank?

    i = @engine.parser.parse_immediate 'tell p to generate'
    i.run
    i = @engine.parser.parse_immediate 'tell p to hash'
    i.run
    refute hash.value.blank?
  end

  def test_checking_a_correct_password
    i = @engine.parser.parse_immediate 'create p as password'
    i.run
    p = @engine.heap.root.children.first
    hash = p.children.last
    assert hash.value.blank?

    i = @engine.parser.parse_immediate 'tell p to generate'
    i.run
    i = @engine.parser.parse_immediate 'tell p to hash'
    i.run
    i = @engine.parser.parse_immediate 'tell p to check'
    i.run
    assert @engine.heap.it.value
  end

  def test_checking_an_incorrect_password
    i = @engine.parser.parse_immediate 'create p as password'
    i.run
    p = @engine.heap.root.children.first
    hash = p.children.last
    assert hash.value.blank?

    i = @engine.parser.parse_immediate 'tell p to generate'
    i.run
    i = @engine.parser.parse_immediate 'tell p to hash'
    i.run
    i = @engine.parser.parse_immediate 'tell p to generate'
    i.run
    i = @engine.parser.parse_immediate 'tell p to check'
    i.run
    refute @engine.heap.it.value
  end

end
