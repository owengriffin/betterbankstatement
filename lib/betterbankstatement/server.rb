require 'sinatra'
require 'haml'
require 'dm-serializer'

enable :sessions
set :views, BetterBankStatement::dir + '/views'
set :public, BetterBankStatement::dir + '/public'

load BetterBankStatement::dir + '/routes/category.rb'
load BetterBankStatement::dir + '/routes/filter.rb'
load BetterBankStatement::dir + '/routes/transactions.rb'
load BetterBankStatement::dir + '/routes/import.rb'

get '/' do
  session[:title] = "Home"
  @categories = BetterBankStatement::Category.all
  earliest = BetterBankStatement::Transaction.earliest
  @date_range = (earliest.date..Time.now.to_date) if earliest
  haml :index
end

get '/style.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end

get '/reset.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :reset
end

get '/categories' do
  session[:title] = "Categories"
  @categories = BetterBankStatement::Category.all
  haml :categories
end

get '/category/timeline/:year/:month/:days' do
  chart = Hash.new
  chart["elements"] = []
  # Read the earliest transaction date
  #from = BetterBankStatement::Transaction.earliest.date
  # Set the date which we will be generating data for to be the first day of the month
  from = Date.new(params[:year].to_i, params[:month].to_i, 1)
  to = from + params[:days].to_i
  # 
  min = 0
  max = 0
  # Iterate through all the categories and find out how much the spend in a particular date
  BetterBankStatement::Category.all.each do |category|
    if params[:exclude] and category.name == params[:exclude]
      # Skip
    else
    # Gather the amount spent each month
    data = []
    iterator = from
    while iterator < to
      monthly_total = category.total_amount(iterator..(iterator >> 1))
      monthly_total = 0 if monthly_total == nil
      # Set the minimum and maximum variables if required
      if monthly_total > max
        max = monthly_total
      end
      if monthly_total < min
         min = monthly_total
      end
      data << { "value" => monthly_total, "tip" => "#val# #{category.name}" }
      # Move to the next day
      iterator = iterator + 1
    end
    chart["elements"].push({ "type" => "line",
                             "width" => 2,
                             "colour" => "\##{rand(255).to_s(16)}#{rand(255).to_s(16)}#{rand(255).to_s(16)}",
                             "values" => data,
                             "text" => category.name
                           })
    end
  end
  labels = []
  iterator = from
  while iterator < to
    labels << iterator.strftime('%d-%m')
    iterator = iterator + 1
  end
  chart["x_axis"] = { 
    "labels" => { 
      "labels" => labels, 
      "rotate" => 270 
    }, 
    "steps"=> 2, 
    "stoke" => 1, 
    "grid-colour" => "#DDDDDD", 
    "colour" => "#AFAFAF" 
  }
  chart["x_legend"] = { 
    "text" => "#{from.strftime('%d-%m-%Y')} to #{to.strftime('%d-%m-%Y')}", 
    "style" => {
      "font-size" => "20px", 
      "color" => "#778877" 
    } 
  }
  chart["y_axis"] = { 
    "min" => min, 
    "max" => max, 
    "steps"=> (max - min) / 10, 
    "labels"=> nil, 
    "offset"=> 0, 
    "grid-colour" => "#DDDDDD", 
    "colour" => "#AFAFAF" 
  }
  chart["bg_colour"] = "#FFFFFF"
  content_type :json
  chart.to_json
end


