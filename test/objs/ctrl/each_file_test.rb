require 'test_helper'

class EachFileTest < BaseEngineTest

  def test_use_for
    i = @engine.parser.parse_immediate 'create for as each'
    i.run
    i = @engine.parser.parse_immediate 'tell for.word to unload'
    i.run
    i = @engine.parser.parse_immediate 'create for.file as file'
    i.run

    obj = @engine.heap.root.children.first
    assert obj

    assert Gloo::Objs::EachFile.use_for?( obj )
    refute Gloo::Objs::EachChild.use_for?( obj )
    refute Gloo::Objs::EachLine.use_for?( obj )
    refute Gloo::Objs::EachRepo.use_for?( obj )
    refute Gloo::Objs::EachWord.use_for?( obj )
  end

end
