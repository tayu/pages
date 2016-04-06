# coding: utf-8

JEKYLL = "jekyll"

task :default => "genall"


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

task :genall => [ :lang, :main ] do
  puts 'done: gen all'
end

