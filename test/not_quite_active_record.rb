# Mock ActiveRecord::Base
class NotQuiteActiveRecord
  attr_accessor :name, :title, :other_method, :attributes

  def initialize(args = {})
    @attributes = args
    extract_attributes
    self.class.members << self
  end
  
  def extract_attributes
    attributes.each do |name, value|
      self.send("#{name}=", value.to_s) if self.respond_to?(name.to_sym)
    end
  end

  def save
    self.class.saved << self if new_record?
    true
  end

  def new_record?
    !self.class.saved.include? self
  end
  
  def self.where(hash)
    members.select{|m| hash.collect{|k, v| m.send(k) == v.to_s}.uniq == [true]}
  end
  
  def self.find_or_initialize_by(hash)
    if exists?(hash)
      where(hash).first
    else
      new(hash)
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
