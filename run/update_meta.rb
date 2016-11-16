require 'csv'
require 'business_time'

def safeParseDate(value, default = nil)
  return DateTime.parse(value)
rescue ArgumentError
  return default
end

redis = Redis.new(:host => RadisHost, :port => RadisPort)
updatedCount = 0
Stock.all.each do |stock|
  ticker=stock.Ticker
  utcToday = DateTime.now.utc.change(:hour => 0)
  metaUrl = "MarketData/%{symbol}-meta.csv" % {:symbol => ticker}
  resultMeta = redis.get(metaUrl)
  if resultMeta.present?
    csvLines = CSV.parse(resultMeta)
#    print(csvLines)
    data = csvLines[0][3].to_f
    stock.PtoE = data if data.present?
    data = csvLines[0][4].to_f
    stock.AverageVolume = data if data.present?
    data = csvLines[0][5].to_f
    stock.High52w = data if data.present?
    data = csvLines[0][6].to_f
    stock.Low52w = data if data.present?
    data = csvLines[0][8].to_f
    stock.DividendYield = data if data.present?
    data = csvLines[1][6].to_f
    stock.Volume = data if data.present?
    data = csvLines[1][45].to_f
    stock.MarketCap = data if data.present?
    stock.save
    redis.del(metaUrl)
    updatedCount += 1
  end
end
print("Updated %{count} records\n" % {:count => updatedCount})