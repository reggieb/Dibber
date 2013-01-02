$:.unshift File.join(File.dirname(__FILE__),'../..','lib')

require 'test/unit'
require 'dibber/thing'

module Dibber

  class ThingTest < Test::Unit::TestCase
    
    def test_find_or_initialize_by_name
      @name = 'foo'
      @thing = Thing.find_or_initialize_by_name(@name)
      assert_equal(@name, @thing.name)
    end
    
    def test_find_or_initialize_by_name_when_thing_exists
      test_find_or_initialize_by_name
      things_before = thing_count
      test_find_or_initialize_by_name
      things_after = thing_count
      assert_equal(things_before, things_after)
    end
    
    def test_count
      assert_equal(thing_count, Thing.count)
      Thing.find_or_initialize_by_name(:thing_for_count_test)
      assert_equal(thing_count, Thing.count)
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
    
    private
    def thing_count
      ObjectSpace.each_object(Thing).to_a.length
    end
    
  end

end
