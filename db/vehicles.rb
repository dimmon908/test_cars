#encoding: utf-8
if Vehicle::where(:name => 'Mercedes SUV Black Car').any?
  Vehicle.update(Vehicle::where(:name => 'Mercedes SUV Black Car').all[0].id,{:name => 'Mercedes SUV Black Car', :internal_name => :mercedes_suv,  :desc => 'Black SUV', :photo => '/img/cars/vehicle1.png', :passengers => 6, :sort_order => 1, :rate => 7})
else
  Vehicle.create :name => 'Mercedes SUV Black Car', :internal_name => :mercedes_suv,  :desc => 'Black SUV', :photo => '/img/cars/vehicle1.png', :passengers => 6, :sort_order => 1, :rate => 7
end

if Vehicle::where(:name => 'Tesla Electronic Car').any?
  Vehicle.update(Vehicle::where(:name => 'Tesla Electronic Car').first.id,{:name => 'Tesla S Electric Car', :internal_name => :tesla_car,:desc => 'Black Luxury Sedan', :photo => '/img/cars/vehicle3.png', :passengers => 4, :sort_order => 2, :rate => 12})
elsif Vehicle::where(:internal_name => :tesla_car).any?
  Vehicle.update(Vehicle::where(:internal_name => :tesla_car).first.id,{:name => 'Tesla S Electric Car', :internal_name => :tesla_car,:desc => 'Black Luxury Sedan', :photo => '/img/cars/vehicle3.png', :passengers => 4, :sort_order => 2, :rate => 12})
else
  Vehicle.create :name => 'Tesla S Electric Car', :internal_name => :tesla_car,:desc => 'Black Luxury Sedan', :photo => '/img/cars/vehicle3.png', :passengers => 4, :sort_order => 2, :rate => 12
end

if Vehicle::where(:name => '12 Passengers Sprinter').any?
  Vehicle.update(Vehicle::where(:name => '12 Passengers Sprinter').all[0].id,{:name => '12 Passengers Sprinter', :internal_name => :sprinter, :desc => 'Black van', :photo => '/img/cars/vehicle2.png', :passengers => 12, :sort_order => 3, :rate => 100})
elsif Vehicle::where(:name => '16 Passengers Sprinter').any?
  Vehicle.update(Vehicle::where(:name => '16 Passengers Sprinter').all[0].id,{:name => '12 Passengers Sprinter', :internal_name => :sprinter, :desc => 'Black van', :photo => '/img/cars/vehicle2.png', :passengers => 12, :sort_order => 3, :rate => 100})
else
  Vehicle.create :name => '12 Passengers Sprinter', :internal_name => :sprinter, :desc => 'Black van', :photo => '/img/cars/vehicle2.png', :passengers => 12, :sort_order => 3, :rate => 100
end