require 'test_helper'

class CipherTest < BaseEngineTest

  def test_the_typename
    assert_equal 'cipher', Gloo::Objs::Cipher.typename
  end

  def test_the_short_typename
    assert_equal 'crypt', Gloo::Objs::Cipher.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Cipher.doc_data
    assert_equal Gloo::Objs::Cipher.typename, data[:name]
    assert_equal Gloo::Objs::Cipher.short_typename, data[:shortcut]
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

  def test_creating_with_children
    i = @engine.parser.parse_immediate 'create o as cipher'
    i.run
    assert_equal 1, @engine.heap.root.child_count

    o = @engine.heap.root.children.first
    assert o
    assert_equal 3, o.child_count

    key = o.children.first
    iv = o.children.second
    data = o.children.last

    assert_equal 'key', key.name
    assert_equal 'init_vector', iv.name
    assert_equal 'data', data.name
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
    data = o.children.last
    data.value = str

    i = @engine.parser.parse_immediate 'tell o to generate_keys'
    i.run

    assert_equal str, data.value
    i = @engine.parser.parse_immediate 'tell o to encrypt'
    i.run
    refute_equal str, data.value

    i = @engine.parser.parse_immediate 'tell o to decrypt'
    i.run
    assert_equal str, data.value
  end

  def test_encrypt_and_decrypt_set_it
    str = 'hello to the encrypted world'
    @engine.parser.run 'create o as cipher'
    data = @engine.heap.root.children.first.children.last
    data.value = str
    @engine.parser.run 'tell o to generate_keys'

    @engine.parser.run 'tell o to encrypt'
    refute_equal str, @engine.heap.it.value
    assert_equal data.value, @engine.heap.it.value

    @engine.parser.run 'tell o to decrypt'
    assert_equal str, @engine.heap.it.value
  end

  def test_encrypt_with_a_bad_key_is_an_error
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'create c as cipher'
    @engine.parser.run "put 'abc' into c.key"
    @engine.parser.run "put 'hello' into c.data"
    @engine.parser.run 'tell c to encrypt'
    assert @engine.error?
    assert_includes @engine.heap.error.value.to_s, 'Could not encrypt c: key must be 32 bytes'
    assert_equal false, @engine.heap.it.value
  end

  def test_decrypt_with_the_wrong_key_is_an_error
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'create c as cipher'
    @engine.parser.run "put 'hello' into c.data"
    @engine.parser.run 'tell c to generate_keys'
    @engine.parser.run 'tell c to encrypt'
    @engine.parser.run 'tell c to generate_keys'
    @engine.parser.run 'tell c to decrypt'
    assert @engine.error?
    assert_includes @engine.heap.error.value.to_s, 'Could not decrypt c:'
    assert_equal false, @engine.heap.it.value
  end

end
