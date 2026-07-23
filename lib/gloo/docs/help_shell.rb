# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# The interactive help shell, entered by the `help`/`?` verb.
# Built on Gloo::Shell::Runner (see lib/gloo/shell/).
#
require_relative '../shell/runner'

module Gloo
  module Docs
    class HelpShell < Gloo::Shell::Runner

      PROMPT = 'help>'.freeze
      NO_DOC_YET = 'No documentation available yet for'.freeze

      VERB_NAMES = :verb_names
      OBJECT_NAMES = :object_names

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
        data = "\n"
        data << " Verbs (shortcut, name)\n".blue
        @engine.dictionary.get_verbs.sort_by( &:keyword ).each do |v|
          cut = v.keyword_shortcut.ljust( 5, ' ' ).yellow
          name = v.keyword.ljust( 20, ' ' ).white
          data << "   #{cut}  #{name} \n"
        end
        @engine.log.show "#{data}\n"
      end

      #
      # List all object types.
      #
      def cmd_show_objects( _obj, _context )
        data = "\n"
        data << " Objects \n".blue
        @engine.dictionary.get_obj_types.sort_by( &:typename ).each do |o|
          if o.short_typename != o.typename
            short = "(#{o.short_typename})".yellow
            name = "#{o.typename.white}  #{short}"
          else
            name = o.typename.white
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
      # List loaded extensions.
      #
      def cmd_show_extensions( _obj, _context )
        data = "\n"
        data << " Extensions\n".blue
        @engine.ext_manager.loaded_extensions.sort.each do |name, _ext|
          data << "   #{name.white} \n"
        end
        @engine.log.show "#{data}\n"
      end

      #
      # List loaded libraries.
      #
      def cmd_show_libraries( _obj, _context )
        data = "\n"
        data << " Libraries\n".blue
        @engine.lib_manager.loaded_libraries.sort.each do |name, _lib|
          data << "   #{name.white} \n"
        end
        @engine.log.show "#{data}\n"
      end

      # ---------------------------------------------------------------------
      #    Detail commands - verb {name}, object {name}
      # ---------------------------------------------------------------------

      #
      # Show detailed help for one verb.
      #
      def cmd_show_verb_detail( obj, _context )
        verb_class = @engine.dictionary.find_verb( obj )
        return @engine.log.show "#{NO_DOC_YET} '#{obj}'." unless verb_class.respond_to?( :doc_data )

        Gloo::Docs::DocData.new( verb_class.doc_data ).show_in_terminal
      end

      #
      # Show detailed help for one object type.
      #
      def cmd_show_object_detail( obj, _context )
        obj_class = @engine.dictionary.find_obj( obj )
        return @engine.log.show "#{NO_DOC_YET} '#{obj}'." unless obj_class.respond_to?( :doc_data )

        Gloo::Docs::DocData.new( obj_class.doc_data ).show_in_terminal
      end

      # ---------------------------------------------------------------------
      #    Private
      # ---------------------------------------------------------------------

      private

      #
      # Snapshot the verb and object type names for tab-completion.
      #
      def populate_context
        set_context( VERB_NAMES, @engine.dictionary.get_verbs.map( &:keyword ).sort )
        set_context( OBJECT_NAMES, @engine.dictionary.get_obj_types.map( &:typename ).sort )
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
          name: 'extensions', description: 'List loaded extensions', method: 'cmd_show_extensions' )
        add_command_node(
          name: 'libraries', description: 'List loaded libraries', method: 'cmd_show_libraries' )
        add_command_node(
          name: 'verb', description: 'Show detailed help for a verb',
          dynamic: true, source: VERB_NAMES, child_method: 'cmd_show_verb_detail' )
        add_command_node(
          name: 'object', description: 'Show detailed help for an object type',
          dynamic: true, source: OBJECT_NAMES, child_method: 'cmd_show_object_detail' )
      end

    end
  end
end
