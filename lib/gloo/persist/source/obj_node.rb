# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# One object declaration in a source file, eg.
#   name [type] : value
# Carries the raw text needed to reproduce the declaration unchanged,
# plus a back-reference to the heap object it created (or updated),
# so a save can tell whether the live value still matches what's on
# disk and, if so, leave the raw text alone.
#

module Gloo
  module Persist
    module Source
      class ObjNode

        # block_style is one of:
        #  :inline    -- name [type] : value, all on one line
        #  :begin_end -- name [type] : BEGIN ... END
        #  :body      -- name [type] :, followed by an indented,
        #                unparsed body (script commands)
        attr_accessor :name, :raw_type, :raw_indent, :raw_tail, :block_style,
                      :raw_value, :raw_end_indent, :leading_doc, :trailing_comment, :obj
        attr_reader :children

        #
        # Set up an object declaration node. Everything but the name
        # and raw type is optional and commonly set afterward via the
        # accessors above -- keeping the initializer small.
        #
        def initialize( name:, raw_type: )
          @name = name
          @raw_type = raw_type
          @raw_indent = ''
          @raw_tail = ''
          @block_style = :inline
          @raw_value = nil
          # a begin_end block's closing END is not necessarily indented
          # to match its declaration -- kept separately, raw.
          @raw_end_indent = ''
          @leading_doc = nil
          @trailing_comment = nil
          @obj = nil
          @children = []
        end

      end
    end
  end
end
