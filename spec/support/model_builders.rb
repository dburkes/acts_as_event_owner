def attributes_for_event_specification(overrides={})
  {
    :description => 'do something'
  }.merge(overrides)
end

def new_event_specification(overrides={})
  ActsAsEventOwner::EventSpecification.new(attributes_for_event_specification(overrides))
end

def create_event_specification(overrides={})
  ActsAsEventOwner::EventSpecification.create(attributes_for_event_specification(overrides))
end