require 'sqlite3'
require 'prawn'
require 'date'

if ARGV[0]
  phone_number = ARGV[0]
else
  puts "Error: A phone number is required to run the script.\n"
  exit
end

base_location = "/Users/" << ENV['USER'] << "/Library/Application\\ Support/MobileSync/Backup/"

# Find the last backup folder
cmd = "cd " << base_location << " && ls -t1 | head -n1"
backup_directory = %x[ #{cmd} ]

# Copy the message document to a temporary database
cmd = "cp " + base_location << backup_directory.split.join("\n") << "/3d0d7e5fb2ce288813306e4d4636395e047a3d28 temp.db"
%x[ #{cmd} ]

# Open the temp database
db = SQLite3::Database.new('temp.db')
db.results_as_hash = true

handles = []

# Find the account_guid of the phone number passed in (there may be more than one for seperate iMessage and SMS purposes)
db.execute("SELECT * FROM handle") do |row|
  if row['id'].include? phone_number
    handles << "'#{row['ROWID']}'"
  end
end

# Create a document with the name of the phone number
Prawn::Document.generate(phone_number + ".pdf") do

  # Search for all messages with one of the handles
  db.execute("select date, is_from_me, service, text, account_guid from message where handle_id IN (#{handles.join(',')})") do |row|
      # Mac uses Mac Absolute Time (MacTime). This is counted from 01-01-2001, need to add 31 years!
      date = row['date'] + 978307200
      message_date = Time.at(date).strftime("%a, %b %e, %Y at %I:%M%p")
      font "fonts/OpenSans-Regular.ttf"

      # Bump to the next pageif the cursor overflows
      if cursor < 150
        start_new_page
      end

      if row['text']

        # Create a text bubble of its from the recipient
        if row['is_from_me'] == 0

          rounded_rectangle [0,cursor+20], 220, 150, 10

          bounding_box [10,cursor], :width => 200 do
            fill_color 'F0F0F0'
            fill
            move_down 2
            fill_color '000000'
            text message_date
            move_down 5
            text row['text']
            move_down 20
          end

        # Create a text bubble of its from me
        else

          rounded_rectangle [bounds.right - 210,cursor+20], 220, 150, 10

          bounding_box [bounds.right - 200,cursor], :width => 200 do
            fill_color '66CC33'
            fill
            move_down 2
            fill_color '000000'
            text message_date
            move_down 5
            text row['text']
            move_down 20
          end

        end

      end
  end
end

# Destroy the database
cmd = "rm temp.db"
%x[ #{cmd} ]

puts "#{phone_number}.pdf created"
