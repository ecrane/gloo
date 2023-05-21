# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Application information such as Version and public name.
#

# require 'gloo-lang'

module Gloo
  module App
    class Info

      #
      # Load the version from the VERSION file.
      #
      def self.get_version
        f = File.dirname( File.absolute_path( __FILE__ ) )
        f = File.dirname( File.dirname( f ) )
        f = File.join( f, 'VERSION' )
        return File.read( f )
      end

      VERSION = Gloo::App::Info.get_version
      APP_NAME = 'Gloo'.freeze

      #
      # Get the application display title.
      #
      def self.display_title
        return "#{APP_NAME}, version #{VERSION}"
      end


      #
      # Get the full application version information,
      # including engine version.
      #
      def self.full_version
        return "#{display_title}\n#{ruby_info}"
        return str
      end

      # 
      # Get the version of Ruby.
      # 
      def self.ruby_info
        return "Ruby version: #{RUBY_VERSION}"
      end

    end
  end
end