
When /^I import a QIF file$/ do |string|
  filename = '/tmp/qif.tmp'
  File.open(filename, 'w') {|f| f.write(string) }
  BetterBankStatement::Import.qif_file(filename)
end

When /^I import a PDF file$/ do |string|
  filename = '/tmp/pdf.tmp'
  File.open(filename, 'w') {|f| f.write(string) }
  BetterBankStatement::Import.pdf_textfile(filename)
end
