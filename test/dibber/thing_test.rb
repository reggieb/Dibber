$:.unshift File.join(File.dirname(__FILE__),'../..','lib')

require 'test/unit'
require 'dibber/thing'

module Dibber

  class ThingTest < Test::Unit::TestCase
    
    def teardown
      Thing.clear_all
    end
    
    def test_find_or_initialize_by_name
      @name = 'foo'
      @thing = Thing.find_or_initialize_by_name(@name)
      assert_equal(@name, @thing.name)
    end
    
    def test_find_or_initialize_by_name_with_symbol
      test_find_or_initialize_by_name
      assert_equal(1, Thing.count)
      thing = Thing.find_or_initialize_by_name(:foo)
      assert_equal(1, Thing.count)
      assert_equal('foo', thing.name)
    end
    
    def test_find_or_initialize_by_name_when_thing_exists
      test_find_or_initialize_by_name
      test_find_or_initialize_by_name
      assert_equal(1, Thing.count)
    end
    
    def test_count
      assert_equal(0, Thing.count)
      Thing.find_or_initialize_by_name(:thing_for_count_test)
      assert_equal(1, Thing.count)
    end
    
    def test_attributes
      stuff = %w{this that}
      test_find_or_initialize_by_name
      @thing.attributes = stuff
      assert_equal(stuff, @thing.attributes)
    end
    
    def test_other_method
      stuff = %w{come home mother}
      test_find_or_initialize_by_name
      @thing.other_method = stuff
      assert_equal(stuff, @thing.other_method)
    end
    
    def test_save_and_saved
      thing = Thing.find_or_initialize_by_name(:thing_for_save_test)
      assert !Thing.saved.include?(thing), 'saved things should not include thing'
      assert thing.save, 'should return true on save'
      assert Thing.saved.include?(thing), 'saved things should include thing'
      thing.save
      assert_equal(1, Thing.saved.select{|t| t == thing}.length)
    end
    
    def test_clear
      test_find_or_initialize_by_name
      @thing.save
      assert_not_equal(0, Thing.count)
      assert_not_equal([], Thing.saved)
      Thing.clear_all
      assert_equal(0, Thing.count)
      assert_equal([], Thing.saved)
    end
    
    
  end

end
