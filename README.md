# Resume

To view Daniel Bear's resume, [go here][res].

This started as a simple place to store a markdown format of my resume, and now it's turned into an easy way to host your resume using [sinatra][s], [github-pages][gp] or [Heroku][h].

[res]: http://danhbear.github.io/resume
[gp]: http://pages.github.com/
[h]: http://heroku.com/

## Installation

 1. Fork this project
 1. Modify resume.md to be your resume.
 1. Modify config.yaml so that the data represents you.
 1. Edit views/style.less to make your resume look pretty.
 1. Install the gems [sinatra][s], [github-markup][gm], [git][g], [rack-test][rt] and [heroku][h]. The easiest way to do this is `gem install bundler && bundle install`
   * install the correct parser for [github-markup][gm], such as [rdiscount][r] for [Markdown][md].
 1. type `rake local` or `./resume.rb` to run locally.
 1. type `rake pdf` to create resume.pdf (requires [wkhtmltopdf][pdf]`).
 1. To deploy to Heroku
   * Run `heroku create`
   * `rake deploy` to push your resume to the internet.
 1. To deploy to [github-pages][gp], run `rake github`.

[g]: http://github.com/schacon/ruby-git
[rt]: http://github.com/brynary/rack-test
[s]: http://www.sinatrarb.com/
[r]: http://github.com/rtomayko/rdiscount
[gm]: http://github.com/github/markup
[md]: http://en.wikipedia.org/wiki/Markdown
[pdf]: http://wkhtmltopdf.org

## License

resume.md is property of Daniel Bear. You are welcome to use it as a base structure for your resume, but don't forget, you are not him.

The rest of the code is licensed CC-GPL. Remember sharing is caring.
