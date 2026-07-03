require 'test_helper'

class FileStorageTest < BaseEngineTest

  def test_loading_a_file
    pn = @engine.persist_man.get_full_path_names( 'test' ).first
    fs = Gloo::Persist::FileStorage.new( @engine, pn )
    fs.load
    assert fs.obj
    assert_equal 'test', fs.obj.name
  end

end
