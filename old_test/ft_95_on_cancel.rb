
#
# Testing Ruote (OpenWFEru)
#
# John Mettraux at openwfe.org
#
# Thu Dec  4 21:22:57 JST 2008
#

require File.dirname(__FILE__) + '/flowtestbase'


class FlowTest95 < Test::Unit::TestCase
  include FlowTestBase

  #
  # TEST 0

  # testing the 'on_cancel' expression (via participant)

  class Test0 < OpenWFE::ProcessDefinition
    sequence :on_cancel => 'decommission' do
      alpha
    end
  end

  def test_0

    @engine.register_participant :alpha, OpenWFE::NullParticipant
      # receives workitems, discards them, does not reply to the engine

    @engine.register_participant :decommission do |workitem|
      @tracer << "#{workitem.fei.wfid} decom\n"
    end

    fei = @engine.launch Test0

    #p fei.wfid

    sleep 0.350

    ps = @engine.process_status(fei)

    assert_equal 1, ps.expressions.size
    assert_equal 'alpha', ps.expressions.first.fei.expname

    @engine.cancel_process(fei)

    sleep 0.350

    assert_equal "#{fei.wfid}.0 decom", @tracer.to_s

    assert_nil @engine.process_status(fei)

    #purge_engine
  end

  #
  # TEST 1

  # testing the 'on_cancel' expression (via subprocess, tag)

  class Test1 < OpenWFE::ProcessDefinition
    sequence :on_cancel => 'decommission' do
      alpha
    end

    process_definition :name => 'decommission' do
      sequence do
        decommission_agent
      end
    end
  end

  def test_1

    #log_level_to_debug

    @engine.register_participant :alpha, OpenWFE::NullParticipant
      # receives workitems, discards them, does not reply to the engine

    @engine.register_participant :decommission_agent do |workitem|
      @tracer << "#{workitem.fei.wfid} decom agent\n"
    end

    fei = @engine.launch Test1

    #p fei.wfid

    sleep 0.3350

    ps = @engine.process_status(fei)

    assert_equal 1, ps.expressions.size
    assert_equal 'alpha', ps.expressions.first.fei.expname

    @engine.cancel_process(fei)

    sleep 0.350

    assert_equal "#{fei.wfid}.0 decom agent", @tracer.to_s

    assert_nil @engine.process_status(fei)

    #purge_engine
  end

  #
  # TEST 3

  class Test3 < OpenWFE::ProcessDefinition
    process_definition(
      :name => 'ft_95_test', :revision => '3', :on_cancel => :decommission
    ) do
      sequence do
        _print '0'
        alpha
        _print '1'
      end
      define 'decommission' do
        _print 'd'
      end
    end
  end

  def test_3

    @engine.register_participant(:alpha, OpenWFE::NullParticipant)

    fei = @engine.launch(Test3)

    sleep 0.350

    @engine.cancel_process(fei)

    sleep 0.350

    assert_equal "0\nd", @tracer.to_s
    assert_equal 1, @engine.get_expression_storage.size
  end
end

