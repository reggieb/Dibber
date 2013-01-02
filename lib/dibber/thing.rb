class Thing
  attr_reader :name
  attr_accessor :attributes, :other_method
  
  def initialize(name = nil)
    @name = name.to_s if name
    self.class.members << self
  end
  
  def save
    self.class.saved << self unless self.class.saved.include? self
    true
  end
  
  def self.find_or_initialize_by_name(name)
    existing = members.select{|m| m.name == name.to_s}
    if existing.empty?
      new(name)
    else
      existing.first
    end
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
end
