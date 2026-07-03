# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Utilities related to words (strings).
#

require 'active_support/inflector'

module Gloo
  module Utils
    class Words

      # 
      # Return the plural form of the given word.
      # 
      # @param word [String] the word to pluralize
      # @return [String] the plural form of the word
      def self.pluralize( word )
        return word.pluralize
      end

    end
  end
end
