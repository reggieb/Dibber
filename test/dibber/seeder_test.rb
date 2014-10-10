$:.unshift File.join(File.dirname(__FILE__),'../..','lib')

require 'test/unit'
require 'dibber'
require_relative 'thing'

module Dibber

  class SeederTest < Test::Unit::TestCase

    def setup
      Seeder.seeds_path = File.join(File.dirname(__FILE__), 'seeds')
    end

    def teardown
      Thing.clear_all
    end

    def test_process_log
      assert_kind_of(ProcessLog, Seeder.process_log)
    end

    def test_process_log_start
      @log = Seeder.process_log
      assert(@log.raw.keys.include?(:time), 'time should be logged')
    end

    def test_report
      test_process_log_start
      assert_equal(@log.report, Seeder.report)
    end

    def test_monitor
      Seeder.monitor(Thing)
      assert_equal({:command => 'Thing.count', :start => Thing.count}, Seeder.process_log.raw[:things])
    end

    def test_seeds_path
      assert_match(/test\/dibber\/seeds\/$/, Seeder.seeds_path)
    end

    def test_objects_from
      content = YAML.load_file(thing_file_path)
      assert_equal(content, Seeder.objects_from('things.yml'))
    end

    def test_start_log
      thing_seeder.start_log
      assert(Seeder.process_log.raw.keys.include?(:things), 'Things should be logged')
    end

    def test_objects
      content = YAML.load_file(thing_file_path)
      assert_equal(content, thing_seeder.objects)
    end

    def test_build_with_no_objects
      thing_seeder = Seeder.new(Thing, 'empty.yml')
      assert_raise RuntimeError do
        thing_seeder.build
      end
    end

    def test_build
      assert_equal(0, Thing.count)
      thing_seeder.build
      assert_equal(2, Thing.count)
      foo = Thing.find_or_initialize_by(name:  :foo)
      bar = Thing.find_or_initialize_by(name: :bar)
      assert_equal([foo, bar], Thing.saved)
      assert_equal({'title' => 'one'}, foo.attributes)
    end

    def test_rebuilding_does_not_overwrite
      test_build
      attributes = {'title' => 'something else'}
      foo = Thing.find_or_initialize_by(name: :foo)
      foo.attributes = attributes
      foo.save
      thing_seeder.build
      assert_equal(2, Thing.count)
      foo = Thing.find_or_initialize_by(name: :foo)
      assert_equal(attributes, foo.attributes)
    end

    def test_rebuilding_does_overwrite_if_set_to
      test_build
      attributes = {'title' => 'something else'}
      foo = Thing.find_or_initialize_by(name: :foo)
      foo.attributes = attributes
      foo.save
      thing_seeder(:overwrite => true).build
      assert_equal(2, Thing.count)
      foo = Thing.find_or_initialize_by(name: :foo)
      assert_equal({'title' => 'one'}, foo.attributes)
    end

    def test_other_method_instead_of_attributes
      thing_seeder('other_method').build
      foo = Thing.find_or_initialize_by(name: :foo)
      bar = Thing.find_or_initialize_by(name: :bar)
      assert_equal([foo, bar], Thing.saved)
      assert_equal({:name=>"foo"}, foo.attributes)
      assert_equal({'title' => 'one'}, foo.other_method)
    end

    def test_other_method_replacing_attributes_via_args
      thing_seeder(:attributes_method => 'other_method').build
      foo = Thing.find_or_initialize_by(name: :foo)
      bar = Thing.find_or_initialize_by(name: :bar)
      assert_equal([foo, bar], Thing.saved)
      assert_equal({:name=>"foo"}, foo.attributes)
      assert_equal({'title' => 'one'}, foo.other_method)
    end

    def test_alternative_name_method
      thing_seeder(:name_method => 'other_method').build
      assert_equal(2, Thing.count)
      foo = Thing.find_or_initialize_by(other_method: :foo)
      bar = Thing.find_or_initialize_by(other_method: :bar)
      assert_equal([foo, bar], Thing.saved)
      assert_equal({'title' => 'one'}, foo.attributes)
    end

    def test_seed
      assert_equal(0, Thing.count)
      Seeder.seed(:things)
      assert_equal(2, Thing.count)
      foo = Thing.find_or_initialize_by(name: :foo)
      bar = Thing.find_or_initialize_by(name: :bar)
      assert_equal([foo, bar], Thing.saved)
      assert_equal({'title' => 'one'}, foo.attributes)
    end

     def test_seed_with_alternative_name_method
      Seeder.seed(:things, :name_method => 'other_method')
      assert_equal(2, Thing.count)
      foo = Thing.find_or_initialize_by(other_method: :foo)
      bar = Thing.find_or_initialize_by(other_method: :bar)
      assert_equal([foo, bar], Thing.saved)
      assert_equal({'title' => 'one'}, foo.attributes)
    end

    def test_seed_with_non_existent_class
      assert_raise NameError do
        Seeder.seed(:non_existent_class)
      end
    end

    def test_seed_with_non_existent_seed_file
      no_file_found_error = Errno::ENOENT
      assert_raise no_file_found_error do
        Seeder.seed(:array)
      end
    end

    def test_seeds_path_with_none_set
      Seeder.seeds_path = nil
      assert_raise RuntimeError do
        Seeder.seeds_path
      end
    end

    def test_process_log_not_reset_by_second_seed_process_on_same_class
      Seeder.seed(:things)
      original_start = Seeder.process_log.raw[:things][:start]
      Seeder.seed(:things)
      assert_equal original_start, Seeder.process_log.raw[:things][:start]
    end

    module DummyRails
      def self.root
        '/some/path'
      end
    end

    def test_seeds_path_if_Rails_exists
      Dibber.const_set :Rails, DummyRails
      Seeder.seeds_path = nil
      assert_equal '/some/path/db/seeds/', Seeder.seeds_path
      Dibber.send(:remove_const, :Rails)
    end


    private
    def thing_seeder(method = 'attributes')
      @thing_seeder = Seeder.new(Thing, 'things.yml', method)
    end

    def thing_file_path
      File.join(File.dirname(__FILE__),'seeds', 'things.yml')
    end
  end

end
