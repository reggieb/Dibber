module Dibber
  class Seeder
    attr_accessor :klass, :file, :method

    def self.process_log
      @process_log || start_process_log
    end

    def self.start_process_log
      @process_log = ProcessLog.new
      @process_log.start :time, 'Time.now.to_s(:long_time)'
      return @process_log
    end

    def self.report
      @process_log.report
    end

    def self.monitor(klass)
      process_log.start(klass.to_s.tableize.to_sym, "#{klass}.count")
    end

    def self.objects_from(file)
      YAML.load_file("#{seeds_path}#{file}")
    end

    def self.seeds_path
      @seeds_path || raise_no_seeds_path_error
    end

    def self.seeds_path=(path)
      path = path + '/' unless path =~ /\/$/
      @seeds_path = path
    end


    def initialize(klass, file, method = 'attributes')
      @klass = klass
      @file = file
      @method = method
    end

    def build
      start_log
      objects.each do |name, attributes|
        object = klass.find_or_initialize_by_name(name)
        object.send("#{method}=", attributes)
        object.save
      end
    end

    def start_log
      self.class.monitor(klass)
    end

    def objects
      self.class.objects_from(file)
    end

    private
    def self.raise_no_seeds_path_error
      raise "You must set the path to your seed files via Seeder.seeds_path = 'path/to/seed/files'"
    end

  end
end