function drawChart(data,ticker,renderElement,resetButton,fullButton,maxWidth,maxHeight){ 
  var results;
  if(data && data !== "false"){
    results=d3.csv.parse(data);
  }
  var symbol=ticker;
  var rootContainerIdCss="#" + ticker;
  renderElement=renderElement ? d3.select(renderElement) : d3.select(rootContainerIdCss);

  var fullwidth = maxWidth ? maxWidth : 700, fullheight = maxHeight ? maxHeight : 400,
      margin = {top: 20, right: 20, bottom: 70, left: 35},
      margin2 = {top: fullheight - margin.bottom - margin.top + 5, bottom: 20},
      width = fullwidth - margin.left - margin.right,
      height = fullheight - margin.top - margin.bottom,
      height2 = fullheight - margin.top - margin2.top - margin2.bottom,
      totalheight = fullheight - margin.top - margin2.bottom;
  
  var chartStartShiftToLeft = 15;
  
  var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;
  
  var x = techan.scale.financetime()
    .range([0, width]);

  var y = d3.scale.linear()
    .range([height, 0]);
  
  var yVolume = d3.scale.linear()
    .range([totalheight, margin2.top]);

  var zoom = d3.behavior.zoom()
    .scaleExtent([0.95, Infinity])
    .on("zoom", onZoom);
  
  if(resetButton) d3.select(resetButton).on("click", resetChart);
  if(fullButton) d3.select(fullButton).on("click", fullChart);
  renderElement.on("click", enableZoom);
  
  var candlestick = techan.plot.candlestick()
    .xScale(x)
    .yScale(y);
  
  var xAxis = d3.svg.axis()
    .scale(x)
    .innerTickSize(-totalheight)
    .orient("bottom");
  
  var yAxis = d3.svg.axis()
    .scale(y)
    .innerTickSize(-width)
    .orient("left");
  
  var volumeAxis = d3.svg.axis()
    .scale(yVolume)
    .orient("left")
    .ticks(4)
    .tickFormat(d3.format(",.2s"));
    
  var volume = techan.plot.volume()
    .accessor(techan.accessor.ohlc())
    .xScale(x)
    .yScale(yVolume);

  var sma0 = techan.plot.sma()
    .xScale(x)
    .yScale(y);

  var sma1 = techan.plot.sma()
    .xScale(x)
    .yScale(y);

  var sma2 = techan.plot.sma()
    .xScale(x)
    .yScale(y);

  var ohlcAnnotation = techan.plot.axisannotation()
    .axis(yAxis)
    .format(d3.format(',.2fs'));

  var timeAnnotation = techan.plot.axisannotation()
    .axis(xAxis)
    .format(d3.time.format('%Y-%m-%d'))
    .width(65)
    .translate([0, totalheight]); 

  var volumeAnnotation = techan.plot.axisannotation()
    .axis(volumeAxis)
    .width(35);

  var ohlcCrosshair = techan.plot.crosshair()
    .xScale(x)
    .yScale(y)
    .xAnnotation(timeAnnotation)
    .yAnnotation(ohlcAnnotation)
    .verticalWireRange([0, totalheight])
    .on("enter", enter)
    .on("out", out)
    .on("move", move);

  var volumeCrosshair = techan.plot.crosshair()
    .xScale(x)
    .yScale(yVolume)
    .xAnnotation(timeAnnotation)
    .yAnnotation(volumeAnnotation)
    .verticalWireRange([0, totalheight])
    .on("enter", enter)
    .on("out", out)
    .on("move", move);
    
  renderElement.html("");
  
  var svg = renderElement.append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)

  var defs = svg.append("defs");

  defs.append("clipPath")
    .attr("id", "clip")
    .append("rect")
      .attr("x", 0)
      .attr("y", y(1))
      .attr("width", width)
      .attr("height", totalheight);

  defs.append("clipPath")
    .attr("id", "volumeClip")
    .append("rect")
      .attr("x", 0)
      .attr("y", margin2.top)
      .attr("width", width)
      .attr("height", height2);

  svg = svg.append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  svg.append('text')
    .attr("class", "symbol")
    .attr("x", 20)
    .text(symbol);  
  
  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + totalheight + ")");
  
  svg.append("g")
    .attr("class", "y axis")
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Price ($)");

  svg.append("g")
    .attr("class", "volume")
    .attr("clip-path", "url(#volumeClip)");

  svg.append("g")
    .attr("class", "indicator sma ma-0")
    .attr("clip-path", "url(#clip)");

  svg.append("g")
    .attr("class", "indicator sma ma-1")
    .attr("clip-path", "url(#clip)");

  svg.append("g")
    .attr("class", "indicator sma ma-2")
    .attr("clip-path", "url(#clip)");

  svg.append("g")
    .attr("class", "volume axis")
    .append("text")
      .attr("dy", "-.35em")
      .style("text-anchor", "end")
      .text("Volume");

  svg.append("g")
    .attr("class", "candlestick")
    .attr("clip-path", "url(#clip)");

  svg.append('g')
    .attr("class", "crosshair ohlc")
    .call(ohlcCrosshair);
	
  svg.append('g')
    .attr("class", "crosshair volume")
    .call(volumeCrosshair);

  var coordsText = svg.append('text')
    .style("text-anchor", "end")
    .attr("class", "extradata")
    .attr("x", width - 5)
    .attr("y", 0);
    
  var accessor = candlestick.accessor();
  
  if(results){
    var data = results.map(function(d) {
      if(d.date){
        var date = parseDate(d.date)
        if (date)
          return {
            date: new Date(date.valueOf() - 5 * 60000),
            open: +d.open,
            high: +d.high,
            low: +d.low,
            close: +d.close,
            volume: +d.volume
          };
      }
    }).sort(function(a, b) { return d3.ascending(accessor.d(a), accessor.d(b)); });
    x.domain(data.map(accessor.d));
    //y.domain(techan.scale.plot.ohlc(data, accessor).domain());
    zoom.x(x.zoomable().clamp(false));
    svg.select("g.volume").datum(data);
    svg.select("g.candlestick").datum(data).call(candlestick);
    svg.select("g.sma.ma-0").datum(techan.indicator.sma().period(20)(data)).call(sma0);
    svg.select("g.sma.ma-1").datum(techan.indicator.sma().period(50)(data)).call(sma1);
    svg.select("g.sma.ma-2").datum(techan.indicator.sma().period(200)(data)).call(sma2);
    resetChart();
  }

  function resetChart() {
    svg.on(".zoom", null);
    renderElement.on("click", enableZoom);
    zoom.scale(2);
    zoom.translate([-width-chartStartShiftToLeft,0]);
    draw();
  }

  function fullChart() {
    zoom.scale(1);
    zoom.translate([0,0]);
    draw();
  }

  function enableZoom() {
    renderElement.on("click", null);
    svg.call(zoom);
  }
  
  function enter() {
    coordsText.style("display", "inline");
  }

  function out() {
    coordsText.style("display", "none");
  }

  function move(coords) {
    coordsText.text("");
    try{
      if(!coords[0])return;
      var extra = $.grep(svg.select("g.candlestick").datum(), function(e){ return e.date === coords[0]; })[0];
      coordsText.text(
          coords[0].toLocaleString() + "; O:" + extra.open + " H:" + extra.high + " L:" + extra.low + " C:" + extra.close + " Vol:" + extra.volume.toLocaleString()
      );
    }catch (err) {
      console.debug("data resolve"+err);
    }
  }

  function onZoom() {
    var t = zoom.translate(),
    tx = t[0],
    ty = t[1];
    
    tx = Math.min(tx, chartStartShiftToLeft);
    tx = Math.max(tx, -(zoom.scale() - 1)*width - chartStartShiftToLeft);
    zoom.translate([tx, ty]);
    draw();
  }
  
  function draw() {
    var visibleData = data.filter(function(d) { 
            var dt = x(d.date);
            return dt > 0 && dt < width;
      });
    yVolume.domain(techan.scale.plot.volume(visibleData, accessor.v).domain());
    y.domain(techan.scale.plot.ohlc(visibleData, accessor).domain());
    
    svg.select("g.x.axis").call(xAxis);
    svg.select("g.y.axis").call(yAxis);
    svg.select("g.volume").call(volume);
    svg.select("g.volume.axis").call(volumeAxis);
    // using refresh method is more efficient as it does not perform any data joins
    // Use this if underlying data is not changing
//    svg.select("g.candlestick").call(candlestick.refresh);
    svg.select("g.candlestick").call(candlestick.refresh);
    // svg.select("g.crosshair").call(crosshair.refresh);
    svg.select("g.sma.ma-0").call(sma0.refresh);
    svg.select("g.sma.ma-1").call(sma1.refresh);
    svg.select("g.sma.ma-2").call(sma2.refresh);
  }
}