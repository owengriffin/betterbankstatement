
get '/filters' do
  session[:title] = "Filters"
  @filters = BetterBankStatement::Filter.all
  haml :filters
end

get '/filter/export' do
  content_type :json
  filter_json = []
  BetterBankStatement::Filter.all.each do |filter|
    filter_json << filter.to_json(:exclude => [:id, :category_id], :methods => [:category_name])
  end
  "[#{filter_json.join(',')}]"
end

get '/filter/import' do
  session[:title] = "Import Filters"
  haml :filter_import
end

post '/filter/import' do
  number = 0
  JSON.parse(params[:import_file][:tempfile].readlines.join).each do |obj|
    category = BetterBankStatement::Category.first(:name => obj["category_name"])
    if category == nil
      category = BetterBankStatement::Category.new(:name => obj["category_name"])
      category.save
    end
    filter = BetterBankStatement::Filter.first(:expression => obj["expression"], :category => category)
    if filter == nil
      filter = BetterBankStatement::Filter.new(:expression => obj["expression"], :category => category)
      if filter.save
        number = number + 1
      end
    end
  end
  session[:notice] = "#{number} filters imported"
  redirect "/filters"
end

get '/filter/new' do
  session[:title] = "New Filter"
  @expression = params[:expression]
  haml :filter_new
end

post '/filter/new' do
  session[:notice] = "Filter created successfully"
  filter = BetterBankStatement::Filter.new(:expression => params[:expression])
  category = BetterBankStatement::Category.first(:name => params[:category])
  if category == nil
    category = BetterBankStatement::Category.new(:name => params[:category])
    category.save
  end
  filter.category = category
  filter.save
  redirect '/filters'
end

get '/filter/:id/delete' do
  @filter = BetterBankStatement::Filter.get(params[:id])
  haml :filter_delete
end

post '/filter/:id/delete' do
  if params[:confirm]
    BetterBankStatement::Filter.get(params[:id]).destroy
    session[:notice] = "Filter deleted"
  end
end

get '/filter/apply' do
  BetterBankStatement::Transaction.filter
  session[:notice] = "Filters applied"
  redirect '/'
end
