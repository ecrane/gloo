# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Show the help information.
#

module Gloo
  module Verbs
    class Help < Gloo::Core::Verb

      KEYWORD = 'help'.freeze
      KEYWORD_SHORT = '?'.freeze
      DEFAULT_HELP = 'default_help'.freeze
      HELP_NOT_FOUND_ERR = 'Help command could not be found:'.freeze

      DISPATCH = {
        s: 'show_settings',
        settings: 'show_settings',
        verb: 'show_verbs',
        verbs: 'show_verbs',
        v: 'show_verbs',
        o: 'show_objs',
        obj: 'show_objs',
        object: 'show_objs',
        objects: 'show_objs',
        e: 'show_ext',
        ext: 'show_ext',
        extension: 'show_ext',
        extensions: 'show_ext'
      }.freeze

      #
      # Run the verb.
      #
      def run
        opts = @tokens.second if @tokens
        opts = opts.strip.downcase if opts

        if opts
          dispatch opts
        else
          show_default_help
        end
      end

      #
      # Get the Verb's keyword.
      #
      def self.keyword
        return KEYWORD
      end

      #
      # Get the Verb's keyword shortcut.
      #
      def self.keyword_shortcut
        return KEYWORD_SHORT
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Write output to it and show it unless we are in
      # silent mode.
      #
      def show_output( out )
        @engine.heap.it.set_to out
        puts out unless @engine.args.quiet?
      end

      #
      # Show application settings.
      #
      def show_settings
        @engine.settings.show
      end

      #
      # Show all keywords: verbs and objects.
      #
      def show_keywords
        @engine.dictionary.show_keywords
      end

      # 
      # Show default help.
      # No parameters were given.
      # 
      def show_default_help
        data = "\n"
        data << " Help Options:\n"
        data << "   ? objects (obj, o) \n"
        data << "   ? verbs (v) \n"
        data << "   ? ext (e) \n"
        data << "   ? settings (s) \n"
        data << "\n For detailed documentation use the gloo website. \n"
        data << "\n     https://gloo.ecrane.us/doc/. \n\n"
        @engine.log.show data
      end

      #
      # Dispatch the help to the right place.
      #
      def dispatch( opts )
      #   return if dispatch_help_page( opts )

        @engine.log.debug 'looking for help topic'
        cmd = DISPATCH[ opts.to_sym ]
        if cmd
          @engine.log.debug 'found help command'
          send cmd
        else
          report_help_error opts
        end
      end

      #
      # Show application settings.
      #
      def show_settings
        @engine.settings.show
      end

      #
      # Report an error with the inline help.
      #
      def report_help_error( opts )
        @engine.err "#{HELP_NOT_FOUND_ERR} '#{opts}'"
      end

      #
      # List the verbs
      #
      def show_verbs
        data = "\n"
        data << " Verbs (shortcut, name)\n".blue
        data << "#{get_verbs}\n\n"
        @engine.log.show data
      end

      #
      # List the object types
      #
      def show_objs
        data = "\n"
        data << " Objects \n".blue
        data << "#{get_objects}\n\n"
        @engine.log.show data
      end

      #
      # Get the text for the list of verbs.
      #
      def get_verbs
        str = ''
        verbs = @engine.dictionary.get_verbs.sort_by( &:keyword )
        verbs.each_with_index do |v, i|
          cut = v.keyword_shortcut.ljust( 5, ' ' ).yellow
          name = v.keyword.ljust( 20, ' ' ).white
          str << "   #{cut}  #{name} \n"
        end

        return str
      end

      #
      # Get the text for the list of objects.
      #
      def get_objects
        str = ''
        objs = @engine.dictionary.get_obj_types.sort_by( &:typename )
        objs.each_with_index do |o, i|          
          if o.short_typename != o.typename
            short = "(#{o.short_typename})".yellow
            name = "#{o.typename.white}  #{short}"
          else
            name = o.typename.white
          end
          str << "   #{name.ljust( 30, ' ' )}\n"
        end

        return str
      end

      #
      # List the extensions
      #
      def show_ext
        data = "\n"
        data << " Extensions\n".blue
        data << "#{get_extensions}\n\n"
        @engine.log.show data
      end

      #
      # Get the text for the list of extensions.
      #
      def get_extensions
        str = ''
        exts = @engine.ext_manager.loaded_extensions.sort
        exts.each do |name, ext|
          str << "   #{name.white} \n"
        end

        return str
      end


    end
  end
end
