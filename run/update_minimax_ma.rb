require 'csv'
require 'business_time'

def safeParseDate(value, default = nil)
  return DateTime.parse(value)
rescue ArgumentError
  return default
end

def calculateAtr(csvLines)
  sumTR = 0
  csvLines.shift(14).each do |csvLine|
    closePrice = csvLine[4].to_f
    highPrice = csvLine[1].to_f
    lowPrice = csvLine[2].to_f
    sumTR += [highPrice - lowPrice,(highPrice - closePrice).abs,(lowPrice - closePrice).abs].max
  end
  atr = sumTR/14
  csvLines.each do |csvLine|
    closePrice = csvLine[4].to_f
    highPrice = csvLine[1].to_f
    lowPrice = csvLine[2].to_f
    tr = [highPrice - lowPrice,(highPrice - closePrice).abs,(lowPrice - closePrice).abs].max
    atr = (atr*13 + tr)/14
  end
  return atr
end

redis = Redis.new(:host => RadisHost, :port => RadisPort)
updatedCount = 0
Stock.all.each do |stock|
  ticker=stock.Ticker
  dailyUrl = "MarketData/%{symbol}-daily.csv" % {:symbol => ticker}
  resultDaily = redis.get(dailyUrl)
  if resultDaily.present?
    csvLines = CSV.parse(resultDaily)
    filteredData = csvLines
    nilDate = DateTime.commercial(0)
    date = 260.business_days.ago
    filteredData = filteredData.select { |elm| safeParseDate(elm[0],nilDate) > date }
    if filteredData.empty?
      stock.High52w = nil
      stock.Low52w = nil
    else
      stock.High52w = filteredData.collect {|elm| elm[1].to_f}.max
      stock.Low52w = filteredData.collect {|elm| elm[2].to_f}.min
    end
    date = 200.business_days.ago
    filteredData = filteredData.select { |elm| safeParseDate(elm[0],nilDate) > date }
    if filteredData.empty?
      stock.SMA200 = nil
    else
      stock.SMA200 = filteredData.collect {|elm| elm[4].to_f}.sma
    end
    date = 50.business_days.ago
    filteredData = filteredData.select { |elm| safeParseDate(elm[0],nilDate) > date }
    if filteredData.empty?
      stock.SMA50 = nil
      stock.High50 = nil
      stock.Low50 = nil
    else
      stock.SMA50 = filteredData.collect {|elm| elm[4].to_f}.sma
      stock.High50 = filteredData.collect {|elm| elm[1].to_f}.max
      stock.Low50 = filteredData.collect {|elm| elm[2].to_f}.min
    end
    date = 20.business_days.ago
    filteredData = filteredData.select { |elm| safeParseDate(elm[0],nilDate) > date }
    if filteredData.empty?
      stock.SMA20 = nil
      stock.High20 = nil
      stock.Low20 = nil
    else
      stock.SMA20 = filteredData.collect {|elm| elm[4].to_f}.sma
      stock.High20 = filteredData.collect {|elm| elm[1].to_f}.max
      stock.Low20 = filteredData.collect {|elm| elm[2].to_f}.min
    end
    if csvLines.count>24
      stock.ATR = calculateAtr(csvLines.sort{ |x,y| safeParseDate(y[0],nilDate) <=> safeParseDate(x[0],nilDate) }[0,23].reverse)
    else
      stock.ATR = nil
    end
#    print(stock.inspect)
    stock.save
    updatedCount += 1
  end
#  break
end
print("Updated %{count} records\n" % {:count => updatedCount})