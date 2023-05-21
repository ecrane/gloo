# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Here helper class,
# used to resolve relative referencing.
#

module Gloo
  module Core
    class Here

      HERE = '^'.freeze

      #
      # Does the pathname start with here reference?
      #
      def self.includes_here_ref?( elements )
        return elements.first.start_with?( HERE )
      end

      #
      # Expand here reference if present.
      #
      def self.expand_here( engine, pn )
        target = engine.exec_env.here_obj

        here = pn.elements.first
        remainder = pn.elements[ 1..-1 ].join( '.' )

        here.length.times { target = target.parent }
        pn.set_to "#{target.pn}.#{remainder}"
      end

    end
  end
end
