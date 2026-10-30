# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Helper class used to load a file, create objects in the heap, and
# build a parallel Source::SourceDoc capturing everything about the
# file that the heap alone can't represent (comments, blank lines,
# raw formatting) -- so a later save can rewrite the file instead of
# regenerating it from scratch.
#
# Every byte of the file goes into exactly one source node, in file
# order, so the document's text is the file. When the load finishes,
# each declaration remembers its object's place and value, so a save
# can tell what changed.
#
# Work is delegated to TriviaBuffer (comment/blank-line buffering),
# ScriptBodyCollector (script bodies), IndentStack (nesting shared by
# the heap and source trees), ShorthandExpander (nested-container
# shorthand), and DeclarationLedger (this file's roots + cross-file
# clash warnings) -- this class is the orchestrator: per-line dispatch
# and BEGIN/END handling.
#

module Gloo
  module Persist
    class FileLoader

      BEGIN_BLOCK = 'BEGIN'.freeze
      END_BLOCK = 'END'.freeze
      SPACE_CNT = 2
      UNNAMED = 'unnamed_'.freeze
      NO_NAME_ERR = 'Object name is missing; using '.freeze
      MISSING_BRACKET_ERR = "Missing ']' after type ".freeze
      OVER_INDENTED_WARNING = 'Indented more than one level deeper than ' \
        'the line above; nesting it under that line.'.freeze
      MISALIGNED_WARNING = "Indentation doesn't line up with any line " \
        'above; nesting it under the closest one.'.freeze
      INVALID_UTF8_WARNING = 'Line is not valid UTF-8; using U+FFFD for ' \
        'the bytes that are not.'.freeze
      NO_END_WARNING = "BEGIN block has no END; it runs to the end of the file.".freeze
      CONTINUATION = "\\\n".freeze

      # A 'load lib {name}' (or 'load ext {name}') statement at the top
      # of a file, before the first object declaration. It makes a core
      # library's object types available to the declarations that
      # follow. Same syntax as the load verb, but the loader runs it
      # before building the object tree instead of a script running it
      # afterward.
      LIB_DIRECTIVE = /\A(?:load|ld)\s+(?:lib|ext)\s+\S+\s*\z/i.freeze

      attr_reader :obj, :source_doc

      #
      # Set up a file storage for an object.
      #
      def initialize( engine, pn )
        @engine = engine
        @mech = @engine.platform.get_file_mech( @engine )
        @pn = pn
        @obj = nil
        @found = false
        @source_doc = Gloo::Persist::Source::SourceDoc.new
        @trivia = Gloo::Persist::TriviaBuffer.new
        @body = Gloo::Persist::ScriptBodyCollector.new
        @shorthand = Gloo::Persist::ShorthandExpander.new( engine )
        @ledger = Gloo::Persist::DeclarationLedger.new( engine )
        @in_block = false
        @block_value = +''
        @save_raw = nil
        @body_started = false
      end

      #
      # The top-level objects this file declared (for save resolution).
      #
      def roots
        return @ledger.roots
      end

      #
      # Was the file there to read? False before load, or when the
      # file couldn't be found (already reported as an error).
      #
      def found?
        return @found
      end

      #
      # Load the objects from the file.
      #
      def load
        unless @mech.exist?( @pn )
          @engine.err Gloo::Core::NotFound.file( @pn )
          return
        end
        @found = true

        @engine.log.debug "Loading file '#{@pn}'"
        @indent_stack = IndentStack.new( @engine.heap.root, @source_doc )
        f = @data = @mech.read( @pn )

        exec_env = @engine.exec_env
        outer_location = exec_env.load_location
        begin
          each_joined_line( f ) do |line, raw, number|
            exec_env.load_location = "#{@pn}:#{number}"
            dispatch_line( valid_utf8( line ), raw )
          end
          finish
        ensure
          exec_env.load_location = outer_location
        end
      end

      #
      # Run a top-of-file 'load lib {name}' directive. It goes through
      # the same load verb a script would use, so libraries are loaded
      # and their object types registered before the declarations that
      # depend on them are parsed.
      #
      def run_lib_directive( line )
        @engine.log.debug "Loading file directive: #{line.strip}"
        @engine.parser.run line.strip
      end

      #
      # Yield each line of the file, its exact source text, and its line
      # number (counting from 1). A line ending in a backslash continues
      # on the next line: the two are joined, dropping the backslash and
      # the line break, and the joined line has the number of the line
      # it starts on. Not inside a BEGIN/END block, whose lines are the
      # value, exactly as written.
      #
      def each_joined_line( data )
        pending = nil
        raw = nil
        start = 0
        data.each_line.with_index( 1 ) do |line, number|
          if pending
            pending << line
            raw << line
          else
            pending = line.dup
            raw = line.dup
            start = number
          end
          next if !@in_block && pending.delete_suffix!( CONTINUATION )

          yield pending, raw, start
          pending = nil
        end
        yield pending, raw, start if pending
      end

      #
      # A line to work with: as read if it's valid UTF-8, otherwise with
      # U+FFFD in place of the bytes that aren't, and a warning. The
      # source text keeps the original bytes.
      #
      def valid_utf8( line )
        return line if line.valid_encoding?

        @engine.warn INVALID_UTF8_WARNING
        return line.scrub( "\uFFFD" )
      end

      # ---------------------------------------------------------------------
      #    Per-line dispatch
      # ---------------------------------------------------------------------

      #
      # Route one line of the file to whichever mode we're currently in:
      # collecting a script body, collecting a BEGIN/END block, trivia
      # (comment/blank), a top-of-file directive, or a normal
      # declaration. line is the line as read (continuations joined),
      # raw its exact source text.
      #
      def dispatch_line( line, raw )
        return handle_body_line( line, raw ) if @body.active
        return handle_block_line( line, raw ) if @in_block
        return handle_trivia_line( line, raw ) if skip_line?( line )

        if !@body_started && line =~ LIB_DIRECTIVE
          # Comments before the directive stay before it.
          @trivia.flush_into( @indent_stack.node.children )
          @indent_stack.node.children << Source::DirectiveNode.new( raw )
          run_lib_directive line
          return
        end
        @body_started = true

        handle_declaration_line( line, raw )
      end

      #
      # End of file: close out anything still open so its content
      # isn't silently dropped, then have every declaration remember
      # its object's place and value as loaded.
      #
      def finish
        finish_open_block if @in_block
        @body.finish
        # Comments and blank lines at the end of the file belong to the
        # file, not to whatever declaration happened to come last.
        @trivia.flush_into( @source_doc.children )
        @source_doc.missing_final_newline! unless @data.empty? || @data.end_with?( "\n" )
        @source_doc.obj_nodes.each( &:remember )
      end

      #
      # A BEGIN block with no END: the best guess is that it runs to the
      # end of the file, so the object still loads with that value.
      #
      def finish_open_block
        @engine.warn NO_END_WARNING
        @in_block = false
        finalize_declaration( @save_line, @save_raw + @block_raw )
      end

      # ---------------------------------------------------------------------
      #    Trivia (comments and blank lines)
      # ---------------------------------------------------------------------

      #
      # A comment or blank line, outside of any block/body. Both are
      # buffered, not placed immediately: a container's own declaration
      # line doesn't push it as the current node (see IndentStack) until
      # a genuinely deeper line is seen, so a comment/blank sitting
      # between the container and its first child has to wait for that
      # push before it's resolved against the *correct* node -- placing
      # it against whatever's current right now would land it one level
      # too shallow. TriviaBuffer#take_leading_doc/#flush_into do that
      # resolving once the right moment comes (the next declaration, or
      # end of file).
      #
      def handle_trivia_line( line, raw )
        if line.strip.empty?
          @trivia.push_blank( raw )
        else
          @trivia.push_comment( raw, tab_count( line ) )
        end
      end

      # ---------------------------------------------------------------------
      #    BEGIN / END blocks
      # ---------------------------------------------------------------------

      #
      # Inside a BEGIN/END block every line is literal content -- kept
      # exactly as-is, comments and blank lines included.
      #
      def handle_block_line( line, raw )
        @block_raw << raw
        if line.strip == END_BLOCK
          @in_block = false
          finalize_declaration( @save_line, @save_raw + @block_raw )
        else
          @block_value << line
        end
      end

      # ---------------------------------------------------------------------
      #    Script bodies (indented lines, no BEGIN/END)
      # ---------------------------------------------------------------------

      #
      # One line while a script body might be open. Re-dispatches the
      # line normally if it turns out to have closed the body.
      #
      def handle_body_line( line, raw )
        consumed = @body.handle_line( line, raw, tab_count( line ) )
        dispatch_line( line, raw ) unless consumed
      end

      # ---------------------------------------------------------------------
      #    Object declarations
      # ---------------------------------------------------------------------

      #
      # A line that starts (or is) an object declaration.
      #
      def handle_declaration_line( line, raw )
        if line.strip.end_with?( BEGIN_BLOCK )
          @in_block = true
          @save_line = line
          @save_raw = raw
          @block_raw = +''
          return
        end

        finalize_declaration( line, raw )
      end

      #
      # Place the declaration at its indentation level and create the
      # object (and its Source::ObjNode). raw is the declaration's exact
      # text (with its BEGIN/END block, if it has one).
      #
      def finalize_declaration( line, raw )
        line_tabs = tab_count( line )
        placed = @indent_stack.place( line_tabs, @last, @last_node )
        warn_indent( placed ) if placed
        create_declared_obj( line, raw, line_tabs )
      end

      #
      # A declaration with no name is a syntax error. The best guess is
      # a placeholder name that isn't taken under the parent, so the
      # object (its type, value and children) still loads.
      #
      def placeholder_name( parent )
        n = 1
        n += 1 while parent&.contains_child?( "#{UNNAMED}#{n}" )
        name = "#{UNNAMED}#{n}"
        @engine.syntax_err "#{NO_NAME_ERR}'#{name}'."
        return name
      end

      #
      # Warn about indentation that was understood, but probably isn't
      # what was meant.
      #
      def warn_indent( placed )
        msg = if placed == IndentStack::OVER_INDENTED
                OVER_INDENTED_WARNING
              else
                MISALIGNED_WARNING
              end
        @engine.warn msg
      end

      #
      # Create the heap object and its source node for one declaration
      # line, and start body collection if its type calls for one.
      #
      def create_declared_obj( line, raw, line_tabs )
        name, type, value, style = split_declaration( line )
        style[ :repair ] ||= name.nil?
        name ||= placeholder_name( @indent_stack.parent )
        leaf, parent, roots, created = @shorthand.expand( name, @indent_stack.parent )
        roots.each { |r| @ledger.root( r ) }
        created.each { |c| @ledger.created( c ) }

        prior = parent.find_child( leaf )
        params = { :name => leaf, :type => type, :value => value, :parent => parent }
        @last = @engine.factory.create( params )
        @ledger.clash( prior, leaf, value ) if prior
        @ledger.created( @last )
        @ledger.root( @last ) if parent == @engine.heap.root

        node = build_obj_node( line, raw, name, type, value, style )
        # A declaration gloo had to guess at is written as understood.
        node.repaired_head = "#{node.raw_indent}#{name} [#{type}]" if style[ :repair ]
        node.leading_doc = @trivia.take_leading_doc( line_tabs, @indent_stack.node.children )
        # First non-empty doc wins, same as "first value wins" for a
        # name re-declared across files -- @last is the same object
        # across re-declarations (the factory returns the existing
        # one), so a later, comment-less re-declaration doesn't blank
        # out an earlier file's doc. @last can be nil for a type that
        # can't be created (an unknown type is created untyped).
        @last.doc = node.doc if @last && @last.doc.to_s.strip.empty?
        @indent_stack.node.children << node
        @last_node = node
        @obj ||= @ledger.roots.last || @last

        # A whitespace-only inline value (trailing spaces after the ':'
        # on a `script :` line) counts as no value -- start the body.
        no_value = value.nil? || value.strip.empty?
        @body.start( node, @last, @indent_stack.tabs ) if no_value && @last&.multiline_value?
      end

      #
      # Split a declaration line into name/type/value, plus a style
      # hash (:block_style, :raw_tail), folding in any BEGIN/END block
      # value collected just before it. raw_tail is the exact source
      # text that followed the type bracket on this line -- eg.
      # " : BEGIN" or " :" -- kept for a save to reproduce the
      # declaration's original spacing when unchanged.
      #
      def split_declaration( line )
        splitter = LineSplitter.new( line, @indent_stack&.tabs || 0 )
        name, type, value = splitter.split
        @engine.syntax_err "#{MISSING_BRACKET_ERR}'#{type}'." if splitter.missing_bracket
        style = { :raw_tail => splitter.raw_tail, :block_style => :inline,
                  :repair => splitter.missing_bracket && closable?( splitter.raw_tail ) }
        return name, type, value, style unless @save_raw

        value = @block_value
        @block_value = +''
        @save_raw = nil
        style[ :block_style ] = :begin_end
        return name, type, value, style
      end

      #
      # Can a missing ']' be closed on save? Only when the value comes
      # next ('b [int : 3'), not when a ']' does ('a [string ] :', where
      # closing it would add a second).
      #
      def closable?( tail )
        rest = tail.lstrip
        return rest.empty? || rest.start_with?( ':' )
      end

      #
      # Build the source node for one object declaration: its exact text
      # (raw), and its head -- the declaration line up to its value
      # (indent, name and [type], as written) -- for a save that only
      # changes the value. raw_value is what was handed to the heap
      # object's set_value.
      #
      def build_obj_node( line, raw, name, type, value, style )
        node = Source::ObjNode.new( :name => name, :raw_type => type )
        first = line.lines.first.to_s.chomp
        node.raw_indent = leading_ws( first )
        node.raw_tail = style[ :raw_tail ]
        node.head = first[ 0, first.length - node.raw_tail.length ]
        node.block_style = style[ :block_style ]
        node.raw_value = value
        node.raw = raw.dup
        node.obj = @last
        return node
      end

      #
      # Is this line a comment or a blank line?
      # If so we'll skip it.
      #
      def skip_line?( line )
        line = line.strip
        return true if line.empty?
        return true if line[ 0 ] == '#'

        return false
      end

      #
      # Get the indentation level of a line: a tab or SPACE_CNT spaces is
      # one level, and they can be mixed, on one line or across lines.
      #
      def tab_count( line )
        width = 0
        line.each_char do |c|
          if c == ' '
            width += 1
          elsif c == "\t"
            width += SPACE_CNT
          else
            break
          end
        end
        return width / SPACE_CNT
      end

      #
      # Split the line into 3 parts.
      #
      def split_line( line )
        o = LineSplitter.new( line, @indent_stack&.tabs || 0 )
        return o.split
      end

      #
      # The line's leading whitespace, exactly as written.
      #
      def leading_ws( line )
        return line[ /\A[ \t]*/ ]
      end

    end
  end
end
