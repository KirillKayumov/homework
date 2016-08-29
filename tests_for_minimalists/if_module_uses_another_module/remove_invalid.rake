require "tasks/support/remove_invalid_accounts"

namespace :accounts do
  desc "Remove invalid accounts having no owner"
  task :remove_invalid => :environment do
    RemoveInvalidAccounts.new.perform
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"
require "rake"

describe "Rake task RemoveInvalidAccounts" do
  before do
    Rake.application.rake_require "tasks/support/remove_invalid_accounts"
    Rake::Task.define_task(:environment)
  end

  it "performs RemoveInvalidAccounts" do
    expect_any_instance_of(RemoveInvalidAccounts).to receive(:perform)

    Rake::Task["accounts:remove_invalid"].execute
  end
end
