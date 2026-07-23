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
      DATA = 'data'.freeze

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
        return find_child_value KEY
      end

      #
      # Get the Initialization Vector.
      # Returns nil if there is none.
      #
      def init_vector
        return find_child_value INIT_VECTOR
      end

      #
      # Get the data value of the object.
      # This might be encrypted or decrypted based on
      # what action was last taken.
      #
      def data
        return find_child_value DATA
      end

      #
      # Update the key value.
      #
      def update_key( new_val )
        o = find_child_resolve_alias KEY
        return unless o

        o.set_value new_val
      end

      #
      # Update the initialization vector value.
      #
      def update_init_vector( new_val )
        o = find_child_resolve_alias INIT_VECTOR
        return unless o

        o.set_value new_val
      end

      #
      # Update the data value of the object.
      #
      def update_data( new_val )
        o = find_child_resolve_alias DATA
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
        fac.create_string DATA, '', self
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

        iv = cipher.random_iv
        iv = Base64.encode64 iv
        update_init_vector iv
      end

      #
      # Decrypt the encrypted child object.
      #
      def msg_decrypt
        update_data Cipher.decrypt( data, key, init_vector )
      end

      #
      # Encrypt the decrypted child object.
      #
      def msg_encrypt
        update_data Cipher.encrypt( data, key, init_vector )
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

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Tool to encrypt and decrypt data.',
          :children => [
            'key (string) — The encryption key. Base64 encoded.',
            'init_vector (string) — The initialization vector. Base64 encoded.',
            'data (string) — The encrypted or decrypted data.'
          ],
          :messages => [
            'generate_keys — Generate an encryption key and initialization vector. The keys are base64 encoded.',
            'encrypt — Encrypt the data.',
            'decrypt — Decrypt the data.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Encrypt and Decrypt a string.
            #

            encrypt [can] :

              str [string] : Encrypt your data for better security!

              cipher [cipher] :
                key [string] :
                init_vector [string] :
                data [string] :

              on_load [script] :
                show
                show 'Original string' (white)
                show ^.str
                show
                show 'Generating Key' (white)
                tell ^.cipher to generate_keys
                show ^.cipher.key
                show ^.cipher.init_vector
                show
                show 'Encrpting the string' (white)
                put ^.str into ^.cipher.data
                tell ^.cipher to encrypt
                show ^.cipher.data
                show
                show 'Decrypting the string' (white)
                tell ^.cipher to decrypt
                show ^.cipher.data
                show
          EXAMPLES
        }
      end

    end
  end
end
