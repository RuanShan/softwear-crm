require 'travis'

namespace :travis do
  desc "Wait until other Travis CI builds are done, and deploy if they succeeded."
  task deploy_on_success: :environment do
    branch = ENV['TRAVIS_BRANCH']
    if branch != 'master'
      puts "TRAVIS_BRANCH wasn't master (\"#{branch}\" instead) - not deploying"
      next
    end

    build_id = ENV['TRAVIS_BUILD_ID']
    job_id   = ENV['TRAVIS_JOB_ID']

    if build_id.blank?
      fail "Expected TRAVIS_BUILD_ID environment variable to be present."
    end
    if job_id.blank?
      fail "Expected TRAVIS_JOB_ID environment variable to be present."
    end

    build = Travis::Build.find(build_id)

    loop do
      what_to_do = :dont_deploy

      build.reload.jobs.each do |job|
        case job.state
        when 'failed', 'errored'
          what_to_do = :dont_deploy
          puts "A job failed"
          break
        when 'started', 'received'
          what_to_do = :wait
          puts "A job is still in progress - wating 2 minutes"
          break
        when 'passed'
          what_to_do = :deploy
          puts "Job ##{job.number} looks good"
        else
          puts "UNKNOWN JOB STATE: #{job.state}"
          what_to_do = :dont_deploy
        end
      end

      case what_to_do
      when :deploy
        exec 'bundle exec softwear-deploy'
      when :dont_deploy
        fail "Not all jobs passed - not deploying"
      when :wait
        sleep 2.minutes
      else
        fail "do what? #{what_to_do.inspect}"
      end
    end
  end
end