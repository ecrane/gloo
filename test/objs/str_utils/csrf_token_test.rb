require 'test_helper'

class CsrfTokenTest < BaseEngineTest


  def test_generation_of_a_token
    token = Gloo::Objs::CsrfToken.generate_csrf_token
    assert token
    assert token.length > Gloo::Objs::CsrfToken::TOKEN_LENGTH

    token2 = Gloo::Objs::CsrfToken.generate_csrf_token
    assert token2
    assert token2.length > Gloo::Objs::CsrfToken::TOKEN_LENGTH

    refute_equal token, token2
  end

  def test_masking_of_a_token
    token = Gloo::Objs::CsrfToken.generate_csrf_token
    masked_token = Gloo::Objs::CsrfToken.mask_token( token )
    assert masked_token
    assert masked_token.length > token.length

    unmasked_token = Gloo::Objs::CsrfToken.unmask_token( masked_token )
    assert unmasked_token
    assert_equal token, unmasked_token
  end

  def test_masking_of_a_token_twice
    token = Gloo::Objs::CsrfToken.generate_csrf_token
    masked_token = Gloo::Objs::CsrfToken.mask_token( token )
    assert masked_token
    assert masked_token.length > token.length

    masked_token2 = Gloo::Objs::CsrfToken.mask_token( token )
    assert masked_token2
    assert masked_token2.length > token.length

    refute_equal masked_token, masked_token2

    unmasked_token = Gloo::Objs::CsrfToken.unmask_token( masked_token )
    assert unmasked_token
    assert_equal token, unmasked_token

    unmasked_token2 = Gloo::Objs::CsrfToken.unmask_token( masked_token2 )
    assert unmasked_token2
    assert_equal token, unmasked_token2
  end

  def test_comparison_of_two_tokens
    token1 = Gloo::Objs::CsrfToken.generate_csrf_token
    token2 = Gloo::Objs::CsrfToken.generate_csrf_token
    assert token1
    assert token2
    assert token1.length > Gloo::Objs::CsrfToken::TOKEN_LENGTH
    assert token2.length > Gloo::Objs::CsrfToken::TOKEN_LENGTH

    assert_equal Gloo::Objs::CsrfToken.compare_tokens( token1, token1 ), true
    assert_equal Gloo::Objs::CsrfToken.compare_tokens( token1, token2 ), false
  end

  def test_get_csrf_token_hidden_field
    token = Gloo::Objs::CsrfToken.generate_csrf_token
    assert token
    assert token.length > Gloo::Objs::CsrfToken::TOKEN_LENGTH

    hidden_field = Gloo::Objs::CsrfToken.get_csrf_token_hidden_field( token )
    assert hidden_field
    assert hidden_field.length > token.length
    assert hidden_field.start_with?( "<input type='hidden' name='authenticity_token' value='" ) 
    assert hidden_field.end_with?( "' />" )
  end

  def test_validate_csrf_token
    token = Gloo::Objs::CsrfToken.generate_csrf_token
    assert token
    refute Gloo::Objs::CsrfToken.valid_csrf_token?( token, token )

    masked_token = Gloo::Objs::CsrfToken.mask_token( token )
    assert masked_token
    assert masked_token.length > token.length
    assert Gloo::Objs::CsrfToken.valid_csrf_token?( token, masked_token )

    masked_token2 = Gloo::Objs::CsrfToken.mask_token( token )
    assert masked_token2
    assert masked_token2.length > token.length
    refute_equal masked_token, masked_token2
    assert Gloo::Objs::CsrfToken.valid_csrf_token?( token, masked_token2 )

    refute Gloo::Objs::CsrfToken.valid_csrf_token?( token, nil )
    refute Gloo::Objs::CsrfToken.valid_csrf_token?( token, '' )
    refute Gloo::Objs::CsrfToken.valid_csrf_token?( nil, masked_token )
    refute Gloo::Objs::CsrfToken.valid_csrf_token?( '', masked_token )
  end

end
