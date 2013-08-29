require_relative '../../not_quite_active_record'

class Fee < NotQuiteActiveRecord
  attr_accessor :description, :value, :title
end
