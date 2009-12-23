
module BetterBankStatement
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
          link :href => 'style.css', :rel => 'stylesheet', :type => 'text/css', :media => 'screen'
        }
        body.betterbankstatement! do
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
        head { 
          title "Bank statement for #{from.strftime('%d-%m-%Y')} to #{to.strftime('%d-%m-%Y')}"
          link :href => 'style.css', :rel => 'stylesheet', :type => 'text/css', :media => 'screen'
        }
        body.betterbankstatement! do
          script :type => "text/javascript", :src => "swfobject.js"
          script :type => "text/javascript" do
            OpenFlashChart.js('category_timeline', Graph.category_timeline(from, to))
          end
          script :type => "text/javascript" do
            OpenFlashChart.js('category_piechart', Graph.category_piechart(from, to))
          end
          h1 "Bank statement for #{from.strftime('%d-%m-%Y')} to #{to.strftime('%d-%m-%Y')}"

          div.categories! do
            h2 "Categories"
            div :id => "category_timeline"
            div :id => "category_piechart"
            ul do
              categories = Category.date_range(Category.all, from, to).sort { |x,y| x.total_negative <=> y.total_negative}
              categories.each { |category|
                transactions = category.transactions.clone.delete_if { |x| x.date < from or x.date > to }
                transactions = transactions.sort { |x,y| x.date <=> y.date}
                amount = 0
                transactions.each { |transaction|
                  amount = amount + transaction.amount
                }
                li do
                  div.header do
                    span.name category.name
                    span.amount do 
                      if amount < 0
                        span.negative amount
                      else
                        span.positive amount
                      end
                    end
                  end
                  table do
                    transactions.each { |transaction|
                      tr do
                        td.date transaction.date
                        td.amount do
                          if transaction.amount < 0
                            span.negative transaction.amount
                          else
                            span.positive transaction.amount
                          end
                        end
                        td.description transaction.description
                      end
                    }
                  end
                end
              }
            end
          end
          
          div.payees! do
            h2 "Payees"
            script :type => "text/javascript" do
              OpenFlashChart.js('payee_debitors', Graph.debitors_piechart(from, to))
            end
            div :id => "payee_debitors"
            script :type => "text/javascript" do
              OpenFlashChart.js('payee_creditors', Graph.creditors_piechart(from, to))
            end
            div :id => "payee_creditors"
            ul do
              payees = Payee.date_range(Payee.all, from, to)
              payees.each { |payee|
                li do
                  div.header do
                    span.name payee.name
                    span.amount do
                      if payee.total < 0
                        span.negative payee.total
                      else
                        span.positive payee.total
                      end
                    end
                  end
                  table do
                    transactions = payee.transactions.clone.delete_if { |x| x.date < from or x.date > to }
                    transactions.each { |transaction|
                      tr do
                        td.date transaction.date
                        td.amount do
                          if transaction.amount < 0
                            span.negative transaction.amount
                          else
                            span.positive transaction.amount
                          end
                        end
                        td.description transaction.description
                      end
                    }
                  end
                end
              }
            end
          end
        end
      end

      File.open(filename, "w") do |file|
        file.write(mab.to_s)
      end
    end
  end
end
