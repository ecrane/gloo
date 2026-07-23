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
      KEYWORD_HARD = 'hard'.freeze

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

        if is_hard_redirect?
          redirect_hard
        else
          determine_target
          redirect_to_target
        end
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
      # Is this a hard redirect?
      # A hard redirect returns the new URL to the client.
      # 
      def is_hard_redirect?
        return false unless @params&.token_count&.positive?

        param_val = @params.tokens.first
        return ( param_val.downcase == KEYWORD_HARD )
      end

      # 
      # Redirect to the target using a hard redirect.
      # 
      def redirect_hard
        expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
        to_site = expr.evaluate

        if @engine.app_running?
          @engine.exec_env.running_script.break_out
          @engine.running_app.obj.redirect_hard = to_site
        else
          @engine.err APP_NOT_RUNING_ERR
        end
      end

      # 
      # Send the control to the redirect target.
      # This could be a page or a script.
      # 
      def redirect_to_target
        # TODO: Use a better way to determine if the target is a page or a script.
        if @engine.app_running? && ( @target_obj.class.name == 'Objs::Page' )
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
          @engine.exec_env.running_script.break_out
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

      # ---------------------------------------------------------------------
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Redirect from the current script (or page). ' \
            'There are 3 ways to use this verb: redirect in a script; ' \
            'redirect from one page to another, where the parameter is ' \
            'a path to a page; or redirect (hard) to an external web ' \
            'site, where the parameter is the URL.',
          :syntax => [
            'redirect {path.to.object}',
            'redirect https://example.com/ (hard)'
          ],
          :parameters => [
            '{path.to.object} — Reference to the script to run, or ' \
              'reference to the page to redirect to. In the case of a ' \
              'redirect (hard) this is the target website we will redirect to.'
          ],
          :result => 'No more commands are executed in the currently ' \
            'running script. Execution transfers to the target script. ' \
            'If the target is a page, the current page is replaced with ' \
            'the target page.',
          :errors => [
            "#{MISSING_EXPR_ERR} — Redirect requires the target page or script to redirect to.",
            "#{BAD_TARGET_ERR} — The target object does not exist or cannot receive the redirect.",
            "#{APP_NOT_RUNING_ERR} — Page cannot redirect because the application is not running."
          ],
          :examples => <<~EXAMPLES.strip
            # Redirect to a different script:
            redirect [can] :
              x [bool] : false
              first_time [script] : show 'It is true (first time)'
              second_time [script] : show 'It is true (second time)'
              on_load [script] :
                if ^.x then go ^.first_time
                show 'skipping first time'
                put true into ^.x
                if ^.x then go ^.second_time
                show 'skipping second time'
          EXAMPLES
        }
      end

    end
  end
end
