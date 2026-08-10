# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Maps semantic color roles (heading, emphasis, etc) onto actual
# ANSI colors for the app's UI chrome (prompt, settings, log,
# tables, listings, help). Callers ask for a role, never a literal
# color, so a single palette swap (dark/light) fixes every call
# site at once.
#
# NOT used by the user-facing `show {target} (color)` verb or the
# `[colorize]` core-lib object - those are explicit color choices
# made in gloo scripts, not app chrome, and are intentionally left
# alone.
#
# Design note: most of the base 8 ANSI colors (red/green/yellow/
# blue/magenta/cyan) are exactly what a well-built terminal color
# scheme remaps per-background to stay legible - that's what
# switching a terminal profile from dark to light is for. `white`
# is the exception: by convention it stays "lightest foreground"
# regardless of background, so text forced to `.white` goes
# near-invisible on a light background no matter how good the
# terminal theme is. That's why :emphasis flips color between the
# two palettes below.
#
# `yellow` and `cyan` turned out to be further exceptions in
# practice: tested against a real light-background terminal, both
# were washed out and hard to read - the terminal's own theme
# wasn't remapping them as dark/saturated as hoped. So the light
# palette diverges from dark on more than just :emphasis, using
# explicit 256-color values (:ansi, raw SGR codes - none of these
# have a true equivalent in the base 16 ANSI colors) picked by eye
# against a real light terminal:
#   - :warn uses orange instead of yellow
#   - :accent uses a dark green instead of yellow
#   - :subheading uses navy instead of cyan
#
require 'colorize'
require 'colorized_string'

module Gloo
  module App
    class Theme

      # 256-color values picked by eye against a real light-background
      # terminal - see design note above. 256-color support has been
      # effectively universal in terminals for well over a decade.
      ORANGE = '38;5;208'.freeze
      NAVY = '38;5;18'.freeze
      DARK_GREEN = '38;5;22'.freeze

      #
      # Dark-background palette. This matches the colors gloo
      # has always used, so it's the default and non-breaking.
      #
      DARK = {
        :heading    => { :color => :blue, :mode => :bold },
        :subheading => { :color => :cyan, :mode => :bold },
        :accent     => { :color => :yellow },
        :emphasis   => { :color => :white },
        :muted      => { :color => :light_black },
        :warn       => { :color => :yellow },
        :error      => { :color => :red }
      }.freeze

      #
      # Light-background palette.
      #
      LIGHT = {
        :heading    => { :color => :blue, :mode => :bold },
        :subheading => { :ansi => NAVY },
        :accent     => { :ansi => DARK_GREEN },
        :emphasis   => { :color => :black },
        :muted      => { :color => :light_black },
        :warn       => { :ansi => ORANGE },
        :error      => { :color => :red }
      }.freeze

      PALETTES = { 'dark' => DARK, 'light' => LIGHT }.freeze
      ROLES = DARK.keys.freeze

      attr_reader :name

      #
      # Set up the theme for the given theme name ('dark' or 'light').
      # Falls back to the default (dark) for anything else.
      #
      def initialize( name = nil )
        @name = PALETTES.key?( name ) ? name : Gloo::App::Settings::DEFAULT_THEME
        @palette = PALETTES[ @name ]
      end

      #
      # Build a Theme from the engine's settings.
      #
      def self.for_engine( engine )
        return new( engine&.settings&.theme )
      end

      #
      # Colorize the given string for the given semantic role.
      # Unknown roles are returned unchanged rather than raising,
      # so a typo'd role degrades to plain text instead of crashing.
      #
      # Named colors (:color/:mode) go through the colorize gem;
      # :ansi is a raw SGR parameter string for colors the gem's
      # named palette doesn't have (eg. 256-color orange).
      #
      def apply( str, role )
        style = @palette[ role ]
        return str.to_s unless style
        return ansi_wrap( str.to_s, style ) if style[ :ansi ]

        params = {}
        params[ :color ] = style[ :color ] if style[ :color ]
        params[ :mode ] = style[ :mode ] if style[ :mode ]
        return ColorizedString[ str.to_s ].colorize( params ).to_s
      end

      #
      # Define a convenience method per role, eg. theme.heading( str ).
      #
      ROLES.each do |role|
        define_method( role ) do |str|
          apply( str, role )
        end
      end

      private

      #
      # Wrap a string in a raw SGR escape sequence - used for :ansi
      # styles (eg. 256-color orange) that the colorize gem's named
      # 16-color palette can't express.
      #
      def ansi_wrap( str, style )
        codes = []
        codes << String.mode_codes[ style[ :mode ] ] if style[ :mode ]
        codes << style[ :ansi ]
        return "\e[#{codes.join( ';' )}m#{str}\e[0m"
      end

    end
  end
end
