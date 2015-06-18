# The Rakefile does all of the real work.
task :default => [:github, :heroku]

desc "Run your resume locally."
task :local do
  exec('./resume.rb')
end

desc "Convert to PDF by running resume locally."
task :pdf do
  require 'socket'
  require 'timeout'

  marginTopBottom = 14
  marginLeftRight = 8
  localPort = 4567

  # Start local resume service
  p_local = fork do
    exec('./resume.rb')
  end

  # Wait for the sinatra port to open
  port_open = true
  while port_open
    sleep 0.1
    begin
      Timeout::timeout(1) do
        s = TCPSocket.new('localhost', localPort)
        s.close
        port_open = false
      end
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
      # port still closed
    end
  end

  # Convert to PDF
  p_pdf = fork do
    exec("wkhtmltopdf -T #{marginTopBottom} -B #{marginTopBottom} -L #{marginLeftRight} -R #{marginLeftRight} 'http://localhost:#{localPort}/index.html?print_pdf=1' resume.pdf")
  end
  Process.waitpid(p_pdf)

  # Kill the resume service
  Process.kill('KILL', p_local)
end

# Based off of http://railspikes.com/2010/2/13/rake-task-for-deploying-to-heroku
desc "Deploy to Heroku."
task :heroku do
  [ 'heroku', 'heroku/command', 'git' ].each {|gem|
    begin
      require gem
    rescue LoadError
      puts "The gem #{gem} is not installed.\n"
      exit
    end
  }

  puts 'Deploying to Heroku. If you haven\'t run heroku create before, this will fail.'

  # Get users credentials
  user, pass = File.read(File.expand_path("~/.heroku/credentials")).split("\n")
  heroku = Heroku::Client.new(user, pass)

  cmd = Heroku::Command::BaseWithApp.new([])
  remotes = cmd.git_remotes '.'
  remote, app = remotes.detect {|key, value| value == (ENV['APP'] || cmd.app)}

  if remote.nil?
    raise "Could not find a git remote for the '#{ENV['APP']}' app"
  end

  g = Git.open('.')
  g.push(g.remote(remote))

  heroku.rake(app, "db:migrate")
  heroku.restart(app)

  puts '--> Heroku Push successful.'
end

# TODO: Make this dynamically figure out all of the files needed from Sinatra.
desc "Deploy to remote defined in config.yaml"
task :github do
  require File.expand_path('../resume',__FILE__)
  require 'rubygems'

  # Nice Error checking for gems.
  [ 'git', 'rack/test', 'logger' ].each {|gem|
    begin
      require gem
    rescue LoadError
      puts "The gem #{gem} is not installed.\n"
      exit
    end
  }

  remote = YAML.load_file('config.yaml')['github']['remote']

  browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

  files = [
    'index.html',
    'resume.txt',
    'resume.md',
    'resume.pdf',
  ]

  files = files + Dir.entries("public").keep_if {|file| File.file? "public/#{file}"}

  root = "/tmp/checkout-#{Time.now.to_i}"
  g = Git.clone(remote, root, :log => Logger.new(STDOUT))

  # Make sure this actually switches branches.
  g.checkout(g.branch('gh-pages'))

  files.each {|file|
    browser.get file
    content = browser.last_response.body
    File.open("#{root}/#{file}", 'w') {|f| f.write(content) }
    g.add(File.basename(file))
  }

  g.commit('Regenerating Github Pages.')

  # PUSH!
  g.push(g.remote('origin'), g.branch('gh-pages'))

  puts '--> GitHub Pages Commit and Push successful.'
end
