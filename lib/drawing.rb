require 'flag_shih_tzu'

class Drawing < Product
	
  include FlagShihTzu

  has_flags 1 => :awesome,
            2 => :the_best,
            3 => :great,
            :check_for_column => false


  def get_score
    self.awesome = true
    self.great = true
    10
  end
  def self.get_data(product)
    raise "Must be implemented"
  end

end