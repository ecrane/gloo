# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A CLI menu.
# The menu contains a collection of menu items, a prompt
# and an option to loop until done.
#

module Gloo
  module Objs
    class Menu < Gloo::Core::Obj

      KEYWORD = 'menu'.freeze
      KEYWORD_SHORT = 'menu'.freeze
      PROMPT = 'prompt'.freeze
      ITEMS = 'items'.freeze
      LOOP = 'loop'.freeze
      HIDE_ITEMS = 'hide_items'.freeze
      BEFORE_MENU = 'before_menu'.freeze
      DEFAULT = 'default'.freeze
      TITLE = 'title'.freeze
      TITLE_STYLE = 'straight'.freeze
      TITLE_COLOR = 'bright_cyan'.freeze
      QUIT_ITEM_NAME = 'q'.freeze

      @@menu_stack = []

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      #
      # Get the value of the prompt child object.
      # Returns nil if there is none.
      #
      def prompt_value
        o = find_child PROMPT
        return '' unless o

        return o.value
      end

      #
      # Get the value of the loop child object.
      # Should we keep looping or should we stop?
      #
      def loop?
        return false unless @engine.running

        o = find_child LOOP
        return false unless o

        return o.value
      end

      # 
      # If there is no loop child, add it.
      # 
      def add_loop_child
        o = find_child LOOP
        return if o

        fac = @engine.factory
        fac.create_bool LOOP, true, self
      end

      # 
      # Add a Quit menu item
      # 
      def add_quit_item
        items = find_child ITEMS
        q = items.find_child QUIT_ITEM_NAME
        return if q

        fac = @engine.factory
        fac.create_bool LOOP, true, self

        params = { :name => QUIT_ITEM_NAME,
          :type => 'mitem',
          :value => 'Quit',
          :parent => items }
        mitem = fac.create params
        script = "put false into #{self.pn}.loop"
        fac.create_script 'do', script, mitem
      end

      # 
      # Add any required children not specified in the source.
      # 
      def lazy_add_children
        add_loop_child
        add_quit_item
      end

      #
      # Does the menu have a title?
      #
      def title?
        o = find_child TITLE
        return o ? true : false
      end

      #
      # Get the Menu's Title.
      #
      def title
        obj = find_child TITLE
        return obj.value
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      #
      def add_children_on_create?
        return true
      end

      #
      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      #
      def add_default_children
        fac = @engine.factory
        fac.create_string PROMPT, '> ', self
        fac.create_can ITEMS, self
        fac.create_bool LOOP, true, self
        fac.create_script DEFAULT, '', self
      end

      # ---------------------------------------------------------------------
      #    Menu Stack
      # ---------------------------------------------------------------------

      # 
      # Show the bread-crumbs for the menu stack.
      # 
      def show_menu_stack
        if @@menu_stack.count < 2
          puts '...'
        else
          msg = ''
          @@menu_stack[0..-2].each do |menu|
            msg << ' | ' unless msg.blank?
            msg << menu.title
          end
          msg << ' | ... '
          puts msg
        end
      end

      # 
      # Add a menu to the stack.
      # 
      def push_menu obj
        @@menu_stack << obj
      end

      # 
      # Pop a menu from the stack
      # 
      def pop_menu
        @@menu_stack.pop
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'run' ]
      end

      #
      # Show the menu options, and prompt for user input.
      #
      def msg_run
        lazy_add_children
        push_menu self
        run_default
        loop do
          begin_menu
          if prompt_value.empty?
            dt = DateTime.now
            d = dt.strftime( '%Y.%m.%d' )
            t = dt.strftime( '%I:%M:%S' )
            cmd = @engine.platform.prompt.ask( "\n#{d.yellow} #{t.white} >" )
          else
            cmd = @engine.platform.prompt.ask( prompt_value )
          end
          cmd ? run_command( cmd ) : run_default
          break unless loop?
        end
        pop_menu
      end

      # ---------------------------------------------------------------------
      #    Menu actions
      # ---------------------------------------------------------------------

      #
      # Begin the menu execution.
      # Run the before menu script if there is one,
      # then show options unless we are hiding them by default.
      #
      def begin_menu
        run_before_menu

        # Check to see if we should show items at all.
        o = find_child HIDE_ITEMS
        return if o && o.value == true

        show_options
      end

      #
      # If there is a before menu script, run it now.
      #
      def run_before_menu
        o = find_child BEFORE_MENU
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      #
      # Show the list of menu options.
      #
      def show_options
        o = find_child ITEMS
        return unless o

        o.children.each do |mitem|
          mitem = Gloo::Objs::Alias.resolve_alias( @engine, mitem )
          puts "  #{mitem.shortcut_value} - #{mitem.description_value}"
        end
      end

      #
      # Find the command matching user input.
      #
      def find_cmd( cmd )
        o = find_child ITEMS
        return nil unless o

        o.children.each do |mitem|
          mitem = Gloo::Objs::Alias.resolve_alias( @engine, mitem )
          return mitem if mitem.shortcut_value.downcase == cmd.downcase
        end

        return nil
      end

      #
      # Run the default option.
      #
      def run_default
        obj = find_child DEFAULT
        if obj
          s = Gloo::Exec::Script.new( @engine, obj )
          s.run
        elsif title?
          run_default_title
        end
      end

      # 
      # There is a title, so show it.
      # 
      def run_default_title
        @engine.platform&.clear_screen
        show_menu_stack
        Banner.show_banner( title, TITLE_STYLE, TITLE_COLOR )
      end

      #
      # Run the selected command.
      #
      def run_command( cmd )
        @engine.log.debug "Menu Command: #{cmd}"
        obj = find_cmd cmd

        if obj
          script = obj.do_script
          return unless script
  
          s = Gloo::Exec::Script.new( @engine, script )
          s.run
        else
          if cmd == '?'
            show_options
          elsif cmd == 'q!'
            @engine.log.info "Quitting Gloo"
            @engine.stop_running
          else
            msg = "#{cmd} is not a valid option"
            @engine.log.warn msg
          end
          return
        end

      end

    end
  end
end
