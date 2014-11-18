namespace :clamour do
  desc 'Subscribe for Clamour messages'
  task :subscribe => :environment do
    require 'clamour'
    Clamour::Subscription.new.perform
  end
end
