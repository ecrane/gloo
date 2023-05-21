# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Application information such as Version and public name.
#

module GlooLang
  module App
    class Info

      #
      # Register other Info classes when they are loaded.
      #
      def self.inherited( subclass )
        $infos = [] unless $infos
        $infos << subclass
      end

      #
      # Load the version from the VERSION file.
      #
      def self.get_version
        f = File.dirname( File.absolute_path( __FILE__ ) )
        f = File.dirname( File.dirname( f ) )
        f = File.join( f, 'VERSION' )
        return File.read( f )
      end

      VERSION = GlooLang::App::Info.get_version
      APP_NAME = 'Gloo Engine'.freeze

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
        str = "#{display_title}"
        if $infos
          $infos.each do |o|
            str << "\n#{o.display_title}"
          end
        end
        return str
      end

    end

    #
    # Add the ruby version information.
    #
    class RubyInfo < Info

      def self.display_title
        return "Ruby version: #{RUBY_VERSION}"
      end

    end

  end
end
