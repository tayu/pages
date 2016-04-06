# coding: utf-8

JEKYLL = "jekyll"

task :default => "all"


task :main do
  chdir "main"
  sh "jekyll build"
  chdir ".."
end

task :lang do
  chdir "lang"
  sh "jekyll build"
  chdir ".."
end

task :all => [ :lang, :main ] do
  puts 'done: gen all'
end

task :up do
  dt = sprintf( "%04d-%02d-%02d", Time.now.year, Time.now.month, Time.now.day )
  sh "git commit -m '#{dt}'"
#  sh "git push origin master"
end
