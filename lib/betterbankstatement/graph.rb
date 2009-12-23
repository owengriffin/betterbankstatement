# -*- coding: utf-8 -*-

module BetterBankStatement
  class Graph

    COLOURS = ['FF0000', 'FE9A2E', 'FFFF00', '80FF00', '00FF00', '00FF80', '2EFEF7', '0080FF', '0000FF', '8000FF', 'FF00FF', 'FF0080']

    def Graph.safe_name(name)
      return name.gsub(/ & /, 'and')
    end

    def Graph.category_timeline(from, now)
      chart = Hash.new
      chart["elements"] = []
      #chart["title"] = { "text"=> "Category spenditure between #{from.strftime('%d-%m-%Y')} and #{now.strftime('%d-%m-%Y')}" }
      min = 0
      max = 0
      index = 0
      Category.all.each { |category|
        if category.total_between(from, now) != 0
          data = []
          total = 0
          (from..now).each { |date| 
            total = total + category.total_between(date , date + 1 )
            if total > max
              max = total
            end
            if total < min
              min = total
            end
            data << total
          }
          chart["elements"].push({ "type"=> "line", "width"=> 2, "colour"=> '#' + COLOURS[index], "values" => data, "text" => category.name})
          index = index + 1
        end
      }
      labels = []
      (from..now).each { |date|
        labels << date.strftime('%d-%m')
      }
      chart["x_axis"] = { "labels"=> { "labels" => labels, "rotate" => 270 } , "steps"=> 7, "stoke" => 1, "grid-colour" => "#DDDDDD", "colour" => "#AFAFAF" }
      chart["x_legend"] = { "text" => "#{from.strftime('%d-%m-%Y')} to #{now.strftime('%d-%m-%Y')}", "style" => {"font-size" => "20px", "color" => "#778877" } }
      chart["y_axis"] = { "min" => min, "max" => max, "steps"=> (max - min) / 10, "labels"=> nil, "offset"=> 0, "grid-colour" => "#DDDDDD", "colour" => "#AFAFAF" }
      chart["bg_colour"] = "#FFFFFF"
      return chart.to_json
    end

    def Graph.category_piechart(from, now)
      chart = OpenFlashChart.pie_chart
      element = OpenFlashChart.pie_element
      element["colours"] = COLOURS
      Category.all.each { |category|
        if category.total_between(from, now) != 0
          amount = category.total_between(from, now)
          amount = amount * -1 if amount < 0
          element["values"] << { "value" => amount, "label" => "#{category.name} (£#{amount})" }
        end
      }
      chart["elements"] << element
      return chart.to_json
    end

    def Graph.creditors_piechart(from, to)
      chart = OpenFlashChart.pie_chart
      element = OpenFlashChart.pie_element
      element["colours"] = COLOURS
      Payee.date_range(Payee.all, from, to).each { |payee|
        amount = payee.credit_between(from, to) * -1
        name = payee.name.gsub('\'', '')
        element["values"] << { "value" => amount, "label" => "#{name} (£#{amount})" } if amount > 0
      }
      chart["elements"] << element
      return chart.to_json
    end

    def Graph.debitors_piechart(from, to)
      chart = OpenFlashChart.pie_chart
      element = OpenFlashChart.pie_element
      element["colours"] = COLOURS
      Payee.date_range(Payee.all, from, to).each { |payee|
        amount = payee.debit_between(from, to)          
        name = payee.name.gsub('\'', '')
        element["values"] << { "value" => amount, "label" => "#{name} (£#{amount})" } if amount > 0
      }
      chart["elements"] << element
      return chart.to_json
    end
  end
end
