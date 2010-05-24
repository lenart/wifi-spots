namespace :db do
  desc "Backup the database to a file. Options: DIR=base_dir RAILS_ENV=production MAX=20"
  task :backup => [:environment] do
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    base_path = ENV["DIR"] || "db"
    backup_base = File.join(base_path, 'backup')
    backup_folder = File.join(backup_base, datestamp)
    backup_file = File.join(backup_folder, "#{RAILS_ENV}_dump.sql.gz")
    FileUtils.mkpath(backup_folder)

    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    sh "mysqldump -u #{db_config['username']} -p#{db_config['password']} -Q --add-drop-table #{db_config['database']} | gzip -c > #{backup_file}"

    dir = Dir.new(backup_base)
    all_backups = dir.entries[2..-1].sort.reverse
    puts "Created backup: #{backup_file}"
    max_backups = ENV["MAX"] || 20
    unwanted_backups = all_backups[max_backups.to_i..-1] || []
    for unwanted_backup in unwanted_backups
      FileUtils.rm_rf(File.join(backup_base, unwanted_backup))
      puts "deleted #{unwanted_backup}"
    end
    puts "Deleted #{unwanted_backups.length} backups, #{all_backups.length - unwanted_backups.length} backups available" 
  end
end