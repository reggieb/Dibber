$:.unshift File.join(File.dirname(__FILE__),'../..','lib')

require 'test/unit'
require 'dibber'

module Dibber
  class ProcessLogTest < Test::Unit::TestCase
    def setup
      @process_log = ProcessLog.new

    end

    def test_one
      @process_log.start(:one, '1')
      @process_log.finish(:one)

      expected = {:one => {:start => 1, :finish => 1, :command => '1'}}
      assert_equal(expected, @process_log.raw)
    end

    def test_two
      test_one
      @process_log.start(:two, '2')
      @process_log.finish(:two)

      expected = {
        :one => {:start => 1, :finish => 1, :command => '1'},
        :two => {:start => 2, :finish => 2, :command => '2'}
      }
      assert_equal(expected, @process_log.raw)
    end

    def test_report
      test_two
      expected = [
        'One was 1, now 1.',
        'Two was 2, now 2.'
      ]
      assert_equal(expected, @process_log.report)
    end

    def test_report_with_no_finish
      @process_log.start(:no_finish, '1')
      expected = ['No finish was 1, now 1.']
      assert_equal(expected, @process_log.report)
    end

    def test_exists_method
      assert !@process_log.exists?(:one), "There should not be a log for :one yet"
      test_one
      assert @process_log.exists?(:one), "There should be log for :one"
    end
  end
end
