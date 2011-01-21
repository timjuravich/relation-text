require 'sqlite3'
require 'prawn'

if ARGV[0]
  number = ARGV[0]
else
  puts "Error: A number is required to run the script.\n"
  exit
end

base_location = "/Users/" << ENV['USER'] << "/Library/Application\\ Support/MobileSync/Backup/"

cmd = "cd " << base_location << " && ls -t1 | head -n1"
backup_directory = %x[ #{cmd} ]

cmd = "cp " + base_location << backup_directory.split.join("\n") << "/3d0d7e5fb2ce288813306e4d4636395e047a3d28 temp.db"
%x[ #{cmd} ]

db = SQLite3::Database.new('temp.db')
db.results_as_hash = true

Prawn::Document.generate(number + ".pdf") do
  
  db.execute("select datetime(date, 'unixepoch') as message_date, text, flags from message where address like '%" << number << "%'") do |row|
      
      if cursor < 150
        start_new_page
      end
      
      if row['text']
        if row['flags'] == 2
          
          rounded_rectangle [0,cursor+20], 220, 150, 10
          
          bounding_box [10,cursor], :width => 200 do
            fill_color 'F0F0F0'
            fill
            move_down 2
            fill_color '000000'
            text row['message_date']
            move_down 5
            text row['text']
            move_down 20
          end
        
        elsif row['flags'] == 3      
          
          rounded_rectangle [bounds.right - 210,cursor+20], 220, 150, 10
          
          bounding_box [bounds.right - 200,cursor], :width => 200 do
            fill_color '66CC33'
            fill
            move_down 2
            fill_color '000000'
            text row['message_date']
            move_down 5
            text row['text']
            move_down 20
          end
          
        end
        
      end
  end
end

cmd = "rm temp.db"
%x[ #{cmd} ]