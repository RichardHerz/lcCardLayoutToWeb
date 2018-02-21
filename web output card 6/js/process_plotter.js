/*
  Design, text, images and code by Richard K. Herz, 2017-2018
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// declare plot array used below in function plotPlotData
// does not work when declared inside function plotPlotData...
var plot = [];

// ----- GET DATA IN FORM NEEDED FOR PLOTTING ---------

function getPlotData(plotsObjNum) {

  // input argument plotsObjNum refers to plot number in object plotsObj

  var v = 0; // used as index to select the variable
  var p = 0; // used as index to select data point pair
  var n = 0; // used as index
  var sf = 1; // scale factor used below
  var numPlotPoints = plotsObj[plotsObjNum]['numberPoints'];
  // plot will have 0 to numberPoints for total of numberPoints + 1 points
  var varNumbers = plotsObj[plotsObjNum]['var'];
  var numVar = varNumbers.length;
  var plotData = initPlotData(numVar,numPlotPoints)

  // get data for plot
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
    if (sf != 1) {
      for (p = 0; p <= numPlotPoints; p += 1) {
        plotData[v][p][1] = sf * plotData[v][p][1];
      }
    }
  }

  return plotData;

} // END OF function getPlotData

// ----- FUNCTION TO PLOT DATA ---------

function plotPlotData(pData,pNumber) {

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
    // e.g., { data: y1Data, label: y1DataLabel, yaxis: 1 }
    let newobj = {};
    if (vShow[k] === 'show') {
      // XXX THIS CHECK OF "SHOW" COULD BE MOVED UP INTO
      // getPlotData FUNCTION WHERE DATA SELECTED TO PLOT
      // SINCE BOTH FUNCTIONS ARE CALLED EACH PLOT UPDATE...
      // pData is not full profileData nor full stripData
      // pData has the variables specified in plotsObj[pNumber]['var']
      // now want to select the vars in pData with "show" property true
      // *BUT* see "else" condition below
      newobj.data = pData[k];
      newobj.label = vLabel[k];
      if (yAxis[k] === 'right') {newobj.yaxis = 1;} else {newobj.yaxis = 2;}
      dataToPlot[k] = newobj;
    } else {
      // do not plot this variable
      // *BUT* need to add a single point in case no vars on this axis to show
      // in which case no axis labels will show without this single point
      newobj.data = [plotsObj[pNumber]['xAxisMax'],plotsObj[pNumber]['yLeftAxisMax']];
      newobj.label = vLabel[k];
      if (yAxis[k] === 'right') {newobj.yaxis = 1;} else {newobj.yaxis = 2;}
      dataToPlot[k] = newobj;
    }
  } // END OF for (k = 0; k < numVar; k += 1) {

  // set up the plot axis labels and plot legend

  var xShow = plotsObj[pNumber]['xAxisShow'];
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
    xaxes: [ { show: xShow, min: xMin, max: xMax, axisLabel: xLabel } ],
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
  // after that just setData and re-draw
  // for example, for 4 plots on page, this ran in 60% of time for full refresh
  // array plotFlag declared in file process_plot_info.js
  // array plot declared above in this file
  if (plotFlag[pNumber] == 0) {
    plotFlag[pNumber] = 1;
    plot[pNumber] = $.plot($(plotCanvasHtmlID), dataToPlot, options);
  } else {
    plot[pNumber].setData(dataToPlot);
    plot[pNumber].draw();
  }

} // END OF function plotPlotData

function copyData(){

  // if sim is running, pause the sim
  // copy grabs what is showing on plot when copy button clicked
  // so want user to be able to take screenshot to compare with data copied
  var runningFlag = simParams.runningFlag;
  if (runningFlag) {
    runThisLab(); // toggles running state
  }

  var p = 0; // plot index
  var v; // variable index
  var k; // points index
  var tText; // we will put the data into this variable
  var tItemDelimiter = ', &nbsp;'

  tText = '<p>Copy and paste these data into a text file for loading into your analysis program.</p>';

  // column headers
  tText += '<p>';
  tText += 'Time' + tItemDelimiter;
  tText += plotsObj[0]['varLabel'][0] + tItemDelimiter +
           plotsObj[0]['varLabel'][1] + tItemDelimiter +
           plotsObj[0]['varLabel'][2] + tItemDelimiter +
           plotsObj[0]['varLabel'][3];
  tText += '</p>';

  // data values must be numbers for .toFixed(2) to work, use Number() conversion
  // when getting values from input fields
  //    index 1 specifies the variable [0 to numVars-1],
  //    index 2 specifies the data point pair [0 to & including numPlotPoints]
  //    index 3 specifies x or y in x,y data point pair [0 & 1]

  tText += '<p>';
  for (k = 0; k <= plotsObj[p]['numberPoints']; k += 1){
  // or use next line to reverse order
  // for (k = plotsObj[p]['numberPoints']; k >= 0; k -= 1){
    tText += stripData[0][k][0].toFixed(2) + tItemDelimiter + // [k][0] is x value (time)
             stripData[0][k][1].toFixed(2) + tItemDelimiter + // [k][1] is y value
             stripData[1][k][1].toFixed(2) + tItemDelimiter +
             stripData[2][k][1].toFixed(2) + tItemDelimiter +
             stripData[3][k][1].toFixed(2) +
             '<br>'; // use <br> not <p> or get empty line between each row
  }
  tText += '</p>';

  // for window.open, see http://www.w3schools.com/jsref/met_win_open.asp
  dataWindow = window.open('', 'Copy data',
        'height=600, left=20, resizable=1, scrollbars=1, top=40, width=600');
  dataWindow.document.writeln('<html><head><title>Copy data</title></head>' +
         '<body>' +
         tText +
         '</body></html>');
  dataWindow.document.close();

 } // end of function copyData
