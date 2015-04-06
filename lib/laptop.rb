require 'flag_shih_tzu'

class Laptop < Product
  include FlagShihTzu

  has_flags 1 => :awesome,
            2 => :the_best,
            3 => :great,
            :check_for_column => false


  def self.get_score(product)
    10
    self.awesome = true
    self.great = false
  end

  def self.get_data(product)
    raise "Must be implemented"
  end

end