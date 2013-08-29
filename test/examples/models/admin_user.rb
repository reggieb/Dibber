require_relative '../../not_quite_active_record'

class AdminUser < NotQuiteActiveRecord
  attr_accessor :title, :header, :footer
end
