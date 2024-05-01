# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Redirect the web svr request to a different page.
# This verb only works in context of a running web server.
#

module Gloo
  module Verbs
    class Redirect < Gloo::Core::Verb

      KEYWORD = 'redirect'.freeze
      KEYWORD_SHORT = 'go'.freeze

      RUN_MESSAGE = 'run'.freeze

      MISSING_EXPR_ERR = 'Missing Expression!'.freeze
      APP_NOT_RUNING_ERR = 'The application is not running!'.freeze
      BAD_TARGET_ERR = 'Bad redirect target!'.freeze

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count < 2
          @engine.err MISSING_EXPR_ERR
          return
        end

        determine_target
        redirect_to_target
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
      # Send the control to the redirect target.
      # This could be a page or a script.
      # 
      def redirect_to_target
        if @target_obj.class == Gloo::Objs::Page 
          redirect_to_page
        elsif @target_obj.can_receive_message?( RUN_MESSAGE )
          redirect_to_script
        else
          @engine.err BAD_TARGET_ERR
        end
      end

      # 
      # Find the target of the redirect.
      # 
      def determine_target
        obj_name = @tokens.second
        pn = Gloo::Core::Pn.new( @engine, obj_name )

        @target_obj = pn.resolve
 
        @engine.log.info "obj type: #{@target_obj.class}"
      end

      # 
      # Redirect to a page.
      # This requires a running web server.
      # 
      def redirect_to_page
        if @engine.app_running?
          @engine.running_app.obj.redirect = @target_obj
        else
          @engine.err APP_NOT_RUNING_ERR
        end
      end

      # 
      # Redirect to another script.
      # This stops execution of the current script.
      # 
      def redirect_to_script
        @engine.exec_env.running_script.break_out

        Gloo::Exec::Dispatch.message( @engine, RUN_MESSAGE, @target_obj )
      end

    end
  end
end
