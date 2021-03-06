
#
# Testing OpenWFEru (Ruote)
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'rubygems'

require File.dirname(__FILE__) + '/flowtestbase'

require 'openwfe/def'
require 'openwfe/workitem'
require 'openwfe/participants/store_participants'


class FlowTest29 < Test::Unit::TestCase
  include FlowTestBase

  def setup
    super
    @engine.ac[:remote_definitions_allowed] = true
  end

  #def teardown
  #end

  DEFHOST = 'http://openwferu.rubyforge.org/defs'

  #
  # TEST 0

  def test_httprb_0

    li = OpenWFE::LaunchItem.new
    li.wfdurl = "#{DEFHOST}/testdef.rb"

    dotest li, %w{ a b c }.join("\n")
  end


  #
  # TEST 1

  class MainDefinition1 < OpenWFE::ProcessDefinition
    sequence do
      _print "A"
      subprocess :ref => "#{DEFHOST}/testdef.rb"
      _print "C"
    end
  end

  def test_httprb_1

    dotest MainDefinition1, %w{ A a b c C }.join("\n")
  end


  #
  # TEST 2

  class MainDefinition2 < OpenWFE::ProcessDefinition
    def make
      sequence do
        _print '-1'
        subprocess :ref => "#{DEFHOST}/testdef.xml"
        _print '3'
      end
    end
  end

  def test_httprb_2

    dotest MainDefinition2, %w{ -1 0 1 2 3 }.join("\n")
  end


  #
  # TEST 3

  def test_httprb_3

    @engine.ac.delete(:remote_definitions_allowed)
      #
      # relocking

    li = OpenWFE::LaunchItem.new
    li.wfdurl = "#{DEFHOST}/testdef.rb"

    e = nil

    begin
      dotest(li, "")
    rescue Exception => e
    end

    #puts e

    assert_not_nil e
    assert_equal e.to_s, ':remote_definitions_allowed is set to false'
  end

end

