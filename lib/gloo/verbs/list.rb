# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# List out an object and it's children.
#

module Gloo
  module Verbs
    class List < Gloo::Core::Verb

      KEYWORD = 'list'.freeze
      KEYWORD_SHORT = '.'.freeze
      TARGET_MISSING_ERR = 'Object does not exist: '.freeze

      #
      # Run the verb.
      #
      def run
        levels = determine_levels
        target = self.determine_target
        indent = self.determine_indent

        obj = target.resolve
        if obj
          show_target( obj, levels, indent )
        else
          @engine.err "#{TARGET_MISSING_ERR} #{target}"
        end
      end

      #
      # Determine the target object for the show command.
      #
      def determine_target
        return @engine.heap.context if @tokens.token_count == 1

        return Gloo::Core::Pn.new( @engine, @tokens.second )
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
      # Show the target object.
      #
      def show_target( obj, levels, indent = '' )
        show_obj( obj, indent )
        return if levels.zero?

        obj.children.each do |o|
          show_target( o, levels - 1, "#{indent}#{determine_indent}" )
        end
      end

      #
      # Show object in standard format.
      #
      def show_obj( obj, indent = '  ' )
        theme = @engine.theme
        show_doc( obj, indent ) if @engine.settings.list_docs
        if obj.multiline_value? && obj.value_is_array?
          str = theme.emphasis( "#{indent}#{obj.name}" )
          str << theme.accent( " [#{obj.type_display}] : " )
          @engine.log.show str
          obj.value.each do |line|
            @engine.log.show "#{indent}  #{line}"
          end
        else
          str = theme.emphasis( "#{indent}#{obj.name}" )
          str << theme.accent( " [#{obj.type_display}] : " )
          str << "#{obj.value}"
          @engine.log.show str
        end
      end

      #
      # Show the object's doc (its leading comment, cleaned up) above
      # its listing line, one '#'-prefixed line per line of doc, word-
      # wrapped to fit the terminal. Silent when the object has none.
      #
      def show_doc( obj, indent )
        return if obj.doc.to_s.strip.empty?

        prefix = "#{indent}# "
        cont_indent = "#{indent}  " # lines up under the text after '# '
        width = doc_wrap_width( prefix.length )

        # split( -1 ), not each_line -- a doc ending in a blank '#' line
        # ends with "\n", and each_line silently drops that trailing
        # empty line rather than yielding it.
        obj.doc.split( "\n", -1 ).each do |line|
          show_doc_line( line, prefix, cont_indent, width )
        end
      end

      #
      # Word-wrap a single doc line to width, then show each wrapped
      # piece: the '#' prefix on the first, the aligned continuation
      # indent on the rest.
      #
      def show_doc_line( line, prefix, cont_indent, width )
        theme = @engine.theme
        wrapped = Gloo::Objs::WordWrap.wrap( line, width )
        # "".split( "\n", -1 ) is [], not [ '' ] -- a blank line still
        # needs one piece so it renders as a bare '#', not nothing.
        pieces = wrapped.empty? ? [ '' ] : wrapped.split( "\n", -1 )
        pieces.each_with_index do |piece, i|
          p = i.zero? ? prefix : cont_indent
          @engine.log.show theme.muted( "#{p}#{piece}".rstrip )
        end
      end

      #
      # How many columns of text fit after the doc-line prefix. Falls
      # back to a small minimum rather than a zero/negative width when
      # the terminal is very narrow or the indent is very deep.
      #
      def doc_wrap_width( prefix_length )
        width = Gloo::App::Settings.cols( @engine ) - prefix_length
        return width if width.positive?

        return 20
      end

      #
      # Determine how many levels to show.
      #
      def determine_levels
        # Check settings for the default value.
        levels = @engine.settings.list_levels
        return levels if levels

        # Last chance: use the default
        return 1
      end

      #
      # Determine the level of indentation in the outline.
      #
      def determine_indent
        # Check settings for the default value.
        indent = @engine.settings.list_indent
        if indent
          return ( ' ' * indent )
        end

        # Last chance: use the default
        return '  '
      end

      # ---------------------------------------------------------------------
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'List out objects (and children) at the ' \
            'current context. When a path is provided, it will be ' \
            'listed instead of the current context. When using context, ' \
            'the current context will be shown, but when context has ' \
            'not been set, the root will be shown. When the list_docs ' \
            'setting is on, any listed object that has a doc (the ' \
            'comment block declared immediately above it in its source ' \
            'file) shows it too.',
          :syntax => [ 'list {path.to.object}' ],
          :parameters => [
            '{path.to.object} — Optional path to object that will be listed. When no path is provided, the current context is used.'
          ],
          :result => 'Object and children are listed out in the CLI. ' \
            'Doc lines are included when the list_docs setting is on.',
          :errors => [
            "#{TARGET_MISSING_ERR}{path.to.object} — The object specified that is to be listed could not be found."
          ],
          :examples => <<~EXAMPLES.strip
            > list
            > list my.container
            > list root
          EXAMPLES
        }
      end

    end
  end
end
