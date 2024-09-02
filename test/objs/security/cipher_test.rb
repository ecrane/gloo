require 'test_helper'

class CipherTest < BaseEngineTest

  def test_the_typename
    assert_equal 'cipher', Gloo::Objs::Cipher.typename
  end

  def test_the_short_typename
    assert_equal 'crypt', Gloo::Objs::Cipher.short_typename
  end

  def test_messages
    msgs = Gloo::Objs::Cipher.messages
    assert msgs
    assert msgs.include?( 'generate_keys' )
    assert msgs.include?( 'encrypt' )
    assert msgs.include?( 'decrypt' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Cipher.new( @engine )
    assert o.add_children_on_create?
  end

  def test_creating_with_chilren
    i = @engine.parser.parse_immediate 'create o as cipher'
    i.run
    assert_equal 1, @engine.heap.root.child_count

    o = @engine.heap.root.children.first
    assert o
    assert_equal 4, o.child_count

    key = o.children.first
    iv = o.children.second
    dec_data = o.children.third
    enc_data = o.children.last

    assert_equal 'key', key.name
    assert_equal 'init_vector', iv.name
    assert_equal 'decrypted', dec_data.name
    assert_equal 'encrypted', enc_data.name
  end

  def test_generating_keys
    i = @engine.parser.parse_immediate 'create o as cipher'
    i.run
    o = @engine.heap.root.children.first
    key = o.children.first
    iv = o.children.second
    assert key.value.blank?
    assert iv.value.blank?

    i = @engine.parser.parse_immediate 'tell o to generate_keys'
    i.run
    refute key.value.blank?
    refute iv.value.blank?
  end

  def test_encrypting
    str = 'hello to the encrypted world'
    i = @engine.parser.parse_immediate 'create o as cipher'
    i.run
    o = @engine.heap.root.children.first
    key = o.children.first
    iv = o.children.second
    dec_data = o.children.third
    dec_data.value = str
    enc_data = o.children.last

    i = @engine.parser.parse_immediate 'tell o to generate_keys'
    i.run

    assert enc_data.value.blank?
    i = @engine.parser.parse_immediate 'tell o to encrypt'
    i.run
    refute enc_data.value.blank?

    dec_data.value = ''
    assert dec_data.value.blank?
    i = @engine.parser.parse_immediate 'tell o to decrypt'
    i.run
    refute dec_data.value.blank?
    assert_equal str, dec_data.value
  end

end
