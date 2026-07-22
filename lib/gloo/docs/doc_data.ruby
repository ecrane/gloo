# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Documentation data for a primitive: a verb or an object.
#

module Gloo
  module Docs
    class DocData

      attr_accessor :name, :description, :usage, :examples, :notes

      def initialize
        @name = "run"
        @description = "run a script or a runable object"
        @usage = ""
        @examples = []
        @notes = ""
      end

      # 
      # Show the documentation in the terminal.
      def show_in_terminal
        puts
        puts "NAME"
        puts @name
        puts
        puts "DESCRIPTION"
        puts @description
        puts
      end

    end
  end
end
