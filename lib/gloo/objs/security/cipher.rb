# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A object to encrypt and decrypt text.
#
require 'openssl'
require 'base64'

module Gloo
  module Objs
    class Cipher < Gloo::Core::Obj

      KEYWORD = 'cipher'.freeze
      KEYWORD_SHORT = 'crypt'.freeze

      CIPHER_TYPE = 'AES-256-CBC'.freeze
      KEY = 'key'.freeze
      INIT_VECTOR = 'init_vector'.freeze
      DECRYPTED = 'decrypted'.freeze
      ENCRYPTED = 'encrypted'.freeze

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      #
      # Get the Cipher Key.
      # Returns nil if there is none.
      #
      def key
        o = find_child KEY
        return o&.value
      end

      #
      # Get the Initialization Vector.
      # Returns nil if there is none.
      #
      def init_vector
        o = find_child INIT_VECTOR
        return o&.value
      end

      #
      # Get the value of the decrypted message.
      #
      def decrypted_message
        o = find_child DECRYPTED
        return o&.value
      end

      #
      # Get the value of the encrypted message.
      #
      def encrypted_message
        o = find_child ENCRYPTED
        return o&.value
      end

      #
      # Update the key value.
      #
      def update_key( new_val )
        o = find_child KEY
        return unless o

        o.set_value new_val
      end

      #
      # Update the initialization vector value.
      #
      def update_init_vector( new_val )
        o = find_child INIT_VECTOR
        return unless o

        o.set_value new_val
      end

      #
      # Update the decrypted value.
      #
      def update_decrypted( new_val )
        o = find_child DECRYPTED
        return unless o

        o.set_value new_val
      end

      #
      # Update the encrypted value.
      #
      def update_encrypted( new_val )
        o = find_child ENCRYPTED
        return unless o

        o.set_value new_val
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      #
      def add_children_on_create?
        return true
      end

      #
      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      #
      def add_default_children
        fac = @engine.factory
        fac.create_string KEY, '', self
        fac.create_string INIT_VECTOR, '', self
        fac.create_string DECRYPTED, '', self
        fac.create_string ENCRYPTED, '', self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[generate_keys encrypt decrypt]
      end

      #
      # Generate random Key and Initialization Vector.
      #
      def msg_generate_keys
        cipher = OpenSSL::Cipher.new( CIPHER_TYPE )

        key = cipher.random_key
        key = Base64.encode64 key
        update_key key

        iv = update_init_vector cipher.random_iv
        iv = Base64.encode64 iv
        update_init_vector iv
      end

      #
      # Decrypt the encrypted child object.
      #
      def msg_decrypt
        update_decrypted Cipher.decrypt( encrypted_message, key, init_vector )
      end

      #
      # Encrypt the decrypted child object.
      #
      def msg_encrypt
        update_encrypted Cipher.encrypt( decrypted_message, key, init_vector )
      end

      # ---------------------------------------------------------------------
      #    Static Methods
      # ---------------------------------------------------------------------

      # 
      # Encrypt the data using the key and initialization vector.
      # Returns the encrypted data (base64 encoded).
      # 
      def self.encrypt( data, key, iv )
        cipher = OpenSSL::Cipher.new( CIPHER_TYPE )
        cipher.encrypt
        cipher.key = Base64.decode64( key )
        cipher.iv = Base64.decode64( iv ) unless iv.blank?

        encrypted_msg = cipher.update( data ) + cipher.final
        return Base64.encode64( encrypted_msg )
      end

      # 
      # Decrypt the data using the key and initialization vector.
      # Returns the decrypted data.
      #
      def self.decrypt( data, key, iv )
        cipher = OpenSSL::Cipher.new( CIPHER_TYPE )
        data = Base64.decode64( data )
        cipher.decrypt
        cipher.key = Base64.decode64( key )
        cipher.iv = Base64.decode64( iv ) unless iv.blank?

        return cipher.update( data ) + cipher.final
      end

    end
  end
end
