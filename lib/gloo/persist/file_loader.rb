# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Helper class used to load a file, create objects in the heap, and
# build a parallel Source::SourceDoc capturing everything about the
# file that the heap alone can't represent (comments, blank lines,
# raw formatting) -- so a later save can rewrite the file instead of
# regenerating it from scratch.
#
# Comment buffering is delegated to CommentBuffer, script-body
# collection to ScriptBodyCollector, and the nesting level shared by
# the heap and source trees to IndentStack -- this class is the
# orchestrator: per-line dispatch and BEGIN/END handling.
#

module Gloo
  module Persist
    class FileLoader

      BEGIN_BLOCK = 'BEGIN'.freeze
      END_BLOCK = 'END'.freeze
      SPACE_CNT = 2

      # A 'load lib {name}' (or 'load ext {name}') statement at the top
      # of a file, before the first object declaration. It makes a core
      # library's object types available to the declarations that
      # follow. Same syntax as the load verb, but the loader runs it
      # before building the object tree instead of a script running it
      # afterward.
      LIB_DIRECTIVE = /\A(?:load|ld)\s+(?:lib|ext)\s+\S+\s*\z/i.freeze

      attr_reader :obj, :roots, :source_doc

      #
      # Set up a file storage for an object.
      #
      def initialize( engine, pn )
        @engine = engine
        @mech = @engine.platform.get_file_mech( @engine )
        @pn = pn
        @obj = nil
        @roots = []
        @source_doc = Gloo::Persist::Source::SourceDoc.new
        @comments = Gloo::Persist::CommentBuffer.new
        @body = Gloo::Persist::ScriptBodyCollector.new
        @in_block = false
        @block_value = ''
        @body_started = false
        @debug = false
      end

      #
      # Load the objects from the file.
      #
      def load
        unless @mech.exist?( @pn )
          @engine.err "File '#{@pn}' does not exist."
          return
        end

        @engine.log.debug "Loading file '#{@pn}'"
        @indent_stack = IndentStack.new( @engine.heap.root, @source_doc )
        f = @mech.read( @pn )

        f = join_continuations( f )
        f.each_line { |line| dispatch_line( line ) }
        finish
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
      # Join continuation lines.
      #
      def join_continuations( data )
        return data.gsub( "\\\n", '' )
      end

      # ---------------------------------------------------------------------
      #    Per-line dispatch
      # ---------------------------------------------------------------------

      #
      # Route one line of the file to whichever mode we're currently in:
      # collecting a script body, collecting a BEGIN/END block, trivia
      # (comment/blank), a top-of-file directive, or a normal
      # declaration.
      #
      def dispatch_line( line )
        return handle_body_line( line ) if @body.active
        return handle_block_line( line ) if @in_block
        return handle_trivia_line( line ) if skip_line?( line )

        if !@body_started && line =~ LIB_DIRECTIVE
          @indent_stack.node.children << Source::DirectiveNode.new( line.strip )
          run_lib_directive line
          return
        end
        @body_started = true

        handle_declaration_line( line )
      end

      #
      # End of file: close out anything still open so its content
      # isn't silently dropped.
      #
      def finish
        @body.finish
        @comments.flush_into( @indent_stack.node.children )
      end

      # ---------------------------------------------------------------------
      #    Trivia (comments and blank lines)
      # ---------------------------------------------------------------------

      #
      # A comment or blank line, outside of any block/body. A comment
      # is buffered -- it may turn out to be the leading_doc for the
      # declaration that follows. A blank line always breaks that
      # association (detaches any buffered comments as floating nodes)
      # and is itself kept, not discarded.
      #
      def handle_trivia_line( line )
        if line.strip.empty?
          @comments.flush_into( @indent_stack.node.children )
          @indent_stack.node.children << Source::BlankNode.new( chomped( line ) )
        else
          @comments.push( chomped( line ), tab_count( line ) )
        end
      end

      # ---------------------------------------------------------------------
      #    BEGIN / END blocks
      # ---------------------------------------------------------------------

      #
      # Inside a BEGIN/END block every line is literal content -- kept
      # exactly as-is, comments and blank lines included.
      #
      def handle_block_line( line )
        if line.strip == END_BLOCK
          @in_block = false
          finalize_declaration( @save_line )
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
      def handle_body_line( line )
        consumed = @body.handle_line( line, tab_count( line ) )
        dispatch_line( line ) unless consumed
      end

      # ---------------------------------------------------------------------
      #    Object declarations
      # ---------------------------------------------------------------------

      #
      # A line that starts (or is) an object declaration.
      #
      def handle_declaration_line( line )
        if line.strip.end_with?( BEGIN_BLOCK )
          @in_block = true
          @save_line = line
          return
        end

        finalize_declaration( line )
      end

      #
      # Place the declaration at its indentation level and create the
      # object (and its Source::ObjNode).
      #
      def finalize_declaration( line )
        line_tabs = tab_count( line )
        @indent_stack.place( line_tabs, @last, @last_node )
        create_declared_obj( line, line_tabs )
      end

      #
      # Create the heap object and its source node for one declaration
      # line, and start body collection if its type calls for one.
      #
      def create_declared_obj( line, line_tabs )
        parent = @indent_stack.parent
        name, type, value, block_style = split_declaration( line )

        params = { :name => name, :type => type, :value => value, :parent => parent }
        @last = @engine.factory.create( params )
        @roots << @last if parent == @engine.heap.root

        node = build_obj_node( leading_ws( line ), name, type, value, block_style )
        node.leading_doc = @comments.take_leading_doc( line_tabs, @indent_stack.node.children )
        @indent_stack.node.children << node
        @last_node = node
        @obj = @last if @obj.nil?

        @body.start( node, @last, @indent_stack.tabs ) if value&.empty? && @last&.multiline_value?
      end

      #
      # Split a declaration line into name/type/value, folding in any
      # BEGIN/END block value collected just before it.
      #
      def split_declaration( line )
        name, type, value = split_line( line )
        return name, type, value, :inline if @block_value == ''

        value = @block_value
        @block_value = ''
        return name, type, value, :begin_end
      end

      #
      # Build the source node for one object declaration.
      #
      def build_obj_node( raw_indent, name, type, value, block_style )
        raw_value = block_style == :begin_end ? value.chomp( "\n" ) : value
        node = Source::ObjNode.new( :name => name, :raw_type => type )
        node.raw_indent = raw_indent
        node.block_style = block_style
        node.raw_value = raw_value
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
      # Get the number of leading tabs.
      #
      def tab_count( line )
        i = 0

        if line[ i ] == ' '
          i += 1 while line[ i ] == ' '
          tab_equiv = ( i / SPACE_CNT ).to_i
          puts "Found #{i} spaces => #{tab_equiv}" if @debug
          return tab_equiv
        end

        i += 1 while line[ i ] == "\t"
        return i
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

      #
      # A line's raw text with its trailing newline removed.
      #
      def chomped( line )
        return line.chomp( "\n" )
      end

    end
  end
end
