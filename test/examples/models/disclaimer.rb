require_relative '../../not_quite_active_record'
module Disclaimer
  class Document < NotQuiteActiveRecord
    attr_accessor :title, :header, :footer
  end
end
