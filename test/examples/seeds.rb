require_relative '../../lib/dibber'

models = %w{borough admin_user fee disclaimer category}
models.each {|model| require_relative "models/#{model}"}


Seeder = Dibber::Seeder

# Set up the path to seed YAML files
Seeder.seeds_path = File.expand_path('seeds', File.dirname(__FILE__))

# Example 1. Seeder is used to monitor the process 
# and grab the attributes from the YAML file
Seeder.monitor Borough
Seeder.objects_from("boroughs.yml").each do |holder, borough|
  Borough.find_or_create_by_name(borough)
end

# Example 2. Seeder is only used to monitor the process
Seeder.monitor AdminUser
admin_email = 'admin@undervale.co.uk'
password = 'change_me'
AdminUser.create!(
  :email => admin_email,
  :password => password,
  :password_confirmation => password
) unless AdminUser.exists?(:email => admin_email)

# Example 3. Seeder grabs the attributes from the YAML and builds a 
# set of Fee objects with those attributes (or updates them if 
# they already exist). 
# Note that the build process defaults to using a 'name' field to store 
# the root key.
Seeder.new(Fee, 'fees.yml').build

# Example 4. Seeder using an alternative name field
Seeder.new(Fee, 'fees.yml', :name_method => :title).build

# Example 5. If the seed file's name is the lower case plural of the class name
# you can use the seed method:
Seeder.seed(:fee)

# Example 6. Seeder working with a name-spaced object
Seeder.new(Disclaimer::Document, 'disclaimer/documents.yml').build

# Example 7. You can also use the seed method with name-spaced objects.
# In this case the seed files need to be in a name-spaced path (see previous
# example)
Seeder.seed('disclaimer/document')

# Example 8. Seeder using values in the yaml file to set a single field
Seeder.seed(:category, 'description')

# Example 9. Seeder using alternative name and attributes fields
Seeder.seed(
  :category,
  :name_method => :title, 
  :attributes_method => :description
)

# Example 10. You can also access Seeders attached process log, and set up a
# custom log
Seeder.process_log.start('Time to end of report', 'Time.now')

# Output a report showing how the numbers of each type of object
# have changed through the process. Also has a log of start and end time.
puts Seeder.report
