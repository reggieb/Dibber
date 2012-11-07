require_relative 'process_log'

process_log = ProcessLog.new
process_log.start :time_one, 'Time.now'
sleep(2)
process_log.finish :time_one

process_log.start :time_two, 'Time.now'
sleep(4)

puts "\nReport:"
puts process_log.report
puts "\nRaw:"
p process_log.raw
puts "\n"
