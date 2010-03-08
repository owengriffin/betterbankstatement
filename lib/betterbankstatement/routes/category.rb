
get '/category/new' do
  haml :category_new
end

post '/category/new' do
  BetterBankStatement::Category.new(:name => params[:name]).save
  session[:notice] = "Category '#{params[:name]}' created successfully"
  redirect '/categories'
end

get '/category/:name' do  
  session[:title] = "#{params[:name]}"
  @category = BetterBankStatement::Category.first(:name => params[:name]) 
  @range = (@category.earliest.date..@category.latest.date) if @category.earliest != nil and @category.latest != nil
  haml :category
end

get '/category/:name/:year/:month' do
  if params[:year] and params[:month]
    year = params["year"].to_i
    month = params["month"].to_i
    from = Chronic.parse("#{year}/#{month}/01")
    to = Chronic.parse("#{year}/#{month}/#{Date.days_in_month(month)}")
    @range = (from..to)
  end
  @category = BetterBankStatement::Category.first(:name => params[:name]) 
  @range = (@category.earliest.date..@category.latest.date) if @range == nil
  haml :category
end
