require 'active_support/inflector'
require 'yaml'

module Dibber
  class Seeder
    attr_accessor :klass, :file, :attribute_method, :name_method, :overwrite

    def self.seed(name, args = {})
      class_name = name.to_s.strip.classify
      new_klass = (/\A\w+(::\w+)+\Z/ =~ class_name) ? eval(class_name) : Kernel.const_get(class_name)
      new_file = "#{name.to_s.pluralize}.yml"
      new(new_klass, new_file, args).build
    end

    def self.process_log
      @process_log || start_process_log
    end

    def self.start_process_log
      @process_log = ProcessLog.new
      @process_log.start :time, 'Time.now.strftime("%Y-%b-%d %H:%M:%S.%3N %z")'
      return @process_log
    end

    def self.report
      process_log.report + error_report
    end

    def self.monitor(klass)
      log_name = klass.to_s.tableize.to_sym
      unless process_log.exists?(log_name)
        process_log.start(log_name, "#{klass}.count")
      end
    end

    def self.objects_from(file)
      YAML.load_file("#{seeds_path}#{file}")
    end

    def self.seeds_path
      @seeds_path || try_to_guess_seeds_path || raise_no_seeds_path_error
    end

    def self.seeds_path=(path)
      @seeds_path = add_trailing_slash_to(path)
    end

    def initialize(klass, file, args = {})
      @klass = klass
      @file = file
      args = {:attributes_method => args} unless args.kind_of?(Hash)
      @attribute_method = args[:attributes_method] || 'attributes'
      @name_method = args[:name_method] || 'name'
      @overwrite = args[:overwrite]
    end

    def build
      check_objects_exist
      start_log
      objects.each do |name, attributes|
        object = klass.send(retrieval_method, name)
        if overwrite or object.new_record?
          object.send("#{attribute_method}=", attributes) 
          unless object.save
            self.class.errors << object.errors
          end
        end
      end
    end

    def start_log
      self.class.monitor(klass)
    end

    def objects
      @objects ||= self.class.objects_from(file)
    end

    def self.errors
      @errors ||= []
    end

    def self.error_report
      return [] if errors.empty?
      ["#{errors.length} errors detected:", errors.collect(&:inspect)].flatten
    end

    private
    def self.raise_no_seeds_path_error
      raise "You must set the path to your seed files via Seeder.seeds_path = 'path/to/seed/files'"
    end
    
    def check_objects_exist
      raise "No objects returned from file: #{self.class.seeds_path}#{file}" unless objects
    end
    
    def retrieval_method
      "find_or_initialize_by_#{name_method}"
    end

    def self.try_to_guess_seeds_path
      path = File.expand_path('db/seeds', Rails.root) if defined? Rails
      add_trailing_slash_to(path)
    end


    def self.add_trailing_slash_to(path = nil)
      path = path + '/' if path and path !~ /\/$/
      path
    end

  end
end