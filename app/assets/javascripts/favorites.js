var highlightCssClass = " active";

function highlightFav(){ 
  var favStockBlocks = document.getElementsByClassName("favStockBlock");
  var usdTickers = Cookies.get("fav-usd");
  var euroTickers = Cookies.get("fav-euro");
  var gbpTickers = Cookies.get("fav-gbp");
  if(usdTickers){
    usdTickers = JSON.parse(usdTickers);
  }    
  if(euroTickers){
    euroTickers = JSON.parse(euroTickers);
  }    
  if(gbpTickers){
    gbpTickers = JSON.parse(gbpTickers);
  }
  for(var i=0; i<favStockBlocks.length ; i++){
    var favStockBlock = favStockBlocks[i];
    var ticker = favStockBlock.getAttribute("ticker");
    if(usdTickers){
      if(usdTickers.indexOf(ticker)>-1){
        favStockBlock.getElementsByClassName("glyphicon-usd")[0].className += highlightCssClass;
      }
    }    
    if(euroTickers){
      if(euroTickers.indexOf(ticker)>-1){
        favStockBlock.getElementsByClassName("glyphicon-euro")[0].className += highlightCssClass;
      }
    }    
    if(gbpTickers){
      if(gbpTickers.indexOf(ticker)>-1){
        favStockBlock.getElementsByClassName("glyphicon-gbp")[0].className += highlightCssClass;
      }
    }
  }
}

function insFavIconClick(favGroup){
  var input=document.getElementById("filterTicker").getElementsByTagName("input")[0];
  var tickers = Cookies.get('fav-'+favGroup);
  if(tickers){
    tickers = JSON.parse(tickers);
    input.value = tickers.join(" ");
    $(input).closest('form').submit();
  }
  
}

function favIconClick(clickedButton,favGroup){
  debugger;
  var ticker=clickedButton.parentElement.getAttribute("ticker");
  var tickers = Cookies.get('fav-'+favGroup);
  if(!tickers){
    tickers = new Array();
  }else{
    tickers = JSON.parse(tickers);
  }
  var pos = tickers.indexOf(ticker);
  if(pos > -1){
    tickers.splice(pos,1);
    clickedButton.className = clickedButton.className.replace(highlightCssClass, '' );
  }else{
    clickedButton.className += highlightCssClass;
    tickers.push(ticker);
  }
  Cookies.set('fav-'+favGroup,tickers);
}