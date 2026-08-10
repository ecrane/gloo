# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# The interactive help shell, entered by the `help`/`?` verb.
# Built on Gloo::Shell::Runner (see lib/gloo/shell/).
#
require_relative '../shell/runner'
require_relative 'markdown_renderer'

module Gloo
  module Docs
    class HelpShell < Gloo::Shell::Runner

      PROMPT = 'help>'.freeze
      NO_DOC_YET = 'No documentation available yet for'.freeze

      VERB_NAMES = :verb_names
      OBJECT_NAMES = :object_names
      DOC_NAMES = :doc_names
      LIBRARY_NAMES = :library_names
      EXTENSION_NAMES = :extension_names

      DOCS_DIR = File.expand_path( '../../../docs', __dir__ ).freeze
      README_GLOB = 'README*'.freeze
      NO_README_YET = 'No README found for library'.freeze

      #
      # Initialize the help shell for the given engine.
      #
      def initialize( engine )
        super( engine, prompt: PROMPT, include_quit: true )
        populate_context
        build_commands
      end

      # ---------------------------------------------------------------------
      #    Root commands - lists (mirrors the old help v/o/s/e/l dispatch)
      # ---------------------------------------------------------------------

      #
      # List all verbs.
      #
      def cmd_show_verbs( _obj, _context )
        theme = @engine.theme
        data = "\n"
        data << theme.heading( " Verbs (shortcut, name)\n" )
        @engine.dictionary.get_verbs.sort_by( &:keyword ).each do |v|
          cut = theme.accent( v.keyword_shortcut.ljust( 5, ' ' ) )
          name = theme.emphasis( v.keyword.ljust( 20, ' ' ) )
          data << "   #{cut}  #{name} \n"
        end
        @engine.log.show "#{data}\n"
      end

      #
      # List all object types.
      #
      def cmd_show_objects( _obj, _context )
        theme = @engine.theme
        data = "\n"
        data << theme.heading( " Objects \n" )
        @engine.dictionary.get_obj_types.sort_by( &:typename ).each do |o|
          if o.short_typename != o.typename
            short = theme.accent( "(#{o.short_typename})" )
            name = "#{theme.emphasis( o.typename )}  #{short}"
          else
            name = theme.emphasis( o.typename )
          end
          data << "   #{name.ljust( 30, ' ' )}\n"
        end
        @engine.log.show "#{data}\n"
      end

      #
      # Show application settings.
      #
      def cmd_show_settings( _obj, _context )
        @engine.settings.show
      end

      #
      # Show the current theme, how to change it, and a color preview
      # of both palettes - handy for checking how they actually render
      # in whatever terminal you're sitting in.
      #
      def cmd_show_theme( _obj, _context )
        theme = @engine.theme
        settings = @engine.settings
        config_file = File.join( settings.config_path, 'gloo.yml' )

        data = "\n"
        data << theme.heading( " Theme\n" )
        data << "   Current theme:  #{theme.emphasis( settings.theme )}\n\n"
        data << theme.muted( "   Change it in #{config_file}:\n" )
        data << theme.muted( "     theme: dark   (or: light)\n\n" )
        data << theme_preview( ' Dark palette', Gloo::App::Theme.new( 'dark' ) )
        data << "\n"
        data << theme_preview( ' Light palette', Gloo::App::Theme.new( 'light' ) )
        @engine.log.show "#{data}\n"
      end

      #
      # List loaded extensions.
      #
      def cmd_show_extensions( _obj, _context )
        theme = @engine.theme
        data = "\n"
        data << theme.heading( " Extensions\n" )
        data << theme.muted(
          "   Use `load ext {name}` to load a User Extension, \n" \
          "   then `object {name}` / `verb {name}` / `extension {name}` here to see what it adds. \n" \
          "   Only loaded extensions are listed below.\n\n" )
        loaded = @engine.ext_manager.loaded_extensions
        if loaded.empty?
          data << theme.muted( "   (none loaded)\n" )
        else
          loaded.sort.each do |name, _ext|
            data << "   #{theme.emphasis( name )} \n"
          end
        end
        @engine.log.show "#{data}\n"
      end

      #
      # List loaded libraries.
      #
      def cmd_show_libraries( _obj, _context )
        theme = @engine.theme
        data = "\n"
        data << theme.heading( " Libraries\n" )
        data << theme.muted(
          "   Use `load lib {name}` to load a core library, \n" \
          "   then `object {name}` / `verb {name}` here to see what it adds. \n" \
          "   Only loaded libraries are listed below.\n\n" )
        loaded = @engine.lib_manager.loaded_libraries
        if loaded.empty?
          data << theme.muted( "   (none loaded)\n" )
        else
          loaded.sort.each do |name, _lib|
            data << "   #{theme.emphasis( name )} \n"
          end
        end
        @engine.log.show "#{data}\n"
      end

      #
      # List all narrative doc pages (dev/gloo/docs/*.md).
      #
      def cmd_show_docs( _obj, _context )
        theme = @engine.theme
        data = "\n"
        data << theme.heading( " Docs\n" )
        doc_page_names.each do |name|
          data << "   #{theme.emphasis( name )}\n"
        end
        @engine.log.show "#{data}\n"
      end

      # ---------------------------------------------------------------------
      #    Detail commands - verb {name}, object {name}, doc {name},
      #    library {name}
      # ---------------------------------------------------------------------

      #
      # Show detailed help for one verb.
      #
      def cmd_show_verb_detail( obj, _context )
        verb_class = @engine.dictionary.find_verb( obj )
        return @engine.log.show "#{NO_DOC_YET} '#{obj}'." unless verb_class.respond_to?( :doc_data )

        page_markdown( Gloo::Docs::DocData.new( verb_class.doc_data ).render )
      end

      #
      # Show detailed help for one object type.
      #
      def cmd_show_object_detail( obj, _context )
        obj_class = @engine.dictionary.find_obj( obj )
        return @engine.log.show "#{NO_DOC_YET} '#{obj}'." unless obj_class.respond_to?( :doc_data )

        page_markdown( Gloo::Docs::DocData.new( obj_class.doc_data ).render )
      end

      #
      # Show one narrative doc page (dev/gloo/docs/{name}.md).
      #
      def cmd_show_doc_detail( obj, _context )
        path = File.join( DOCS_DIR, "#{obj}.md" )
        return @engine.log.show "#{NO_DOC_YET} '#{obj}'." unless File.exist?( path )

        page_markdown( File.read( path ) )
      end

      #
      # Show the README for one loaded core library (from the root of
      # its installed gem). Only loaded libraries are tab-completable
      # here - see cmd_show_libraries.
      #
      def cmd_show_library_detail( obj, _context )
        gem_name = @engine.lib_manager.loaded_libraries[ obj ]
        return @engine.log.show "#{NO_DOC_YET} '#{obj}'." unless gem_name

        readme_path = find_readme( gem_name )
        return @engine.log.show "#{NO_README_YET} '#{obj}' (#{gem_name})." unless readme_path

        page_markdown( File.read( readme_path ) )
      end

      #
      # Show the README for one loaded user extension (from the root of
      # its extension folder, e.g. ~/gloo/extensions/{name}). Only loaded
      # extensions are tab-completable here - see cmd_show_extensions.
      #
      def cmd_show_extension_detail( obj, _context )
        start_file = @engine.ext_manager.loaded_extensions[ obj ]
        return @engine.log.show "#{NO_DOC_YET} '#{obj}'." unless start_file

        readme_path = find_extension_readme( start_file )
        return @engine.log.show "#{NO_README_YET} '#{obj}'." unless readme_path

        page_markdown( File.read( readme_path ) )
      end

      # ---------------------------------------------------------------------
      #    Private
      # ---------------------------------------------------------------------

      private

      #
      # Build a labeled preview block for one theme's palette: one line
      # per role, colored in that role's own color, labeled with the
      # role's name. Padding is applied to the plain label before it's
      # colorized, so the ANSI codes don't throw off the alignment.
      #
      def theme_preview( title, theme )
        lines = "#{theme.heading( title )}\n"
        Gloo::App::Theme::ROLES.each do |role|
          label = role.to_s.ljust( 12 )
          lines << theme.send( role, "   #{label}#{role}" )
          lines << "\n"
        end
        return lines
      end

      #
      # Colorize markdown and page it, bracketed with a '---' rule above
      # and below so the content stands out from surrounding CLI output.
      #
      def page_markdown( md )
        rule = '-' * @engine.platform.cols
        bracketed = "#{rule}\n#{md.strip}\n#{rule}\n"
        @engine.platform.page( Gloo::Docs::MarkdownRenderer.colorize( bracketed, @engine.theme ) )
      end

      #
      # Snapshot the verb, object type, doc page, and loaded library
      # names for tab-completion.
      #
      def populate_context
        set_context( VERB_NAMES, @engine.dictionary.get_verbs.map( &:keyword ).sort )
        set_context( OBJECT_NAMES, @engine.dictionary.get_obj_types.map( &:typename ).sort )
        set_context( DOC_NAMES, doc_page_names )
        set_context( LIBRARY_NAMES, @engine.lib_manager.loaded_libraries.keys.sort )
        set_context( EXTENSION_NAMES, @engine.ext_manager.loaded_extensions.keys.sort )
      end

      #
      # Find the README file at the root of an installed gem, if any.
      #
      def find_readme( gem_name )
        spec = Gem::Specification.find_by_name( gem_name )
        return Dir.glob( File.join( spec.gem_dir, README_GLOB ) ).first
      rescue Gem::MissingSpecError
        return nil
      end

      #
      # Find the README file at the root of an extension's folder, given
      # the full path to its {name}_ext.rb start file.
      #
      def find_extension_readme( start_file )
        root = File.dirname( start_file )
        return Dir.glob( File.join( root, README_GLOB ) ).first
      end

      #
      # List the narrative doc page names (dev/gloo/docs/*.md, without extension).
      #
      def doc_page_names
        return Dir.glob( File.join( DOCS_DIR, '*.md' ) ).map { |f| File.basename( f, '.md' ) }.sort
      end

      #
      # Build the help shell's command tree.
      #
      def build_commands
        add_command_node(
          name: 'verbs', description: 'List all verbs', method: 'cmd_show_verbs' )
        add_command_node(
          name: 'objects', description: 'List all object types', method: 'cmd_show_objects' )
        add_command_node(
          name: 'settings', description: 'Show application settings', method: 'cmd_show_settings' )
        add_command_node(
          name: 'theme', description: 'Show the current theme and preview both palettes',
          method: 'cmd_show_theme' )
        add_command_node(
          name: 'extensions', description: 'List loaded extensions', method: 'cmd_show_extensions' )
        add_command_node(
          name: 'libraries', description: 'List loaded libraries', method: 'cmd_show_libraries' )
        add_command_node(
          name: 'docs', description: 'List all narrative doc pages', method: 'cmd_show_docs' )
        add_command_node(
          name: 'verb', description: 'Show detailed help for a verb',
          dynamic: true, source: VERB_NAMES, child_method: 'cmd_show_verb_detail' )
        add_command_node(
          name: 'object', description: 'Show detailed help for an object type',
          dynamic: true, source: OBJECT_NAMES, child_method: 'cmd_show_object_detail' )
        add_command_node(
          name: 'doc', description: 'Show one narrative doc page',
          dynamic: true, source: DOC_NAMES, child_method: 'cmd_show_doc_detail' )
        add_command_node(
          name: 'library', description: "Show a loaded library's README",
          dynamic: true, source: LIBRARY_NAMES, child_method: 'cmd_show_library_detail' )
        add_command_node(
          name: 'extension', description: "Show a loaded extension's README",
          dynamic: true, source: EXTENSION_NAMES, child_method: 'cmd_show_extension_detail' )
      end

    end
  end
end
