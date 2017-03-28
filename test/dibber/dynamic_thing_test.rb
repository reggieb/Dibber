require 'test_helper'
require_relative 'thing'

module Dibber
  class DynamicThingTest < Minitest::Test

    def setup
      Seeder.seeds_path = File.join(File.dirname(__FILE__), 'seeds')
    end


    def test_objects_from
      hash = Seeder.objects_from('dynamic_things.yml')
      assert_equal 'something', hash['one']['title']
    end

  end
end
