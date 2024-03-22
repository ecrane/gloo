require 'test_helper'

class HandlerTest < BaseEngineTest

  def test_app_svr_creation
    o = @engine.parser.parse_immediate "create s as svr"
    o.run
    obj = @engine.heap.root.children.first

    svr = Gloo::WebSvr::Handler.new @engine, obj
    assert svr
    assert_equal obj, svr.server_obj
  end

end
