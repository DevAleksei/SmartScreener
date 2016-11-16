require "aws-sdk-core"
require "json"

class ApiController < ApplicationController
  def getHistory
    getDailyHistory
  end
  def get5MinHistory
    if params[:ticker].present?
      requesturl = "MarketData/%{symbol}-300.csv" % {:symbol => params[:ticker]}
      redis = Redis.new(:host => RadisHost, :port => RadisPort)
      response = false 
      result = redis.get(requesturl)
      response = result.html_safe if result.present?
      render :json => response
    end
  end
  def getDailyHistory
    if params[:ticker].present?
      requesturl = "MarketData/%{symbol}-daily.csv" % {:symbol => params[:ticker]}
      redis = Redis.new(:host => RadisHost, :port => RadisPort)
      response = false 
      result = redis.get(requesturl)
      response = result.html_safe if result.present?
      render :json => response
    end
  end
  def getWeeklyHistory
    if params[:ticker].present?
      requesturl = "MarketData/%{symbol}-weekly.csv" % {:symbol => params[:ticker]}
      redis = Redis.new(:host => RadisHost, :port => RadisPort)
      response = false 
      result = redis.get(requesturl)
      response = result.html_safe if result.present?
      render :json => response
    end
  end
  def getMonthlyHistory
    if params[:ticker].present?
      requesturl = "MarketData/%{symbol}-monthly.csv" % {:symbol => params[:ticker]}
      redis = Redis.new(:host => RadisHost, :port => RadisPort)
      response = false 
      result = redis.get(requesturl)
      response = result.html_safe if result.present?
      render :json => response
    end
  end
  # def get5MinHistory
    # if params[:ticker].present?
      # requesturl = "MarketData/%{symbol}-300.csv" % {:symbol => params[:ticker]}
      # dynamodb = Aws::DynamoDB::Client.new
      # tableName = 'requests'
      # params = {
        # table_name: tableName,
        # key_condition_expression: "#url = :requesturl",
        # expression_attribute_names: {
            # "#url" => "URL"
        # },
        # expression_attribute_values: {
            # ":requesturl" => requesturl
        # }
      # }
      # response = false 
      # result = dynamodb.query(params)
      # response = result.items.first["response"].html_safe if result.items.any?
      # render :json => response
    # end
    # # if params[:ticker].present?
      # # utcNowTime = Time.now.utc.change(:hour => 0)
      # # #url = "/getHistory.json?apikey=a612504b9b72a3888d6a5f7c954654f5&symbol=%{symbol}&type=daily&startDate=%{date}000000" % {:symbol => params[:ticker], :date => (utcNowTime - 5.year).strftime("%Y%m%d")}
      # # url = "/MarketData/%{symbol}-300.csv" % {:symbol => params[:ticker]}
      # # response = Request.where("Url = :param and 'when' > :currenttime", param: request.fullpath, currenttime: utcNowTime).pluck("response").first
      # # if response
        # # response = response.html_safe;
      # # else
        # # response = Net::HTTP.get_response("52.10.247.104", url).body
        # # #response = Net::HTTP.get_response("ondemand.websol.barchart.com", url).body
        # # Request.create(url:request.fullpath, response: response, 'when': utcNowTime + (60)).save if response.present?
      # # end
      # # render :json => response
    # # end
  # end
  # def getDailyHistory
    # if params[:ticker].present?
      # requesturl = "MarketData/%{symbol}-daily.csv" % {:symbol => params[:ticker]}
      # dynamodb = Aws::DynamoDB::Client.new
      # tableName = 'requests'
      # params = {
        # table_name: tableName,
        # key_condition_expression: "#url = :requesturl",
        # expression_attribute_names: {
            # "#url" => "URL"
        # },
        # expression_attribute_values: {
            # ":requesturl" => requesturl
        # }
      # }
      # response = false 
      # result = dynamodb.query(params)
      # response = result.items.first["response"].html_safe if result.items.any?
      # render :json => response
    # end
  # end
end