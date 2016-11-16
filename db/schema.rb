# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160513063805) do

  create_table "requests", force: :cascade do |t|
    t.string   "url"
    t.text     "response"
    t.date     "when"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string   "Region"
    t.string   "Ticker"
    t.string   "Company"
    t.string   "Sector"
    t.string   "Industry"
    t.string   "Country"
    t.float    "MarketCap"
    t.float    "PtoE"
    t.float    "ForvardPtoE"
    t.float    "Price"
    t.float    "Change"
    t.float    "Volume"
    t.float    "AverageVolume"
    t.float    "FloatShort"
    t.float    "DividendYield"
    t.float    "ReturnonAssets"
    t.float    "ReturnonEquity"
    t.float    "ReturnonInvestment"
    t.float    "CurrentRatio"
    t.float    "QuickRatio"
    t.float    "LTDebtToEquity"
    t.float    "TotalDebtToEquity"
    t.float    "GrossMargin"
    t.float    "OperatingMargin"
    t.float    "ProfitMargin"
    t.string   "EarningsDate"
    t.string   "Exchange"
    t.float    "Gap"
    t.float    "ChangeFromOpen"
    t.float    "ATR"
    t.integer  "InSP500"
    t.integer  "InDJIA"
    t.float    "InsiderOwnership"
    t.float    "InsiderTransactions"
    t.float    "InstitutionalOwnership"
    t.float    "InstitutionalTransactions"
    t.float    "SMA20"
    t.float    "SMA50"
    t.float    "SMA200"
    t.float    "High20"
    t.float    "Low20"
    t.float    "High50"
    t.float    "Low50"
    t.float    "Low52w"
    t.float    "High52w"
    t.float    "posSMA20"
    t.float    "posSMA50"
    t.float    "posSMA200"
    t.float    "posHL20"
    t.float    "posHL50"
    t.float    "posHL52w"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
