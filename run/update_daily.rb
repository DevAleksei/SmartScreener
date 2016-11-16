require "csv"

def safeParseDate(value, default = nil)
  return DateTime.parse(value)
rescue ArgumentError
  return default
end

redis = Redis.new(:host => RadisHost, :port => RadisPort)
Stock.all.each do |stock|
  ticker=stock.Ticker
  fiveMinUrl = "MarketData/%{symbol}-300.csv" % {:symbol => ticker}
  result5Min = redis.get(fiveMinUrl)
  if result5Min.present?
    csvLines = CSV.parse(result5Min)
    utcToday = DateTime.now.utc.change(:hour => 0)
    todayCSVlines = Array.new
    csvLines.each do |csv|
      date=safeParseDate(csv[0])
      if date > utcToday
        todayCSVlines.push(csv)
      end if date.present?
    end
    if todayCSVlines.any?
      dateTicker = todayCSVlines[-1][0]
      openPrice = todayCSVlines[0][3].to_f
      closePrice = todayCSVlines[-1][4].to_f
      highPrice = todayCSVlines[0][1].to_f
      lowPrice = todayCSVlines[0][2].to_f
      volume = 0
      todayCSVlines.each do |csv|
        highPrice = csv[1].to_f if highPrice < csv[1].to_f
        lowPrice = csv[2].to_f if lowPrice > csv[2].to_f
        volume = volume + csv[6].to_f
      end
      stock.Price = closePrice
      stock.Volume = volume
      stock.posSMA20 = nil
      stock.posSMA50 = nil
      stock.posSMA200 = nil
      stock.posSMA20 = (closePrice/stock.SMA20 - 1) * 100 if stock.SMA20.present?
      stock.posSMA50 = (closePrice/stock.SMA50 - 1) * 100 if stock.SMA50.present?
      stock.posSMA200 = (closePrice/stock.SMA200 - 1) * 100 if stock.SMA200.present?
      stock.posHL20 = nil
      stock.posHL20 = (closePrice/stock.High20 - 1) * 100 if stock.High20.present? && closePrice>stock.High20
      stock.posHL20 = (closePrice/stock.Low20 - 1) * 100 if stock.Low20.present? && closePrice<stock.Low20
      stock.posHL50 = nil
      stock.posHL50 = (closePrice/stock.High50 - 1) * 100 if stock.High50.present? && closePrice>stock.High50
      stock.posHL50 = (closePrice/stock.Low50 - 1) * 100 if stock.Low50.present? && closePrice<stock.Low50
      stock.posHL52w = nil
      stock.posHL52w = (closePrice/stock.High52w - 1) * 100 if stock.High52w.present? && closePrice>stock.High52w
      stock.posHL52w = (closePrice/stock.Low52w - 1) * 100 if stock.Low52w.present? && closePrice<stock.Low52w
      begin        
        stock.ChangeFromOpen = (closePrice/openPrice - 1) * 100
      rescue
        stock.ChangeFromOpen = nil
      end
      dailyUrl = "MarketData/%{symbol}-daily.csv" % {:symbol => ticker}
      resultDaily = redis.get(dailyUrl)
      if resultDaily.present?
        csvLines = CSV.parse(resultDaily)
        dailyCSVlines = csvLines.reject{|csv| (safeParseDate(csv[0],DateTime.commercial(0)) > utcToday) }
        previousDayClose = dailyCSVlines[1][4].to_f
        begin        
          stock.Gap = (openPrice/previousDayClose - 1) * 100
        rescue
          stock.Gap = nil
        end
        begin        
          stock.Change = (closePrice/previousDayClose - 1) * 100
        rescue
          stock.Change = nil
        end
        resultDaily = dailyCSVlines.shift.join(",")
        dailyCSVlines.each do |csv|
          resultDaily.concat("\n"+csv.join(","))
        end
      end
      stock.save
      resultDaily << "\n" << [dateTicker,highPrice,lowPrice,openPrice,closePrice,volume,0].join(",")
      redis.set(dailyUrl,resultDaily)
    end
  end
#  print(stock.inspect)
#  break
end