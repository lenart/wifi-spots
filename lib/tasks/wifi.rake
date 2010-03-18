namespace :wifi do
  
  desc "Import items from RSS feed"
  task :import => :environment do
    Spot.import_from_rss
  end
  
  desc 'Alias for wifi:import'
  task :im => 'wifi:import'
  
end