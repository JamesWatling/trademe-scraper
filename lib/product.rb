require 'active_record'

class Product < ActiveRecord::Base

  def self.get_score(data)
    raise "Must be implemented"
  end

  def self.get_data(data)
    raise "Must be implemented"
  end
  
end