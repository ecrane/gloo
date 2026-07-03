# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Iterate over each child in an object container.
# 

module Gloo
  module Objs
    class EachChild

      CHILD = 'child'.freeze
      IN = 'IN'.freeze

      GROUP_BY = 'group_by'.freeze
      ON_GROUP_START = 'on_group_start'.freeze
      ON_GROUP_END = 'on_group_end'.freeze

      
      # ---------------------------------------------------------------------
      #    Create Iterator
      # ---------------------------------------------------------------------

      def initialize( engine, iterator_obj )
        @engine = engine
        @iterator_obj = iterator_obj
      end


      # ---------------------------------------------------------------------
      #    Check if this is the right iterator
      # ---------------------------------------------------------------------

      #
      # Use this iterator for each loop?
      #
      def self.use_for?( iterator_obj )
        return true if iterator_obj.find_child CHILD

        return false
      end

      
      # ---------------------------------------------------------------------
      #    Group By
      # ---------------------------------------------------------------------
      
      # 
      # If the iterator has a group by,
      # then we need to group by that value.
      # Otherwise, we just loop for each child.
      #
      def has_group_by?
        child = @iterator_obj.find_child GROUP_BY
        return false unless child

        return true
      end

      # 
      # Get the child that is the group by.
      # Return nil if there is no group by.
      #
      def group_by_value obj_can
        return nil unless obj_can

        child = @iterator_obj.find_child GROUP_BY
        return nil unless child

        group_by_child_name = child.value

        obj = obj_can.find_child( group_by_child_name )
        return nil unless obj

        return obj.value
      end

      #
      # Run the on group start script.
      #
      def run_on_group_start
        o = @iterator_obj.find_child ON_GROUP_START
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      #
      # Run the on group end script.
      #
      def run_on_group_end
        o = @iterator_obj.find_child ON_GROUP_END
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end


      # ---------------------------------------------------------------------
      #    Iterate
      # ---------------------------------------------------------------------

      #
      # Run for each child.
      #
      def run
        o = @iterator_obj.find_child IN
        return unless o

        # Set up for optional groups.
        group_mode = false
        if has_group_by?
          group_mode = true
          last_group = nil
          first_time = true
        end

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        o.children.each do |child|
          if group_mode
            group_value = group_by_value( child )
            if last_group != group_value
              last_group = group_value
              if first_time
                first_time = false
              else
                run_on_group_end
              end
              run_on_group_start
            end
          end

          set_child child
          @iterator_obj.run_do
        end

        if group_mode && !first_time
          run_on_group_end
        end
      end

      #
      # Set the child alias.
      #
      def set_child( obj )
        o = @iterator_obj.find_child CHILD
        return unless o

        o.set_value obj.pn
      end

    end
  end
end
