require "fastercsv"

namespace :db do
  namespace :import do
    desc "Import CSV data form a file for a given model; usage: db:import:csv MODEL=model_name CSV=csv_file_path FIELDS=field1_name,field2_name,... PURGE=boolean"
    task :csv => :environment do
      model   = ENV['MODEL']
      path    = ENV['CSV']
      fields  = ENV['FIELDS'] || true
      purge   = ENV['PURGE']
      headers = true


      raise ArgumentError, "You must specify the destination model using MODEL=" if model.nil?
      raise ArgumentError, "You must specify the CSV file path using PATH=" if path.nil?
      
      csv = FasterCSV.read(path, {:headers => fields})
      model = model.singularize.camelize.constantize
      
      if purge == 'true'
        STDOUT.puts "Purging #{model}..."
        model.destroy_all
      end
      
      STDOUT.puts "Importing CSV..."
      line_number = 1
      csv.each do |row|
        record = model.create(row.to_hash)
        
        unless record.errors.empty?
          STDERR.puts "Line #{line_number} can be imported:"
          record.errors.each_full { |msg| STDERR.puts msg }
        end
        
        line_number += 1
      end
      
      STDOUT.puts "Importation done."
    end
  end
  
  namespace :export do
    
  end
end
