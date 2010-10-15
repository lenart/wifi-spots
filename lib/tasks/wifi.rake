namespace :wifi do
  
  desc "Import items from Google Maps RSS feed"
  task :import_gmaps => :environment do
    Spot.import_from_gmaps_rss
  end
  
  desc 'Alias for wifi:import_gmaps'
  task :im => 'wifi:import_gmaps'
  
end