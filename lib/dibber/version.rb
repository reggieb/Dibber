module Dibber
  VERSION = "0.6.0"
end

# History
# =======
# 0.6.0 ERB parse the source files before passing it to YAML. Allows dynamic
#       content to be used.
#
# 0.5.0 Allow the `Seeder.seed` method to take a Class or the string/symbol
#       representation of the class name.
#
# 0.4.0 Removes dependency on find_or_initialize_by_name type ActiveRecord
#       dynamic methods that are no longer supported in Rails
#
# 0.3.1 Adds error messages when object save fails
#
# 0.3.0 Adds seed method
#       Allows seeding to be carried out via Dibber::Seeder.seed(:thing).
#       Also tidies up examples
#
# 0.2.2 Minor bug fix. There was an error in the example. Also a small bit
#       of house keeping (adding license to gemspec, and removing Gemfile.lock
#       from repository.
#
# 0.2.1 Fixes bug in overwrite code
#       System was not correctly identifying when an object was a new record
#
# 0.2.0 Stops overwriting existing entries unless explicitly directed to
#       Now need to specify :overwrite => true when creating a new Seeder if
#       existing entries are to be overwritten.
#
# 0.1.1 Working version
#       No History before this point
#
