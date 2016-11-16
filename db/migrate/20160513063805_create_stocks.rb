class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :Region
      t.string :Ticker
      t.string :Company
      t.string :Sector
      t.string :Industry
      t.string :Country
      t.float :MarketCap
      t.float :PtoE
      t.float :ForvardPtoE
      t.float :Price
      t.float :Change
      t.float :Volume
      t.float :AverageVolume
      t.float :FloatShort
      t.float :DividendYield
      t.float :ReturnonAssets
      t.float :ReturnonEquity
      t.float :ReturnonInvestment
      t.float :CurrentRatio
      t.float :QuickRatio
      t.float :LTDebtToEquity
      t.float :TotalDebtToEquity
      t.float :GrossMargin
      t.float :OperatingMargin
      t.float :ProfitMargin
      t.string :EarningsDate
      t.string :Exchange
      t.float :Gap
      t.float :ChangeFromOpen
      t.float :ATR
      t.integer :InSP500
      t.integer :InDJIA
      t.float :InsiderOwnership
      t.float :InsiderTransactions
      t.float :InstitutionalOwnership
      t.float :InstitutionalTransactions
      
      t.float :SMA20
      t.float :SMA50
      t.float :SMA200      
      t.float :High20
      t.float :Low20
      t.float :High50
      t.float :Low50
      t.float :Low52w
      t.float :High52w
      
      t.float :posSMA20
      t.float :posSMA50
      t.float :posSMA200      
      t.float :posHL20
      t.float :posHL50
      t.float :posHL52w

      t.timestamps null: false
    end
  end
end
