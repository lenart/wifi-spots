# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

Category.create :name => 'Gostinstvo čžš ČŽŠ', :description => 'Gostilne, bari, restavracije in nočni klubi'
Category.create :name => 'Javne ustanove', :description => 'Knjižnice, občine in ostale javne ustanove'
Category.create :name => 'Drugo', :description => 'Privat in ostale wifi točke'

User.create :name => "Lenart", :email => 'lenart.rudel@gmail.com',
            :password => 'admin', :password_confirmation => 'admin'
            
            
City.create :name => 'Postojna', :lat => 45.77518618352103, :lng => 14.212360382080078