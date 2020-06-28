# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Helper class used to load a file and create objects in the heap.
#

module Gloo
  module Persist
    class FileLoader

      BEGIN_BLOCK = 'BEGIN'.freeze
      END_BLOCK = 'END'.freeze
      SPACE_CNT = 2

      attr_reader :obj

      # Set up a file storage for an object.
      def initialize( pn )
        @pn = pn
        @tabs = 0
        @obj = nil
        @in_multiline = false
        @exiting_multiline = false
        @in_block = false
        @block_value = ''
        @debug = false
      end

      #
      # Load the objects from the file.
      #
      def load
        unless File.exist?( @pn )
          $log.error "File '#{@pn}' does not exist."
          return
        end
        @tabs = 0
        @parent_stack = []
        @parent = $engine.heap.root
        @parent_stack.push @parent
        f = File.open( @pn, 'r' )
        f.each_line do |line|
          next if skip_line? line

          handle_one_line line
        end
      end

      #
      # Process one one of the file we're loading.
      #
      def handle_one_line( line )
        if line.strip.end_with? BEGIN_BLOCK
          @in_block = true
          @save_line = line
        elsif @in_block
          if line.strip == END_BLOCK
            @in_block = false
            determine_indent @save_line
            process_line @save_line
          else
            @block_value << line
          end
        else
          determine_indent line
          process_line line
        end
      end

      # Is this line a comment or a blank line?
      # If so we'll skip it.
      def skip_line?( line )
        line = line.strip
        return true if line.empty?
        return true if line[ 0 ] == '#'

        return false
      end

      # Determine the relative indent level for the line.
      def determine_indent( line )
        tabs = tab_count( line )
        @indent = 0 # same level as prior line
        if tabs > @tabs # indent
          # TODO:  What if indent is more than one more level?
          @tabs = tabs
          @indent = 1
        elsif tabs < @tabs # outdent
          diff = @tabs - tabs
          @tabs -= diff
          @indent -= diff
        end
        puts "tabs: #{@tabs}, indent: #{@indent}, line: #{line}" if @debug
      end

      # Process one line and add objects.
      def process_line( line )
        # reset multiline unless we're actually indented
        if @in_multiline && @multi_indent > @indent
          puts "Done multiline mi: #{@multi_indent}, i: #{@indent}" if @debug
          @in_multiline = false
          @exiting_multiline = true
        end

        if @in_multiline
          @last.add_line line
        else
          setup_process_obj_line
          process_obj_line line
        end
      end

      #
      # Setup and get ready to process an object line.
      #
      def setup_process_obj_line
        if @exiting_multiline
          @exiting_multiline = false
          @indent += 1
        end

        if @indent.positive?
          @parent = @last
          @parent_stack.push @parent
        elsif @indent.negative?
          @indent.abs.times do
            @parent_stack.pop
            @parent = @parent_stack.last
          end
        end
      end

      #
      # Process one line and add objects.
      #
      def process_obj_line( line )
        name, type, value = split_line( line )
        unless @block_value == ''
          value = @block_value
          @block_value = ''
        end
        params = { name: name, type: type, value: value, parent: @parent }
        @last = $engine.factory.create( params )

        if value.empty? && @last&.multiline_value?
          @multi_indent = 0
          @in_multiline = true
          puts "*** Start multiline. multi_indent: #{@multi_indent}" if @debug
        end

        @obj = @last if @obj.nil?
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
        o = LineSplitter.new( line, @tabs )
        return o.split
      end

    end
  end
end
