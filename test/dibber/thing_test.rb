require 'test_helper'
require_relative 'thing'

module Dibber

  class ThingTest < Minitest::Test

    def teardown
      Thing.clear_all
    end

    def test_find_or_initialize_by_name
      @name = 'foo'
      @thing = Thing.find_or_initialize_by(name: @name)
      assert_equal(@name, @thing.name)
    end

    def test_find_or_initialize_by_name_with_symbol
      test_find_or_initialize_by_name
      assert_equal(1, Thing.count)
      thing = Thing.find_or_initialize_by(name: :foo)
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
      Thing.find_or_initialize_by(name: :thing_for_count_test)
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
      thing = Thing.find_or_initialize_by(name: :thing_for_save_test)
      assert !Thing.saved.include?(thing), 'saved things should not include thing'
      assert thing.save, 'should return true on save'
      assert Thing.saved.include?(thing), 'saved things should include thing'
      thing.save
      assert_equal(1, Thing.saved.select{|t| t == thing}.length)
    end

    def test_clear
      test_find_or_initialize_by_name
      @thing.save
      refute_equal(0, Thing.count)
      refute_equal([], Thing.saved)
      Thing.clear_all
      assert_equal(0, Thing.count)
      assert_equal([], Thing.saved)
    end

    def test_find_or_initialize_by_other_method
      thing = Thing.find_or_initialize_by(other_method: :something)
      assert_nil(thing.name)
      assert_equal('something', thing.other_method)
    end

  end

end
