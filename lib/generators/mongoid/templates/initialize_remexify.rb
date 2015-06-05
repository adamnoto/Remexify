Remexify.setup do |config|
  config.model = <%= class_name %>
  config.model_owner = <%= class_name %>Owners

  # uncomment lines bellow if you want to out list mongoid. add other similar lines
  # for other libraries if you wish.
  config.censor_strings << "mongoid"
end
