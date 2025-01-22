# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2025 Eric Crane.  All rights reserved.
#
# Helper class to generate and verify a csrf token.
#
require 'securerandom'
require 'base64'
require 'active_support/security_utils'

module Gloo
  module Objs
    class CsrfToken

      TOKEN_LENGTH = 32
      AUTHENTICITY_TOKEN = 'authenticity_token'.freeze

      # 
      # Generate a random token
      #
      def self.generate_csrf_token
        SecureRandom.base64( TOKEN_LENGTH ) 
      end

      # 
      # Generate a masked token.
      #
      def self.mask_token( base_token )
        one_time_pad = SecureRandom.random_bytes( base_token.bytesize )
        masked_token = one_time_pad.bytes.zip( base_token.bytes ).map { |a, b| a ^ b }.pack('C*')
        return Base64.urlsafe_encode64( one_time_pad + masked_token ) # Encode the result
      end

      # 
      # Unmask a masked token.
      #
      def self.unmask_token( masked_token )
        decoded = Base64.urlsafe_decode64( masked_token )
        one_time_pad, masked_token = decoded[0...decoded.length / 2], decoded[decoded.length / 2..]
        return one_time_pad.bytes.zip( masked_token.bytes ).map { |a, b| (a ^ b).chr }.join
      end

      # 
      # Compare two tokens.
      # Use ActiveSupport::SecurityUtils.secure_compare to avoid timing attacks.
      #
      def self.compare_tokens( token1, token2 )
        return ActiveSupport::SecurityUtils.secure_compare( token1, token2 )
      end

      # 
      # Return a hidden field with the masked csrf token.
      #
      def self.get_csrf_token_hidden_field( base_token )
        form_token = mask_token( base_token )
   
        return "<input type='hidden' name='#{AUTHENTICITY_TOKEN}' value='#{form_token}' />"
      end

      # 
      # Validate a masked csrf token that came from a form submit.
      #
      def self.valid_csrf_token?( base_token, masked_token )
        return false unless base_token && masked_token

        unmasked_token = unmask_token( masked_token )

        return compare_tokens( base_token, unmasked_token )
      end

    end
  end
end