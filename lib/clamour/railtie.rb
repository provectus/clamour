class Clamour::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/clamour_subscribe.rake'
  end
end
