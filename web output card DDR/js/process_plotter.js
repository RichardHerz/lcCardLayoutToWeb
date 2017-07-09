/*
  Design, text, images and code by Richard K. Herz, 2017
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

/* WARNING - WARNING 
  This copy of process_plotter.js has additional lines for specific web lab
  See:  if (puCatalystLayer.model == 1 && plotsObjNum == 0 && v == 1)
  which is specific to reaction-diffusion web app
*/

// set up flag and plot array so don't have to generate
// entire plot everytime want to just change data (and not axes, etc.)
// Speed change in desktop Chrome is 3 sec vs. 5 sec.
// Speed change in iPhone Chrome is 11 sec vs. 16 sec

// var npl = Object.keys(plotsObj).length; // number of plots
// var p; // used as index
// var plotFlag = [0];
// for (p = 1; p < npl; p += 1) {
//   plotFlag.push(0);
// }
// xxx getting error that plotsObj does't exist yet...
// xxx so don't automate and enter 0's for each plot

plotFlag = [0,0,0,0];
var plot = [];

function initPlotData2(numVar,numPlotPoints) {
  // returns 3D array to hold x,y scatter plot data for multiple variables
  // inputs are list of variables and # of x,y point pairs per variable
  // returns array with all elements for plot filled with zero
  //    index 1 specifies the variable,
  //    index 2 specifies the data point pair
  //    index 3 specifies x or y in x,y data point pair
  var v;
  var p;
  var plotDataStub = new Array();
  for (v = 0; v < numVar; v += 1) {
    plotDataStub[v] = new Array();
    for (p = 0; p <= numPlotPoints; p += 1) { // NOTE = AT p <=
      plotDataStub[v][p] = new Array();
      plotDataStub[v][p][0] = 0;
      plotDataStub[v][p][1] = 0;
    }
  }
  return plotDataStub;
  // Note above initialize values for
  //    plotDataStub [0 to numVar-1] [0 to numPlotPoints] [0 & 1]
  // If want later outside this constructor to add new elements,
  // then you can do easily for 3rd index, e.g.,
  //    plotDataStub [v] [p] [2] = 0;
  // But can NOT do assignment for [v] [p+1] [0] since p+1 element does not yet
  // exist, where here p = numPlotPoints+1.
  // Would have to first create new p+1 array
  //    plotDataStub [v] [p+1] = new Array();
  // Then can do
  //    plotDataStub [v] [p+1] [0] = 0;
  //    plotDataStub [v] [p+1] [1] = 0; // etc.
} // end function initPlotData2

// ----- GET DATA IN FORM NEEDED FOR PLOTTING ---------

function getPlotData2(plotsObjNum) {

  // input argument plotsObjNum refers to plot number in object plotsObj

  var v = 0; // used as index to select the variable
  var p = 0; // used as index to select data point pair
  var n = 0; // used as index
  var sf = 1; // scale factor used below

  var numPlotPoints = plotsObj[plotsObjNum]['numberPoints'];
  // plot will have 0 to numberPoints for total of numberPoints + 1 points
  var varNumbers = plotsObj[plotsObjNum]['var'];
  var numVar = varNumbers.length;
  var plotData = initPlotData2(numVar,numPlotPoints)

  // document.getElementById("dev02").innerHTML = "type = " + plotsObj[plotsObjNum]['type'];

  // gat data for plot
  for (v = 0; v < numVar; v += 1) {
    // get number n of variable listed in plotsObj for profileData array
    n = varNumbers[v];
    for (p = 0; p <= numPlotPoints; p += 1) {
      // note want p <= numPlotPoints so get # 0 to # numPlotPoints of points
      // WARNING profileData and stripData are differences below in IF BLOCK
      if (plotsObj[plotsObjNum]['type'] == 'profile') {
        plotData[v][p][0] = profileData[n][p][0];
        plotData[v][p][1] = profileData[n][p][1]; // <<< PROFILEdata
      } else {
        plotData[v][p][0] = stripData[n][p][0]; // <<< STRIPdata
        plotData[v][p][1] = stripData[n][p][1];
      }
    }
  }

  // scale y-axis values if scale factor not equal to 1
  for (v = 0; v < numVar; v += 1) {
    sf = plotsObj[plotsObjNum]['varYscaleFactor'][v];

    // if model 1, then shift rate curve below coverage curve so can see it
    // plotsObj[0]['varYscaleFactor'][1]
    if (puCatalystLayer.model == 1 && plotsObjNum == 0 && v == 1) {
      sf = 0.97;
    }

    if (sf != 1) {
      for (p = 0; p <= numPlotPoints; p += 1) {
        plotData[v][p][1] = sf * plotData[v][p][1];
      }
    }
  }

  return plotData;

} // END OF function getPlotData2

// ----- FUNCTION TO PLOT DATA ---------

function plotPlotData2(pData,pNumber) {

  // SEE WEB SITE OF flot.js
  //     http://www.flotcharts.org/
  // SEE DOCUMENTATION FOR flot.js
  //     https://github.com/flot/flot/blob/master/API.md
  // axisLabels REQUIRES LIBRARY flot.axislabels.js, SEE
  //     https://github.com/markrcote/flot-axislabels

  // input pData holds the data to plot
  // input pNumber is number of plot as 1st index in plotsObj

  // get info about the variables

  var plotList = plotsObj[pNumber]['var'];
  // plotList is array whose elements are the values of the
  // first index in pData array which holds the x,y values to plot

  // document.getElementById("dev02").innerHTML = "var = " + plotsObj[pNumber]['var'];

  var k = 0; // used as index in plotList
  var v = 0; // value of element k in plotList
  var vLabel = []; // array to hold variable names for plot legend
  var yAxis = []; // array to hold y-axis, "left" or "right"
  var vShow = []; // array to hold "show" or "hide" (hide still in copy-save data)
  plotList.forEach(fGetAxisData);
  function fGetAxisData(v,k) {
	  // v = value of element k of plotList array
    // k is index of plotList array
    yAxis[k] = plotsObj[pNumber]['varYaxis'][k]; // get "left" or "right" for plot y axis
    vShow[k] = plotsObj[pNumber]['varShow'][k]; // get "show" or "hide"
    vLabel[k] = plotsObj[pNumber]['varLabel'][k];
  }

  // put data in form needed by flot.js

  var plotCanvasHtmlID = plotsObj[pNumber]['canvas'];

  var dataToPlot = [];
  var numVar = plotList.length;
  var numToShow = 0; // index for variables to show on plot
  // KEEP numToShow as well as for index k because not all k vars will show!
  // only variables with property "show" will appear on plot
  for (k = 0; k < numVar; k += 1) {
    // add object for each plot variable to array dataToPlot
    // e.g., { data: y1Data, label: y1DataLabel, yaxis: 1 },
    if (vShow[k] === 'show') {
      // XXX THIS CHECK OF "SHOW" COULD BE MOVED UP INTO
      // getPlotData2 FUNCTION WHERE DATA SELECTED TO PLOT
      // SINCE BOTH FUNCTIONS ARE CALLED EACH PLOT UPDATE...
      let newobj = {};
      // pData is not full profileData nor full stripData
      // pData has the variables specified in plotsObj[pNumber]['var']
      // now want to select the vars in pData with "show" property true
      newobj.data = pData[k];
      newobj.label = vLabel[k];
      if (yAxis[k] === 'right') {newobj.yaxis = 1;} else {newobj.yaxis = 2;}
      dataToPlot[numToShow] = newobj;
      // KEEP numToShow as well as for index k because not all k vars will show!
      numToShow += 1;
    }
  }

// document.getElementById("dev01").innerHTML = "dataToPlot[0].data = " + dataToPlot[0].data;
// document.getElementById("dev02").innerHTML = "dataToPlot[1].data = " + dataToPlot[1].data;

  // set up the plot axis labels and plot legend

  var xLabel = plotsObj[pNumber]['xAxisLabel'];;
  var xMin= plotsObj[pNumber]['xAxisMin'];
  var xMax = plotsObj[pNumber]['xAxisMax'];
  var yLeftLabel = plotsObj[pNumber]['yLeftAxisLabel'];
  var yLeftMin = plotsObj[pNumber]['yLeftAxisMin'];
  var yLeftMax = plotsObj[pNumber]['yLeftAxisMax'];
  var yRightLabel = plotsObj[pNumber]['yRightAxisLabel'];
  var yRightMin = plotsObj[pNumber]['yRightAxisMin'];
  var yRightMax = plotsObj[pNumber]['yRightAxisMax'];
  var plotLegendPosition = plotsObj[pNumber]['plotLegendPosition'];

  var options = {
    // axisLabels REQUIRES LIBRARY flot.axislabels.js, SEE
    //     https://github.com/markrcote/flot-axislabels
    axisLabels : {show: true},
    xaxes: [ { min: xMin, max: xMax, axisLabel: xLabel } ],
    yaxes: [
      // yaxis object listed first is "yaxis: 1" in dataToPlot, second is 2
      {position: 'right', min: yRightMin, max: yRightMax, axisLabel: yRightLabel },
      {position: 'left', min: yLeftMin, max: yLeftMax, axisLabel: yLeftLabel },
    ],
    legend: { position: plotLegendPosition }
  };

  // check if want to reverse data left-right on x-axis
  // when reversed, xmax is on left, xmin on right
  if (plotsObj[pNumber]['xAxisReversed']) {
    options.xaxis = {
      transform: function (v) { return -v; },
      inverseTransform: function (v) { return -v; }
    }
  }

// only draw plot with axes and all options the first time /
// after that just setData ad re-draw
// for 4 plots, this runs in 60% of the time
if (plotFlag[pNumber] == 0) {
  plotFlag[pNumber] = 1;
  // var plot = $.plot($(plotCanvasHtmlID), dataToPlot, options);
  plot[pNumber] = $.plot($(plotCanvasHtmlID), dataToPlot, options);
} else {
  plot[pNumber].setData(dataToPlot);
  plot[pNumber].draw();
}

} // END OF function plotPlotData2

// ----- FUNCTION TO COPY PLOT DATA TO TEXT IN WINDOW ---------

function copyData() {
  // opens child window with data in plot + hidden variables in simParams.plotList
  // uses data from 3D array plotData and also
  // uses data from simParams object in file proces_units.js

  // if simulation is running, pause it so user can make notes
  var runningFlag = simParams.runningFlag;
  if (runningFlag) {runThisLab();}

  var p = 0; // used as index to select the variable
  var k = 0; // used as index to select data point pair
  var pv = []; // array to hold info about plot variables
  var plotList = simParams.plotVariables;
  var numVar = plotList.length;
  var plotVarName = [];
  var plotVarUnits = [];
  var tmpFunc = new Function("return null;"); // tmpFunc used below

  // get current values name and units of process variables
  plotList.forEach(fGetData);
  function fGetData(pv,p) {  // p is index of "pv" array in plotVariables array
	  // pv = entire individual array element of plotList array
  	let puName = pv[0]; // get process unit name
  	let varName = pv[1]; // get variable object name
    // now need to get var label, units, etc. from puName.varName object
    tmpFunc = new Function("return " + puName + "." + varName + ".name;");
    plotVarName[p] = tmpFunc();
    tmpFunc = new Function("return " + puName + "." + varName + ".units;");
    plotVarUnits[p] = tmpFunc();
  }

  var numPlotPoints = simParams.numPlotPoints;
  var tText; // we will put the data into this variable
  var tItemDelimiter = ", &nbsp;"

  // Some labels & data variables may contain no data because they are not
  // specified in simParams object as plot variables.

  tText = "<p>Copy and paste these data into a text file for loading into your analysis program.</p>";
  tText += "<p>time (s)";
  for (p = 0; p < numVar; p += 1) {
    if (plotVarName[p] !== "") {tText += tItemDelimiter + plotVarName[p] + "&nbsp;" + plotVarUnits[p];}
  }
  tText += "</>";

  // use !== undefined below because !== "" is not true (== "" is true) for zero numeric value
  // values must be numbers for .toFixed() or .toPrecision() to work,
  // so use Number() conversion here (and when getting data from html input fields)

  // xxx WOULD IT BE FASTER to check only 1st array element and set flags
  //     and then only check flags in repeat loop?

  tText += "<p>";
  for (k = 0; k <= numPlotPoints; k += 1) {
      // process row of data
      // get time of row of data from 1st [0] variable's data
      if (plotData[0][k][0] !== undefined) {tText += Number(plotData[0][k][0]).toPrecision(3);}
      // get the value [1] for each variable for this row
      for (p = 0; p < numVar; p += 1) {
        if (plotData[p][k][1] !== undefined) {tText += tItemDelimiter + Number(plotData[p][k][1]).toPrecision(3);}
      }
    tText += "<br>" // use <br> not <p> or get empty line between each row
  }

  tText += "</p>";

  // for window.open, see http://www.w3schools.com/jsref/met_win_open.asp
  dataWindow = window.open("", "Copy data",
        "height=600, left=20, resizable=1, scrollbars=1, top=40, width=600");
  dataWindow.document.writeln("<html><head><title>Copy data</title></head>" +
         "<body>" +
         tText +
         "</body></html>");
  dataWindow.document.close();

 } // end of function copyData
