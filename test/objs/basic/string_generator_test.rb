require 'test_helper'

class StringGeneratorTest < BaseEngineTest

  def test_generating_uuid
    a = Gloo::Objs::StringGenerator.uuid
    assert a
    assert_equal 36, a.length

    b = Gloo::Objs::StringGenerator.uuid
    assert b
    assert_equal 36, b.length

    c = Gloo::Objs::StringGenerator.uuid
    assert c
    assert_equal 36, c.length

    refute_equal a, b
    refute_equal a, c
    refute_equal b, c
  end

  def test_generating_alphanumeric
    a = Gloo::Objs::StringGenerator.alphanumeric
    assert a
    assert_equal 10, a.length

    b = Gloo::Objs::StringGenerator.alphanumeric
    assert b
    assert_equal 10, b.length

    c = Gloo::Objs::StringGenerator.alphanumeric
    assert c
    assert_equal 10, c.length

    refute_equal a, b
    refute_equal a, c
    refute_equal b, c
  end

  def test_generating_alphanumeric_var_length
    a = Gloo::Objs::StringGenerator.alphanumeric( 13 )
    assert a
    assert_equal 13, a.length

    b = Gloo::Objs::StringGenerator.alphanumeric( 20 )
    assert b
    assert_equal 20, b.length

    c = Gloo::Objs::StringGenerator.alphanumeric( 3 )
    assert c
    assert_equal 3, c.length
  end

  def test_generating_hex_strings
    a = Gloo::Objs::StringGenerator.hex
    assert a

    b = Gloo::Objs::StringGenerator.hex
    assert b

    c = Gloo::Objs::StringGenerator.hex
    assert c

    refute_equal a, b
    refute_equal a, c
    refute_equal b, c
  end

  def test_generating_base64_strings
    a = Gloo::Objs::StringGenerator.base64
    assert a

    b = Gloo::Objs::StringGenerator.base64
    assert b

    c = Gloo::Objs::StringGenerator.base64
    assert c

    refute_equal a, b
    refute_equal a, c
    refute_equal b, c
  end

end
