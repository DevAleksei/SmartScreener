class ScreenerController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  
  def index
    @priceRange = [["50M",50000],["100M",100000],["200M",200000],["300M",300000],["500M",500000],["1B",1000000],["2B",2000000],["5B",5000000],["10B",10000000],["50B",50000000],["100B",100000000],["200B",200000000]]
    @volumeRange = [["10K",10000],["20K",20000],["50K",50000],["100K",100000],["150K",150000],["200K",200000],["300K",300000],["400K",400000],["500K",500000],["750K",750000],["1M",1000000],["2M",2000000],["3M",3000000],["4M",4000000],["5M",5000000],["10M",10000000],["20M",20000000]]
    @percentageRange = [["Up",0.01],["Up 1%",1],["Up 2%",2],["Up 3%",3],["Up 4%",4],["Up 5%",5],["Up 6%",6],["Up 7%",7],["Up 8%",8],["Up 9%",9],["Up 10%",10],["Up 15%",15],["Up 20%",20],["Up 50%",50],["Down",-0.01],["Down 1%",-1],["Down 2%",-2],["Down 3%",-3],["Down 4%",-4],["Down 5%",-5],["Down 6%",-6],["Down 7%",-7],["Down 8%",-8],["Down 9%",-9],["Down 10%",-10],["Down 15%",-15],["Down 20%",-20],["Down 50%",-50]]
    @atrRange = [["Over 0.25",0.25],["Over 0.5",0.5],["Over 0.75",0.75],["Over 1",1],["Over 1.5",1.5],["Over 2",2],["Over 2.5",2.5],["Over 3",3],["Over 3.5",3.5],["Over 4",4],["Over 4.5",4.5],["Over 5",5],["Under 0.25",-0.25],["Under 0.5",-0.5],["Under 0.75",-0.75],["Under 1",-1],["Under 1.5",-1.5],["Under 2",-2],["Under 2.5",-2.5],["Under 3",-3],["Under 3.5",-3.5],["Under 4",-4],["Under 4.5",-4.5],["Under 5",-5]]
    setTimeFrameParameter
    stocks_scope=filter
    @stocks = smart_listing_create(:stocks, stocks_scope, partial: "stocks/index",default_sort: {ticker: "asc"})
  end
  
  def detailed
    setTimeFrameParameter
    stocks_scope = Stock.none
    if params[:filterTicker].present?
      stocks_scope = filter
    end
    @filterTicker = params[:filterTicker]if params[:filterTicker].present?
    @stocks = smart_listing_create(:stocks, stocks_scope, partial: "stocks/detailed",default_sort: {ticker: "asc"})
  end
  
  def draw
    stocks_scope=filter
    @stocks = smart_listing_create(:stocks, stocks_scope, partial: "stocks/debug",default_sort: {ticker: "asc"})
  end
  
private
  def setTimeFrameParameter
    @timeFrame = 
      if params[:timeFrame].present?
        params[:timeFrame]
      else
        "daily" 
      end
  end
  
  def filter
    @anchor = params[:anch].present?
    @sectors = Stock.order('Sector asc').pluck("DISTINCT Sector")   
    if params[:filterSector].present?
      @industries = Stock.where('Sector = :filter', filter: "#{params[:filterSector]}").order('Industry asc').pluck("DISTINCT Industry") 
    else
      @industries = Stock.order('Industry asc').pluck("DISTINCT Industry")
    end
    @countries = Stock.order('Country asc').pluck("DISTINCT Country")
    @exchanges = Stock.order('Exchange asc').pluck("DISTINCT Exchange").compact
    @indices = ['S&P500','DJIA']
    stocks_scope = Stock.all
    stocks_scope = stocks_scope.where(Ticker: params[:filterTicker].upcase.split(%r{\W}).reject{|s| s.empty? })  if params[:filterTicker].present?
    stocks_scope = stocks_scope.where('Sector = :filter', filter: "#{params[:filterSector]}")  if params[:filterSector].present?
    stocks_scope = stocks_scope.where('Industry = :filter', filter: "#{params[:filterIndustry]}")  if params[:filterIndustry].present?
    stocks_scope = stocks_scope.where('Country = :filter', filter: "#{params[:filterCountry]}")  if params[:filterCountry].present?
    stocks_scope = stocks_scope.where('Exchange = :filter', filter: "#{params[:filterExchanges]}")  if params[:filterExchanges].present?
    stocks_scope = stocks_scope.where('MarketCap >= :filter', filter: "#{params[:filterMarketCapMin]}")  if params[:filterMarketCapMin].present?
    stocks_scope = stocks_scope.where('MarketCap <= :filter', filter: "#{params[:filterMarketCapMax]}")  if params[:filterMarketCapMax].present? 
    stocks_scope = stocks_scope.where('Price >= :filter', filter: "#{params[:filterPriceMin]}")  if params[:filterPriceMin].present?
    stocks_scope = stocks_scope.where('Price <= :filter', filter: "#{params[:filterPriceMax]}")  if params[:filterPriceMax].present?
    stocks_scope = stocks_scope.where('AverageVolume >= :filter', filter: "#{params[:filterAverageVolumeMin]}")  if params[:filterAverageVolumeMin].present?
    stocks_scope = stocks_scope.where('AverageVolume <= :filter', filter: "#{params[:filterAverageVolumeMax]}")  if params[:filterAverageVolumeMax].present?
    stocks_scope = stocks_scope.where('Volume >= :filter', filter: "#{params[:filterVolumeMin]}")  if params[:filterVolumeMin].present?
    stocks_scope = stocks_scope.where('Volume <= :filter', filter: "#{params[:filterVolumeMax]}")  if params[:filterVolumeMax].present?
    if params[:filterIndices].present?
      stocks_scope = stocks_scope.where('InSP500 > 0') if params[:filterIndices].include? 'S&P500'
      stocks_scope = stocks_scope.where('InDJIA > 0') if params[:filterIndices].include? 'DJIA'
    end
    
    stocks_scope = stocks_scope.where('PtoE >= :filter', filter: "#{params[:filterPtoEMin]}")  if params[:filterPtoEMin].present?
    stocks_scope = stocks_scope.where('PtoE <= :filter', filter: "#{params[:filterPtoEMax]}")  if params[:filterPtoEMax].present? 
    stocks_scope = stocks_scope.where('ForvardPtoE >= :filter', filter: "#{params[:filterForvardPtoEMin]}")  if params[:filterForvardPtoEMin].present?
    stocks_scope = stocks_scope.where('ForvardPtoE <= :filter', filter: "#{params[:filterForvardPtoEMax]}")  if params[:filterForvardPtoEMax].present? 
    stocks_scope = stocks_scope.where('DividendYield >= :filter', filter: "#{params[:filterDividendYieldMin]}")  if params[:filterDividendYieldMin].present?
    stocks_scope = stocks_scope.where('DividendYield <= :filter', filter: "#{params[:filterDividendYieldMax]}")  if params[:filterDividendYieldMax].present?
    stocks_scope = stocks_scope.where('InsiderOwnership >= :filter', filter: "#{params[:filterInsiderOwnershipMin]}")  if params[:filterInsiderOwnershipMin].present?
    stocks_scope = stocks_scope.where('InsiderOwnership <= :filter', filter: "#{params[:filterInsiderOwnershipMax]}")  if params[:filterInsiderOwnershipMax].present?
    stocks_scope = stocks_scope.where('InsiderTransactions >= :filter', filter: "#{params[:filterInsiderTransactionsMin]}")  if params[:filterInsiderTransactionsMin].present?
    stocks_scope = stocks_scope.where('InsiderTransactions <= :filter', filter: "#{params[:filterInsiderTransactionsMax]}")  if params[:filterInsiderTransactionsMax].present?
    stocks_scope = stocks_scope.where('InstitutionalOwnership >= :filter', filter: "#{params[:filterInstitutionalOwnershipMin]}")  if params[:filterInstitutionalOwnershipMin].present?
    stocks_scope = stocks_scope.where('InstitutionalOwnership <= :filter', filter: "#{params[:filterInstitutionalOwnershipMax]}")  if params[:filterInstitutionalOwnershipMax].present?
    stocks_scope = stocks_scope.where('InstitutionalTransactions >= :filter', filter: "#{params[:filterInstitutionalTransactionsMin]}")  if params[:filterInstitutionalTransactionsMin].present?
    stocks_scope = stocks_scope.where('InstitutionalTransactions <= :filter', filter: "#{params[:filterInstitutionalTransactionsMax]}")  if params[:filterInstitutionalTransactionsMax].present?
    stocks_scope = stocks_scope.where('CurrentRatio >= :filter', filter: "#{params[:filterCurrentRatioMin]}")  if params[:filterCurrentRatioMin].present?
    stocks_scope = stocks_scope.where('CurrentRatio <= :filter', filter: "#{params[:filterCurrentRatioMax]}")  if params[:filterCurrentRatioMax].present?
    stocks_scope = stocks_scope.where('QuickRatio >= :filter', filter: "#{params[:filterQuickRatioMin]}")  if params[:filterQuickRatioMin].present?
    stocks_scope = stocks_scope.where('QuickRatio <= :filter', filter: "#{params[:filterQuickRatioMax]}")  if params[:filterQuickRatioMax].present?
    
    if params[:filterGap].to_f>0
      filterGapMin=params[:filterGap].to_f
    else
      filterGapMax=params[:filterGap].to_f
    end if params[:filterGap].present?
    stocks_scope = stocks_scope.where('Gap >= :filter', filter: "#{filterGapMin}")  if filterGapMin.present?
    stocks_scope = stocks_scope.where('Gap <= :filter', filter: "#{filterGapMax}")  if filterGapMax.present?
    if params[:filterChange].to_f>0
      filterChangeMin=params[:filterChange].to_f
    else
      filterChangeMax=params[:filterChange].to_f
    end if params[:filterChange].present?
    stocks_scope = stocks_scope.where('Change >= :filter', filter: "#{filterChangeMin}")  if filterChangeMin.present?
    stocks_scope = stocks_scope.where('Change <= :filter', filter: "#{filterChangeMax}")  if filterChangeMax.present?
    if params[:filterChangeFromOpen].to_f>0
      filterChangeFromOpenMin=params[:filterChangeFromOpen].to_f
    else
      filterChangeFromOpenMax=params[:filterChangeFromOpen].to_f
    end if params[:filterChangeFromOpen].present?
    stocks_scope = stocks_scope.where('ChangeFromOpen >= :filter', filter: "#{filterChangeFromOpenMin}")  if filterChangeFromOpenMin.present?
    stocks_scope = stocks_scope.where('ChangeFromOpen <= :filter', filter: "#{filterChangeFromOpenMax}")  if filterChangeFromOpenMax.present?
    if params[:filterChangeFromSMA20].to_f>0
      filterChangeFromSMA20Min=params[:filterChangeFromSMA20].to_f
    else
      filterChangeFromSMA20Max=params[:filterChangeFromSMA20].to_f
    end if params[:filterChangeFromSMA20].present?
    stocks_scope = stocks_scope.where('posSMA20 >= :filter', filter: "#{filterChangeFromSMA20Min}")  if filterChangeFromSMA20Min.present?
    stocks_scope = stocks_scope.where('posSMA20 <= :filter', filter: "#{filterChangeFromSMA20Max}")  if filterChangeFromSMA20Max.present?
    if params[:filterChangeFromSMA50].to_f>0
      filterChangeFromSMA50Min=params[:filterChangeFromSMA50].to_f
    else
      filterChangeFromSMA50Max=params[:filterChangeFromSMA50].to_f
    end if params[:filterChangeFromSMA50].present?
    stocks_scope = stocks_scope.where('posSMA50 >= :filter', filter: "#{filterChangeFromSMA50Min}")  if filterChangeFromSMA50Min.present?
    stocks_scope = stocks_scope.where('posSMA50 <= :filter', filter: "#{filterChangeFromSMA50Max}")  if filterChangeFromSMA50Max.present?
    if params[:filterChangeFromSMA200].to_f>0
      filterChangeFromSMA200Min=params[:filterChangeFromSMA200].to_f
    else
      filterChangeFromSMA200Max=params[:filterChangeFromSMA200].to_f
    end if params[:filterChangeFromSMA200].present?
    stocks_scope = stocks_scope.where('posSMA200 >= :filter', filter: "#{filterChangeFromSMA200Min}")  if filterChangeFromSMA200Min.present?
    stocks_scope = stocks_scope.where('posSMA200 <= :filter', filter: "#{filterChangeFromSMA200Max}")  if filterChangeFromSMA200Max.present?
    if params[:filterChangeFromHL20].to_f>0
      filterChangeFromHL20Min=params[:filterChangeFromHL20].to_f
    else
      filterChangeFromHL20Max=params[:filterChangeFromHL20].to_f
    end if params[:filterChangeFromHL20].present?
    stocks_scope = stocks_scope.where('posHL20 >= :filter', filter: "#{filterChangeFromHL20Min}")  if filterChangeFromHL20Min.present?
    stocks_scope = stocks_scope.where('posHL20 <= :filter', filter: "#{filterChangeFromHL20Max}")  if filterChangeFromHL20Max.present?
    if params[:filterChangeFromHL50].to_f>0
      filterChangeFromHL50Min=params[:filterChangeFromHL50].to_f
    else
      filterChangeFromHL50Max=params[:filterChangeFromHL50].to_f
    end if params[:filterChangeFromHL50].present?
    stocks_scope = stocks_scope.where('posHL50 >= :filter', filter: "#{filterChangeFromHL50Min}")  if filterChangeFromHL50Min.present?
    stocks_scope = stocks_scope.where('posHL50 <= :filter', filter: "#{filterChangeFromHL50Max}")  if filterChangeFromHL50Max.present?
    if params[:filterChangeFromHL52w].to_f>0
      filterChangeFromHL52wMin=params[:filterChangeFromHL52w].to_f
    else
      filterChangeFromHL52wMax=params[:filterChangeFromHL52w].to_f
    end if params[:filterChangeFromHL52w].present?
    stocks_scope = stocks_scope.where('posHL52w >= :filter', filter: "#{filterChangeFromHL52wMin}")  if filterChangeFromHL52wMin.present?
    stocks_scope = stocks_scope.where('posHL52w <= :filter', filter: "#{filterChangeFromHL52wMax}")  if filterChangeFromHL52wMax.present?
    if params[:filterATR].to_f>0
      filterATRmin=params[:filterATR].to_f
    else
      filterATRmax=params[:filterATR].to_f.abs
    end if params[:filterATR].present?
    stocks_scope = stocks_scope.where('ATR <= :filter', filter: "#{filterATRmax}")  if filterATRmax.present?
    stocks_scope = stocks_scope.where('ATR >= :filter', filter: "#{filterATRmin}")  if filterATRmin.present?
    
    stocks_scope = stocks_scope.where('ReturnonAssets >= :filter', filter: "#{params[:filterReturnonAssetsMin]}")  if params[:filterReturnonAssetsMin].present?
    stocks_scope = stocks_scope.where('ReturnonAssets <= :filter', filter: "#{params[:filterReturnonAssetsMax]}")  if params[:filterReturnonAssetsMax].present?
    stocks_scope = stocks_scope.where('ReturnonEquity >= :filter', filter: "#{params[:filterReturnonEquityMin]}")  if params[:filterReturnonEquityMin].present?
    stocks_scope = stocks_scope.where('ReturnonEquity <= :filter', filter: "#{params[:filterReturnonEquityMax]}")  if params[:filterReturnonEquityMax].present?
    stocks_scope = stocks_scope.where('ReturnonInvestment >= :filter', filter: "#{params[:filterReturnonInvestmentMin]}")  if params[:filterReturnonInvestmentMin].present?
    stocks_scope = stocks_scope.where('ReturnonInvestment <= :filter', filter: "#{params[:filterReturnonInvestmentMax]}")  if params[:filterReturnonInvestmentMax].present?
    stocks_scope = stocks_scope.where('LTDebtToEquity >= :filter', filter: "#{params[:filterLTDebtToEquityMin]}")  if params[:filterLTDebtToEquityMin].present?
    stocks_scope = stocks_scope.where('LTDebtToEquity <= :filter', filter: "#{params[:filterLTDebtToEquityMax]}")  if params[:filterLTDebtToEquityMax].present?
    stocks_scope = stocks_scope.where('TotalDebtToEquity >= :filter', filter: "#{params[:filterTotalDebtToEquityMin]}")  if params[:filterTotalDebtToEquityMin].present?
    stocks_scope = stocks_scope.where('TotalDebtToEquity <= :filter', filter: "#{params[:filterTotalDebtToEquityMax]}")  if params[:filterTotalDebtToEquityMax].present?
    stocks_scope = stocks_scope.where('GrossMargin >= :filter', filter: "#{params[:filterGrossMarginMin]}")  if params[:filterGrossMarginMin].present?
    stocks_scope = stocks_scope.where('GrossMargin <= :filter', filter: "#{params[:filterGrossMarginMax]}")  if params[:filterGrossMarginMax].present?
    stocks_scope = stocks_scope.where('OperatingMargin >= :filter', filter: "#{params[:filterOperatingMarginMin]}")  if params[:filterOperatingMarginMin].present?
    stocks_scope = stocks_scope.where('OperatingMargin <= :filter', filter: "#{params[:filterOperatingMarginMax]}")  if params[:filterOperatingMarginMax].present?
    stocks_scope = stocks_scope.where('ProfitMargin >= :filter', filter: "#{params[:filterProfitMarginMin]}")  if params[:filterProfitMarginMin].present?
    stocks_scope = stocks_scope.where('ProfitMargin <= :filter', filter: "#{params[:filterProfitMarginMax]}")  if params[:filterProfitMarginMax].present?
    stocks_scope = stocks_scope.where('EarningsDate >= :filter', filter: "#{params[:filterEarningsDateMin]}")  if params[:filterEarningsDateMin].present?
    stocks_scope = stocks_scope.where('EarningsDate <= :filter', filter: "#{params[:filterEarningsDateMax]}")  if params[:filterEarningsDateMax].present?
    return stocks_scope
  end
end
