require 'rake'

# Do not re-load the environment task
class Rake::Task
  def invoke_prerequisites(task_args, invocation_chain)
    @prerequisites.reject{|n| n == "environment"}.each do |n|
      prereq = application[n, @scope]
      prereq_args = task_args.new_scope(prereq.arg_names)
      prereq.invoke_with_call_chain(prereq_args, invocation_chain)
    end
  end
end

When /^I run the rake task "([^\"]*)"$/ do |task_name|
  # Make sure you're in the RAILS_ROOT
  oldpwd = Dir.pwd
  Dir.chdir(RAILS_ROOT)
  old_args = ARGV.dup
  ARGV.clear

  # Get an instance of rake
  rake_app = Rake.application
  rake_app.options.silent = true

  # Back to where you were
  Dir.chdir(oldpwd)

  rake_app.init
  rake_app.load_rakefile

  task = rake_app.tasks.detect {|t| t.name == task_name}
  assert_not_nil task, "No rake task defined: #{task_name}"
  task.reenable
  task.invoke

  ARGV.unshift(*old_args)
end

