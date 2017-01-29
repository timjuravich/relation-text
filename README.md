A quick ruby script to grab the texts on your iPhone from the backups on your computer and print them in a PDF.

To get the latest text messages, you should sync your iPhone first. This script checks the backup folders that are created each time you sync your phone. It does not save anything externally or alter anything that is inside of these directories.

Warning: This script will only work on OSX and if you have an iPhone that you sync with that computer. It has not been tested extensively, but will work with all iOS 10 devices.

Requirements: Ruby, RubyGems, sqlite3, prawn

#Installation#
bundle install

#How To Use:#
ruby relation-text.rb {phone number}

#Example:#
ruby relation-text.rb 8675309

Enter the digits of the phone number that you want to grab the texts of. Once complete, a PDF will be created in the same directory as the script. If there are many texts it may take a while and will create a large PDF.
