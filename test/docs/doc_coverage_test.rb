require 'test_helper'

#
# Regression guards against silent doc_data drift - not about the
# help shell mechanics (see HelpShellTest for that), just "does every
# primitive/message have the doc content it should."
#
class DocCoverageTest < BaseEngineTest

  #
  # Every dev/gloo verb has doc_data as of 2026.07.24 (see 'update verb
  # doc' story). Scoped to Gloo::Verbs:: since the Dictionary singleton
  # can accumulate test-fixture verbs (e.g. the extension-loading
  # test's throwaway `T` verb) registered by other tests in the same run.
  #
  def test_all_verbs_have_doc_data
    verbs = @engine.dictionary.get_verbs.select { |v| v.name.start_with?( 'Gloo::Verbs::' ) }
    missing = verbs.reject { |v| v.respond_to?( :doc_data ) }
    assert_empty missing.map( &:keyword )
  end

  #
  # Every dev/gloo object type has doc_data as of 2026.07.23 (see
  # 'update object doc' story). Scoped to Gloo::Objs:: since the
  # Dictionary singleton can accumulate core-library types loaded by
  # other tests in the same run (e.g. the file-loader 'load lib'
  # directive test).
  #
  def test_all_object_types_have_doc_data
    types = @engine.dictionary.get_obj_types.select { |o| o.name.to_s.start_with?( 'Gloo::Objs::' ) }
    missing = types.reject { |o| o.respond_to?( :doc_data ) }
    assert_empty missing.map( &:typename )
  end

  #
  # Every message an object type implements beyond the base Obj
  # messages (reload/unload/blank?/contains?/responds_to?) must have a
  # matching entry in doc_data[:messages] - turns doc drift (a message
  # added to code but never documented) into a caught error instead of
  # a silent gap. Checked against the leading word of each doc entry,
  # since entries are hand-written prose ("name — description"), not
  # bare names.
  #
  def test_every_own_message_is_documented
    base_messages = Gloo::Core::Obj.messages
    problems = []

    @engine.dictionary.get_obj_types.each do |klass|
      next unless klass.respond_to?( :doc_data )

      own_messages = klass.messages - base_messages
      next if own_messages.empty?

      documented = ( klass.doc_data[:messages] || [] ).map { |line| line[ /\A\S+/ ] }
      undocumented = own_messages - documented
      problems << "#{klass.typename}: #{undocumented.join( ', ' )}" unless undocumented.empty?
    end

    assert_empty problems
  end

end
