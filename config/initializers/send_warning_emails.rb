### Here we spawn a thread that sends warning emails on their set intervals ###

# You may modify this to your needs
conditions = [
  # Only send emails on production
  Rails.env.production?,

  # Don't send emails from rails console sessions
  !defined?(Rails::Console),

  # Don't send emails from rake tasks
  $0 !~ /rake$/
]

WarningEmail.spawn_sender_thread if conditions.all?
