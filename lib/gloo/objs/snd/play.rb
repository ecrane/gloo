# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Play an audio file (MP3).
#

module Gloo
  module Objs
    class Play < Gloo::Core::Obj

      KEYWORD = 'play'.freeze
      KEYWORD_SHORT = 'play'.freeze

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

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'run' ]
      end

      #
      # Play the audio file.
      #
      def msg_run
        system "afplay #{value}"
      end

    end
  end
end
