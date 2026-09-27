require 'test_helper'

class NotFoundTest < Minitest::Test

  def test_object
    assert_equal "Object 'a.b' was not found.", Gloo::Core::NotFound.object( 'a.b' )
  end

  def test_file
    assert_equal "File 'x.gloo' was not found.", Gloo::Core::NotFound.file( 'x.gloo' )
  end

  def test_folder
    assert_equal "Folder '/tmp/x' was not found.", Gloo::Core::NotFound.folder( '/tmp/x' )
  end

  def test_verb
    assert_equal "Verb 'xyz' was not found.", Gloo::Core::NotFound.verb( 'xyz' )
  end

end
