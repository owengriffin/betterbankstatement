class Time
  def self.today
    Date.today.to_time
  end
  def self.tomorrow
    Date.tomorrow.to_time
  end
  def self.yesterday
    Date.yesterday.to_time
  end
  def to_date
    Date.parse(self.strftime('%Y/%m/%d'))
  end
end
class Date
  def self.days_in_month(m)
    return (Date.new(Time.now.year,12,31)<<(12-m)).day
  end

  def self.jump_forward_month(date=nil)
    date = DateTime.now if date == nil
    year = date.year
    month = date.month + 1
    if month <= 0
      month = 12
      year = year - 1
    elsif month > 12
      month = 1
      year = year + 1
    end
    day = date.day
    day = Date.days_in_month(month) if day > Date.days_in_month(month) 
    return Date.new(year, month, day)
  end
end
