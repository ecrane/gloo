# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A hashed password (with salt).
#
# BCrypt is used to hash the password.
#   https://www.rubydoc.info/gems/bcrypt-ruby
#   https://github.com/bcrypt-ruby/bcrypt-ruby/blob/master/lib/bcrypt/password.rb
#
require 'bcrypt'

module Gloo
  module Objs
    class Password < Gloo::Core::Obj

      KEYWORD = 'password'.freeze
      KEYWORD_SHORT = 'hash'.freeze

      SALT = 'salt'.freeze
      PASSWORD = 'password'.freeze
      HASH = 'hash'.freeze

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
      # Get the password salt.
      # Returns nil if there is none.
      #
      def salt
        return find_child_value SALT
      end

      #
      # Get the password value.
      # Returns nil if there is none.
      #
      def password
        return find_child_value PASSWORD
      end

      #
      # Update the password value.
      #
      def update_password( new_pwd )
        o = find_child_resolve_alias PASSWORD
        return unless o

        o.set_value new_pwd
      end

      #
      # Get the salted password.
      #
      def salt_pwd
        return "#{salt}#{password}"
      end

      #
      # Get the hashed password value.
      # Returns nil if there is none.
      #
      def hash
        return find_child_value HASH
      end

      #
      # Update the hashed password value.
      #
      def update_hash( new_hash )
        o = find_child_resolve_alias HASH
        return unless o

        o.set_value new_hash
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
        fac.create_string SALT, '', self
        fac.create_string PASSWORD, '', self
        fac.create_string HASH, '', self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[hash check generate]
      end

      #
      # Generate a random alphanumeric password.
      # By default the length is 7 characters.
      # Set the length with an optional parameter.
      #
      def msg_generate
        len = 7
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          len = data.to_i
        end

        s = StringGenerator.alphanumeric( len )
        update_password s
        @engine.heap.it.set_to s
        return s
      end

      #
      # Hash the password with the salt.
      # Uses the salt and the password to create a hash.
      #
      def msg_hash
        hashed_pwd = BCrypt::Password.create( salt_pwd )
        update_hash hashed_pwd
      end

      #
      # Check the password against the hash.
      # Uses the salt and the hash to check the password.
      #
      def msg_check
        hashed_pwd = BCrypt::Password.new( hash )
        result = ( hashed_pwd == salt_pwd )
        @engine.heap.it.set_to result
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
          :description => 'A password object that can be generated, hashed, and compared.',
          :children => [
            'salt (string) — Optional salt to use when hashing and checking passwords.',
            'password (string) — The password. generate puts a new random password here. Used in the hash and check messages.',
            'hash (string) — The hashed value of the password. Created when the hash message is called, and compared when the check message is called.'
          ],
          :messages => [
            'generate ({len}) — Generate a new password, put in the password child object. The {len} parameter is optional; the length is 7 if not specified.',
            'hash — Hash the password in the child object. Put it in the hash child object.',
            'check — Check the password in the child object. Is it the same as the hash?'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Password Hashing and checking.
            #
            password [can] :

              pwd [password] :
                salt [string] : MySalt
                password [string] :
                hash [string] :

              on_load [script] :
                show
                show 'Generating a new password' (white)
                tell ^.pwd to generate
                show 'Password: ' + ^.pwd.password
                show
                show 'hashing the password' (white)
                tell ^.pwd to hash
                show ^.pwd.hash (red)
                show
                show 'checking with the correct password' (white)
                tell ^.pwd to check
                show 'Result of check: ' + it (green)
                show
                show 'checking with the wrong password' (white)
                tell ^.pwd to generate(23)
                tell ^.pwd to check
                show 'Result of check: ' + it (red)
                show
          EXAMPLES
        }
      end

    end
  end
end
