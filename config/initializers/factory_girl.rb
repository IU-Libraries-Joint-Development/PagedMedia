if defined? FactoryGirl
  Dir[Rails.root.join("spec/support/*factory*.rb")].each { |f| require f }
end
