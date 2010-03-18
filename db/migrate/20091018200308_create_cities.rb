class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities, :force => true do |t|
      t.string :name
      t.column :lat, :double
      t.column :lng, :double
    end
    
    City.reset_column_information
                
    City.create :name => "Ljubljana",       :lat => 46.051244, :lng => 14.503061
    City.create :name => "Maribor",         :lat => 46.55858,  :lng => 15.65105
    City.create :name => "Celje",	          :lat => 46.234512, :lng => 15.269367
    City.create :name => "Kranj",           :lat => 46.233634, :lng => 14.35066
    City.create :name => "Velenje",         :lat => 46.357621, :lng => 15.113233
    City.create :name => "Koper",           :lat => 45.54108,  :lng => 13.72723
    City.create :name => "Novo mesto",      :lat => 45.80238,  :lng => 15.17047
    City.create :name => "Ptuj",            :lat => 46.4254,   :lng => 15.87791
    City.create :name => "Jesenice",        :lat => 46.436364, :lng => 14.056428
    City.create :name => "Trbovlje",        :lat => 46.15626,  :lng => 15.05446
    City.create :name => "Nova Gorica",     :lat => 45.959403, :lng => 13.650804
    City.create :name => "Murska Sobota",   :lat => 46.66106,  :lng => 16.161955
  end

  def self.down
    drop_table :cities
  end
end