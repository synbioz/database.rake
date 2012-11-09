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

        unless record.valid?
          STDERR.puts "Line #{line_number} can be imported:"
          STDERR.puts record.errors.full_messages.join("\n")
        end

        line_number += 1
      end

      STDOUT.puts "Importation done."
    end
  end

  namespace :export do
    desc "Export given model data into CSV file; usage: db:export:csv MODEL=model_name [CSV=csv_file_path]"
    task :csv => :environment do
      model = ENV['MODEL']

      raise ArgumentError, "You must specify the destination model using MODEL=" if model.nil?
      model = model.singularize.camelize.constantize
      path  = ENV['CSV'] || "#{model.to_s.tableize}.csv"

      STDOUT.puts "Exporting data..."

      FasterCSV.open(path, "w", {:force_quotes => true}) do |csv|
        csv << model.column_names
        model.all.each do |record|
          values = model.column_names.map { |column| record.send(column) }
          csv << values
        end
      end

      STDOUT.puts "Data exported..."
    end

    desc 'Dumps all models into fixtures.'
    task :fixtures => :environment do
      verbose = ENV['VERBOSE'].present?

      models = Dir.glob(Rails.root.join('app', 'models', '*.rb')).inject([]) do |acc, f|
        acc << File.basename(f).gsub(".rb", "")
      end

      models.each do |m|
        STDOUT.puts "Dumping model: #{m}" if verbose
        model = m.camelcase.constantize

        if ActiveRecord::Base == model.superclass
          model_file = File.join(Rails.root, 'spec', 'fixtures', "#{model.table_name}.yml")

          File.delete(model_file) if File.exists?(model_file)

          f = File.open(model_file, 'w')
          str, index, tab, end_line = '', 1, '  ', "\n"
          f << "#encoding: utf-8\n"
          model.find_each do |object|
            STDOUT.puts "Writing #{model} ##{object.id}" if verbose
            str = "#{m}_#{index}:#{end_line}"

            object.attributes.each do |column, value|
              # attribute is not always a column. Ex: globalize.
              next unless model.columns_hash.has_key?(column)
              column_type = model.columns_hash[column].type

              if [:date, :datetime].include?(column_type)
                value = value.try(:strftime, "%Y-%m-%d %H:%M:%S")
              elsif column_type == :boolean
                value = if value.nil?
                  nil
                else
                  value ? 1 : 0
                end
              elsif [:text, :string].include?(column_type)
                value = "\"#{value.gsub("\"", "\\\"")}\"" unless value.nil?
              end

              str += "#{tab}#{column}: #{value}#{end_line}"
            end
            index += 1
            str   += end_line
            f     << str
          end
          f.close
        end
      end
    end

    namespace :csv do
      desc "Export all models data into many CSV files; usage: db:export:csv:all"
      task :all => :environment do
        Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
        models = Object.subclasses_of(ActiveRecord::Base)

        STDOUT.puts "Exporting all models..."

        models.each do |model|
          path  = "#{model.to_s.tableize}.csv"

          FasterCSV.open(path, "w", {:force_quotes => true}) do |csv|
            csv << model.column_names
            model.all.each do |record|
              values = model.column_names.map { |column| record.send(column) }
              csv << values
            end
          end
        end

        STDOUT.puts "#{models.size} models exported..."
      end
    end
  end
end
