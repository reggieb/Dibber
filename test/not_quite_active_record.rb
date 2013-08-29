# Mock ActiveRecord::Base
class NotQuiteActiveRecord
  attr_reader :name
  attr_accessor :attributes

  def initialize(name = nil)
    @name = name.to_s if name
    self.class.members << self
  end

  def save
    self.class.saved << self if new_record?
    true
  end

  def new_record?
    !self.class.saved.include? self
  end

  def self.find_or_initialize_by_name(name)
    existing = members.select{|m| m.name == name.to_s}
    if existing.empty?
      new(name)
    else
      existing.first
    end
  end

  def self.find_or_initialize_by_title(title)
    existing = members.select{|m| m.title == title.to_s}
    if existing.empty?
      fee = new
      fee.title = title
      fee
    else
      existing.first
    end
  end

  def self.find_or_create_by_name(name)
    find_or_initialize_by_name(name).save
  end

  def self.find_or_initialize_by_other_method(data)
    existing = members.select{|m| m.other_method == data.to_s}
    if existing.empty?
      thing = new
      thing.other_method = data.to_s
      thing
    else
      existing.first
    end
  end

  def self.exists?(hash)
    !members.select{|m| m.send(hash.first[0]) == hash.first[1].to_s}.empty?
  end

  def self.create!(hash)
    new(hash).save
  end

  def self.members
    @members ||= []
  end

  def self.count
    members.length
  end

  def self.saved
    @saved ||= []
  end

  def self.clear_all
    @members = []
    @saved = []
  end
end
