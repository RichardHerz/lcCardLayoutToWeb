/*
  Design, text, images and code by Richard K. Herz, 2017-2018
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// WARNING: number plot points here should match number plot points in
//          unit that generates the plot data
// where number plot points + 1 for origin are plotted

// // these vars used several places below in this file
// var numProfileVars = 4;
// var numProfilePts = 80;

// these vars used several places below in this file
var numStripVars = 4; // plotting 3 but 4th (jacket T) is saved for copy button
var numStripPts = 100;

// DECLARE PARENT OBJECT TO HOLD PLOT INFO
// more than one plot can be put one one web page by
// defining multiple object children, where the first index
// plotsObj[0] is the plot number index (starting at 0)
//
var plotsObj = new Object();
  //
  // USE THIS TO GET NUMBER OF plots, i.e., top-level children of plotsObj
  //    Object.keys(plotsObj).length;
  // except this will include any additional top level children
  //
  // WARNING: some of these object properties may be changed during
  //          operation of the program, e.g., show, scale
  //
  // plot 0 info
  plotsObj[0] = new Object();
  plotsObj[0]['name'] = 'reactor conditions';
  plotsObj[0]['type'] = 'strip';
  plotsObj[0]['canvas'] = '#div_PLOTDIV_plotData';
  plotsObj[0]['numberPoints'] = numStripPts;
  // plot has numberPoints + 1 pts!
  plotsObj[0]['xAxisLabel'] = '< recent time | earlier time (s) >';
  // xAxisShow false does not show numbers, nor label, nor grid for x-axis
  // might be better to cover numbers if desire not to show numbers
  plotsObj[0]['xAxisShow'] = 1; // 0 false, 1 true
  plotsObj[0]['xAxisMin'] = 0;
  plotsObj[0]['xAxisMax'] = numStripPts * simParams.simTimeStep * simParams.simStepRepeats;
  plotsObj[0]['xAxisReversed'] = 1; // 0 false, 1 true, when true, xmax on left
  plotsObj[0]['yLeftAxisLabel'] = 'Reactant Concentration';
  plotsObj[0]['yLeftAxisMin'] = 0;
  plotsObj[0]['yLeftAxisMax'] = 400;
  plotsObj[0]['yRightAxisLabel'] = 'Temperature (K)';
  plotsObj[0]['yRightAxisMin'] = 300;
  plotsObj[0]['yRightAxisMax'] = 400;
  plotsObj[0]['plotLegendPosition'] = "ne";
  plotsObj[0]['var'] = new Array();
    plotsObj[0]['var'][0] = 0; // values are curve data number to be put on plot
    plotsObj[0]['var'][1] = 1; // listed in order of varLabel order, etc.
    plotsObj[0]['var'][2] = 2;
  plotsObj[0]['varLabel'] = new Array();
    plotsObj[0]['varLabel'][0] = 'Reactant conc.'; // 1st var
    plotsObj[0]['varLabel'][1] = 'Reactor T';
    plotsObj[0]['varLabel'][2] = 'Jacket inlet T';
    plotsObj[0]['varLabel'][3] = 'Jacket T'; // for copy data column label
  plotsObj[0]['varShow'] = new Array();
    plotsObj[0]['varShow'][0] = 'show'; // 1st var
    plotsObj[0]['varShow'][1] = 'show';
    plotsObj[0]['varShow'][2] = 'show';
  plotsObj[0]['varYaxis'] = new Array();
    plotsObj[0]['varYaxis'][0] = 'left'; // 1st var
    plotsObj[0]['varYaxis'][1] = 'right';
    plotsObj[0]['varYaxis'][2] = 'right';
  plotsObj[0]['varYscaleFactor'] = new Array();
    plotsObj[0]['varYscaleFactor'][0] = 1; // 1st var
    plotsObj[0]['varYscaleFactor'][1] = 1;
    plotsObj[0]['varYscaleFactor'][2] = 1;
  // ALTERNATIVE to separate arrays for variable number, show, axis
  //    might be to have one array per variable equal to an array of info...?
  //

  // DEFINE plotFlag ARRAY so don't have to generate
  // entire plot everytime want to just change data (and not axes, etc.)
  // for example, for 4 plots on page, this ran in 60% of time for full refresh
  // plotFlag array used in function plotPlotData
  //
  // WARNING: plotFlag ARRAY MUST BE DEFINED AFTER ALL plotsObj CHILDREN
  //
  var npl = Object.keys(plotsObj).length; // number of plots
  var p; // used as index
  var plotFlag = [0];
  for (p = 1; p < npl; p += 1) {
    plotFlag.push(0);
  }

  function initPlotData(numVars,numPlotPoints) {
    // returns 3D array to hold x,y scatter plot data for multiple variables
    // inputs are list of variables and # of x,y point pairs per variable
    // returns array with all elements for plot filled with zero
    //    index 1 specifies the variable [0 to numVars-1],
    //    index 2 specifies the data point pair [0 to & including numPlotPoints]
    //    index 3 specifies x or y in x,y data point pair [0 & 1]
    var v;
    var p;
    var plotDataStub = new Array();
    for (v = 0; v < numVars; v += 1) {
      plotDataStub[v] = new Array();
      for (p = 0; p <= numPlotPoints; p += 1) { // NOTE = AT p <=
        plotDataStub[v][p] = new Array();
        plotDataStub[v][p][0] = 0;
        plotDataStub[v][p][1] = 0;
      }
    }
    return plotDataStub;
    // Note above initialize values for
    //    plotDataStub [0 to numVars-1] [0 to numPlotPoints] [0 & 1]
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
  } // end function initPlotData

  // INITIALIZE DATA ARRAYS - must follow function initPlotData in this file
  // var profileData = initPlotData(numProfileVars,numProfilePts); // holds data for static profile plots
  var stripData = initPlotData(numStripVars,numStripPts); // holds data for scrolling strip chart plots

  // document.getElementById("dev01").innerHTML = "just after var stripData = ";
