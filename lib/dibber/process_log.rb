module Dibber
  class ProcessLog

    def initialize
      @log = {}
    end

    def start(name, command)
      @log[name] = {
        :start => eval(command),
        :command => command
      }
    end

    def finish(name)
      @log[name][:finish] = eval(@log[name][:command])
    end

    def raw
      @log
    end

    def report
      @report = []
      @log.each do |name, log|
        finish(name) unless @log[name][:finish]
        @report << "#{name.to_s.capitalize.gsub(/_/, ' ')} was #{log[:start]}, now #{log[:finish]}."
      end
      return @report
    end

    def exists?(name)
      @log.keys.include?(name)
    end

  end
end