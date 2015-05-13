# app/jobs/test_job.rb
class Retrieval < ActiveJob::Base
  def perform
    # put you scheduled code here
    # Comments.deleted.clean_up...
    puts "hello crono!"
  end
end