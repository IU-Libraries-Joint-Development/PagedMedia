# Represent a profile for a type of Node.
# At the moment all it does (correctly) is to list the profiles, which are
# named (and eventually described) in config/object_profiles.yaml
#--
# Copyright (c) 2015 Indiana University
# All rights reserved.

require 'yaml'

class ObjectProfile
  @@PROFILES = YAML.load_file('config/object_profiles.yml')

  private_class_method :new

  def name
    NAME
  end

  # Enumerate profile names and bodies for a block, as if this were a Hash.
  def self.each
    @@PROFILES.each do |name, profile|
      yield name, profile
    end
  end

  # Return the body of the named profile.
  def self.find(name)
    @@PROFILES[name]
  end
end