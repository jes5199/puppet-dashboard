class ResourceEvent < ActiveRecord::Base
  belongs_to :resource_status

  # These get stored as YAML documents, so that they preserve type
  # (Puppet values may be strings, integers, arrays, hashes, etc)
  serialize :desired_value
  serialize :previous_value
  serialize :historical_value
end
