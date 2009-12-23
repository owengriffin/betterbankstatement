require 'rubygems'
require 'less'
require 'fileutils'


# Remove any temporary HTML files created
task :clean do
  FileList["*.html"].each { |file|
    File.delete(file)
  }
  FileList["*.png"].each { |file|
    File.delete(file)
  }
end

rule ".css" => ".less" do |file|
  File.open(file.name, "w") do |fh|
    fh.write(Less::Engine.new(File.new(file.source)).to_css)
  end
end

stylesheets = FileList["*.less"].sub(/less$/, "css")

task :all => stylesheets do
  puts "Generated JS & CSS"
end

