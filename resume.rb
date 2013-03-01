#!/usr/bin/env ruby
#
# An app for displaying one's resume
# @author Nat Welch - https://github.com/icco/resume

begin
  require "rubygems"
rescue LoadError
  puts "Please install Ruby Gems to continue."
  exit
end

# Check all of the gems we need are there.
[ "sinatra", "less", "github/markup", "yaml", "uri" ].each {|gem|
  begin
    require gem
  rescue LoadError
    puts "The gem #{gem} is not installed.\n"
    exit
  end
}

# Include our configurations from config.yaml
configure do
  config = YAML.load_file('config.yaml')
  set :user_config, config['user_config']
  set :github_config, config['github']
end

# Render the main page.
get '/index.html' do
  rfile = settings.user_config['file']
  name  = settings.user_config['name']
  title = "#{name}'s Resume"
  resume = GitHub::Markup.render(rfile, File.read(rfile))
  pdf_filename = settings.user_config['pdf_file']
  git_url = settings.github_config['git_url']
  html_url = settings.github_config['html_url']

  print_pdf = params['print_pdf'] == '1'
  if print_pdf
    pdf_filename = URI.join(html_url, pdf_filename)
    rfile = URI.join(html_url, rfile)
  end

  # Convert <a>link</a> to icons
  resume = resume.gsub(/\(?(<a href="[^"]*">)link<\/a>\)?/, '\1<i class="icon-external-link"></i></a>')

  # Uncomment to convert all <a>.*</a> to icons
  # resume = resume.gsub(/(<a href="[^"]*">)([^<]*)<\/a>/, '\2 \1<i class="icon-external-link"></i></a>')

  # Convert <a> to target=_blank
  resume = resume.gsub(/\(?(<a[^>]*)(>)/, '\1 target="_blank" \2')

  erb :index, :locals => {
    :title => title,
    :resume => resume,
    :author => name,
    :key => settings.user_config['gkey'],
    :filename => rfile,
    :pdf_filename => pdf_filename,
    :git_url => git_url,
    :html_url => html_url,
    :print_pdf => print_pdf
  }
end

# We do this for our static site rendering.
get '/' do
  redirect '/index.html'
end

# For the plain text markdown version of our resumes
[ '/resume.md', '/resume.txt' ].each {|file_path|
  get file_path do
    content_type 'text/plain', :charset => 'utf-8'
    File.read(settings.user_config['file'])
  end
}

# For the pdf version of our resumes
get '/resume.pdf' do
  content_type 'application/pdf', :charset => 'utf-8'
  File.read(settings.user_config['pdf_file'])
end
