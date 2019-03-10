desc "This task is called by the Heroku scheduler add-on"
task send_stories: :environment do
  warn "Sending the top stories written 20 days ago"
  StoryFetcher.new.call
  warn "done."
end
