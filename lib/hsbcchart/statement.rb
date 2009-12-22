
module HSBCChart
  class Statement

    def Statement.jump_back_month(date=nil)
      date = DateTime.now if date == nil
      year = date.year
      month = date.month - 1
      if month <= 0
        month = 1
        year = year - 1
      end
      return Date.new(year, month, date.day)
    end

    def Statement.generate_monthly_statements
      monthly_statements = []
      to = DateTime.now
      from = jump_back_month(to)
      total = Transaction.total_between(from, to)
      while total > 0
        monthly_filename = "#{from.strftime('%Y%m%d')}_#{to.strftime('%Y%m%d')}.html"
        monthly_statements << { :filename => monthly_filename, :from => from, :to => to }
        Statement.for_date_range(monthly_filename, from, to)
        to = from
        from = jump_back_month(from)
        total = Transaction.total_between(from, to)
      end
      return monthly_statements
    end

    def Statement.generate(filename="index.html")
      mab = Markaby::Builder.new
      mab.html do
        head {
          title "Bank Statement"
        }
        body do
          h1 "Bank Statement"
          ul do
            Statement.generate_monthly_statements.each { |statement|
              li do
                from = statement[:from]
                to = statement[:to]
                a :href => statement[:filename] do
                  "#{from.strftime('%d/%m/%Y')} to #{to.strftime('%d/%m/%Y')}"
                end
              end
            }
          end
        end
      end
      File.open(filename, "w") do |file|
        file.write(mab.to_s)
      end
    end

    def Statement.for_date_range(filename, from, to)
      mab = Markaby::Builder.new
      mab.html do
        head { title "Bank statement for #{from.strftime('%d-%m-%Y')} to #{to.strftime('%d-%m-%Y')}" }
        body do
          script :type => "text/javascript", :src => "swfobject.js"
          script :type => "text/javascript" do
            OpenFlashChart.js('category_timeline', HSBCChart::Graph.category_timeline(from, to))
          end
          script :type => "text/javascript" do
            OpenFlashChart.js('category_piechart', HSBCChart::Graph.category_piechart(from, to))
          end
          h1 "Bank statement for #{from.strftime('%d-%m-%Y')} to #{to.strftime('%d-%m-%Y')}"

          h2 "Categories"
          div :id => "category_timeline"
          div :id => "category_piechart"
          ul.categories! do
            categories = HSBCChart::Category.date_range(Category.all, from, to).sort { |x,y| x.total_negative <=> y.total_negative}
            categories.each { |category|
              transactions = category.transactions.clone.delete_if { |x| x.date < from or x.date > to }
              transactions = transactions.sort { |x,y| x.date <=> y.date}
              amount = 0
              transactions.each { |transaction|
                amount = amount + transaction.amount
              }
              li "#{category.name} #{amount}"
              ul do 
                table do
                  transactions.each { |transaction|
                    tr do
                      td.date transaction.date
                      td.amount transaction.amount
                      td.description transaction.description
                    end
                  }
                end
              end
            }
          end
          
          h2 "Payees"
          script :type => "text/javascript" do
            OpenFlashChart.js('payee_debitors', HSBCChart::Graph.debitors_piechart(from, to))
          end
          div :id => "payee_debitors"
          script :type => "text/javascript" do
            OpenFlashChart.js('payee_creditors', HSBCChart::Graph.creditors_piechart(from, to))
          end
          div :id => "payee_creditors"
          ul.payees! do
            payees = HSBCChart::Payee.date_range(Payee.all, from, to)
            payees.each { |payee|
              li payee.name
              table do
                transactions = payee.transactions.clone.delete_if { |x| x.date < from or x.date > to }
                transactions.each { |transaction|
                  tr do
                    td.date transaction.date
                    td.amount transaction.amount
                    td.description transaction.description
                  end
                }
              end
            }
          end

        end
      end

      File.open(filename, "w") do |file|
        file.write(mab.to_s)
      end
    end
  end
end
