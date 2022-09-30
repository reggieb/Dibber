require 'active_support/inflector'
require 'yaml'
require 'erb'

module Dibber
  class Seeder
    attr_accessor :klass, :file, :attribute_method, :name_method, :overwrite

    class << self

      def seed(klass, args = {}, &block)
        if klass.kind_of?(String) || klass.kind_of?(Symbol)
          name = klass.to_s.underscore
          class_name = klass.to_s.strip.classify
          klass = Kernel.const_get(class_name)
        else
          name = klass.to_s.underscore
        end
        new_file = "#{name.pluralize}.yml"
        new(klass, new_file, args).build(&block)
      end

      def process_log
        @process_log ||= start_process_log
      end

      def clear_process_log
        @process_log = nil
      end

      def report
        process_log.report + error_report
      end

      def monitor(klass)
        log_name = klass.to_s.tableize.to_sym
        unless process_log.exists?(log_name)
          process_log.start(log_name, "#{klass}.count")
        end
      end

      def objects_from(file)
        YAML.load erb_processed(file_content(file))
      end

      def erb_processed(content)
        ERB.new(content).result
      end

      def file_content(file)
        File.read File.join(seeds_path, file)
      end

      def seeds_path
        @seeds_path || try_to_guess_seeds_path || raise_no_seeds_path_error
      end

      def seeds_path=(path)
        @seeds_path = add_trailing_slash_to(path)
      end
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
      objects.map do |name, attributes|
        object = find_or_initialize_by(name)
        if overwrite or object.new_record?
          object.send("#{attribute_method}=", attributes)
          yield(object) if block_given?
          unless object.save
            self.class.errors << object.errors
          end
        end
        object
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
    def self.start_process_log
      process_log = ProcessLog.new
      process_log.start :time, 'Time.now.strftime("%Y-%b-%d %H:%M:%S.%3N %z")'
      return process_log
    end

    def self.raise_no_seeds_path_error
      raise "You must set the path to your seed files via Seeder.seeds_path = 'path/to/seed/files'"
    end

    def check_objects_exist
      raise "No objects returned from file: #{self.class.seeds_path}#{file}" unless objects
    end

    def find_or_initialize_by(name)
      if klass.exists?(name_method_sym => name)
        klass.where(name_method_sym => name).first
      else
        klass.new(name_method_sym => name)
      end
    end

    def name_method_sym
      name_method.to_sym
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
