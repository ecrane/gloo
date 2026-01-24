# 
# Registers the t extension.
# 
class TExt < Gloo::Plugin::Base

    # 
    # Register verbs and objects.
    # 
    def register( callback )
      require_relative 'src/t'      

      callback.register_verb( T )
    end

end
