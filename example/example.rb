class Sandwich
  attr_accessor :id
  private :id=

  def initialize id
    self.id = id
    self.bread = "Brown"
    self.fillings = %w(mayo chicken salad)
    self.name = "Chicken Mayo Salad"
    self.made_at = Time.now
  end

  attr_accessor :fillings
  attr_accessor :bread
  attr_accessor :name
  attr_accessor :made_at
end

class SandwichResource
  include AcceptableApi::Controller

  def show_sandwich
    # Normally this would be a database lookup but since this is just an
    # example I create a new instance to keep things simple
    Sandwich.new params[:id]
  end
end
