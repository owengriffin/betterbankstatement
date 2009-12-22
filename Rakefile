
# Remove any temporary HTML files created
task :clean do
  FileList["*.html"].each { |file|
    File.delete(file)
  }
  FileList["*.png"].each { |file|
    File.delete(file)
  }
end
