
get '/import' do
  haml :import
end

get '/import/pdf' do
  session[:title] = "Import PDF file"
  haml :import_pdf
end

post '/import/pdf' do
  result = BetterBankStatement::Import.pdf_text params[:import_file][:tempfile].readlines.join
  session[:notice] = "#{result[:no_imported]} transactions imported. #{result[:no_duplicates]} duplicates."
  redirect '/transactions'
end

get '/import/qif' do
  session[:title] = "Import QIF file"
  haml :import_qif
end

post '/import/qif' do
  result = BetterBankStatement::Import.qif params[:import_file][:tempfile].readlines.join
  session[:notice] = "#{result[:no_imported]} transactions imported. #{result[:no_duplicates]} duplicates."
  redirect '/transactions'
end
