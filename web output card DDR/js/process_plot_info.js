/*
  Design, text, images and code by Richard K. Herz, 2017
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// data for strip charts - data moves across plot window
// [0] is reactant in, [1] is reactant out, [2] is product out
// numberPoints + 1 for origin
// WARNING: where numberPoints here should match numberPoints below
//          in plotsObj for the strip charts and they should all have
//          save number of points OR GET variables shifted by shift/push methods
//          from each other, e.g., jumps in output for constant input
//
// INPUTS ARE: initPlotData2(numberVariables,numberPoints);
var numStripVars = 3;
var numStripPoints = 80;
var stripData = initPlotData2(numStripVars,numStripPoints);
// data for profile plots - data static in plot window
// [0] is reactant gas, [1] is product gas, [2] is coverage, [3] is local rate
// number plot points + 1 for origin
// WARNING: where numberPoints here should match numNodes in
//          updateState that generates the profile data
// INPUTS ARE: initPlotData2(numberVariables,numberPoints);
var profileData = initPlotData2(4,puCatalystLayer.numNodes); // holds data for profile plots

// declare parent OBJECT to hold plot info
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
  plotsObj[0]['name'] = 'surface profiles';
  plotsObj[0]['type'] = 'profile';
  plotsObj[0]['canvas'] = '#div_plotCanvasSurface_1189';
  plotsObj[0]['numberPoints'] = puCatalystLayer.numNodes; // should match numNodes in process unit
  // plot has numberPoints + 1 pts!
  plotsObj[0]['xAxisLabel'] = 'surface in layer';
  plotsObj[0]['xAxisMin'] = 0;
  plotsObj[0]['xAxisMax'] = 1;
  plotsObj[0]['xAxisReversed'] = 1; // 0 false, 1 true, when true, xmax on left
  plotsObj[0]['yLeftAxisLabel'] = '';
  plotsObj[0]['yLeftAxisMin'] = 0;
  plotsObj[0]['yLeftAxisMax'] = 1;
  plotsObj[0]['yRightAxisLabel'] = 'yRight';
  plotsObj[0]['yRightAxisMin'] = 0;
  plotsObj[0]['yRightAxisMax'] = 1;
  plotsObj[0]['plotLegendPosition'] = "ne";
  plotsObj[0]['var'] = new Array();
    plotsObj[0]['var'][0] = 2; // 1st var in profile data array
    plotsObj[0]['var'][1] = 3; // 2nd var
  plotsObj[0]['varLabel'] = new Array();
    plotsObj[0]['varLabel'][0] = 'AS';
    plotsObj[0]['varLabel'][1] = 'rate';
  plotsObj[0]['varShow'] = new Array();
    plotsObj[0]['varShow'][0] = 'show'; // 1st var
    plotsObj[0]['varShow'][1] = 'show';
  plotsObj[0]['varYaxis'] = new Array();
    plotsObj[0]['varYaxis'][0] = 'left'; // 1st var
    plotsObj[0]['varYaxis'][1] = 'left';
  plotsObj[0]['varYscaleFactor'] = new Array();
    plotsObj[0]['varYscaleFactor'][0] = 1; // 1st var
    plotsObj[0]['varYscaleFactor'][1] = 1;
  // ALTERNATIVE to separate arrays for variable number, show, axis
  //    might be to have one array per variable equal to an array of info...?
  //
  // plot 1 info
  plotsObj[1] = new Object();
  plotsObj[1]['name'] = 'pellet gas';
  plotsObj[1]['type'] = 'profile';
  plotsObj[1]['canvas'] = '#div_plotCanvasGas_1192';
  plotsObj[1]['numberPoints'] = puCatalystLayer.numNodes;
  // plot has numberPoints + 1 pts!
  plotsObj[1]['xAxisLabel'] = 'gas in layer';
  plotsObj[1]['xAxisMin'] = 0;
  plotsObj[1]['xAxisMax'] = 1;
  plotsObj[1]['xAxisReversed'] = 1; // 0 false, 1 true, when true, xmax on left
  plotsObj[1]['yLeftAxisLabel'] = '';
  plotsObj[1]['yLeftAxisMin'] = 0;
  plotsObj[1]['yLeftAxisMax'] = 1;
  plotsObj[1]['yRightAxisLabel'] = 'yRight';
  plotsObj[1]['yRightAxisMin'] = 0;
  plotsObj[1]['yRightAxisMax'] = 1;
  plotsObj[1]['plotLegendPosition'] = "ne";
  plotsObj[1]['var'] = new Array();
    plotsObj[1]['var'][0] = 0; // 1st var in profile data array
    plotsObj[1]['var'][1] = 1;
  plotsObj[1]['varLabel'] = new Array();
    plotsObj[1]['varLabel'][0] = 'A';
    plotsObj[1]['varLabel'][1] = 'B';
  plotsObj[1]['varShow'] = new Array();
    plotsObj[1]['varShow'][0] = 'show'; // 1st var
    plotsObj[1]['varShow'][1] = 'show';
  plotsObj[1]['varYaxis'] = new Array();
    plotsObj[1]['varYaxis'][0] = 'left'; // 1st var
    plotsObj[1]['varYaxis'][1] = 'left';
  plotsObj[1]['varYscaleFactor'] = new Array();
    plotsObj[1]['varYscaleFactor'][0] = 1; // 1st var
    plotsObj[1]['varYscaleFactor'][1] = 1;
  // ALTERNATIVE to separate arrays for variable number, show, axis
  //    might be to have one array per variable equal to an array of info...?
  //
  // plot 2 info
  plotsObj[2] = new Object();
  plotsObj[2]['name'] = 'inlet gas';
  plotsObj[2]['type'] = 'strip';
  plotsObj[2]['canvas'] = '#div_plotCanvasInlet_1195';
  plotsObj[2]['numberPoints'] = numStripPoints;
  // plot has numberPoints + 1 pts!
  plotsObj[2]['xAxisLabel'] = '< recent time | past time >';
  plotsObj[2]['xAxisMin'] = 0;
  // xAxisMax should = numberPoints * dt * stepRepeats
  plotsObj[2]['xAxisMax'] = numStripPoints * simParams.dt * simParams.stepRepeats;
  plotsObj[2]['xAxisReversed'] = 0; // 0 false, 1 true, when true, xmax on left
  plotsObj[2]['yLeftAxisLabel'] = '';
  plotsObj[2]['yLeftAxisMin'] = 0;
  plotsObj[2]['yLeftAxisMax'] = 1;
  plotsObj[2]['yRightAxisLabel'] = 'yRight';
  plotsObj[2]['yRightAxisMin'] = 0;
  plotsObj[2]['yRightAxisMax'] = 1;
  plotsObj[2]['plotLegendPosition'] = "ne";
  plotsObj[2]['var'] = new Array();
    plotsObj[2]['var'][0] = 0; // 1st var in profile data array
    // plotsObj[2]['var'][1] = 1;
  plotsObj[2]['varLabel'] = new Array();
    plotsObj[2]['varLabel'][0] = 'A in';
    // plotsObj[2]['varLabel'][1] = 'B';
  plotsObj[2]['varShow'] = new Array();
    plotsObj[2]['varShow'][0] = 'show'; // 1st var
    // plotsObj[2]['varShow'][1] = 'show';
  plotsObj[2]['varYaxis'] = new Array();
    plotsObj[2]['varYaxis'][0] = 'left'; // 1st var
    // plotsObj[2]['varYaxis'][1] = 'left';
  plotsObj[2]['varYscaleFactor'] = new Array();
    plotsObj[2]['varYscaleFactor'][0] = 1; // 1st var
    plotsObj[2]['varYscaleFactor'][1] = 1;
  // ALTERNATIVE to separate arrays for variable number, show, axis
  //    might be to have one array per variable equal to an array of info...?
  //
  // plot 3 info
  plotsObj[3] = new Object();
  plotsObj[3]['name'] = 'outlet gas';
  plotsObj[3]['type'] = 'strip';
  plotsObj[3]['canvas'] = '#div_plotCanvasOutlet_1196';
  plotsObj[3]['numberPoints'] = numStripPoints;
  // plot has numberPoints + 1 pts!
  plotsObj[3]['xAxisLabel'] = '< recent time | past time >';
  plotsObj[3]['xAxisMin'] = 0;
  // xAxisMax should = numberPoints * dt * stepRepeats
  plotsObj[3]['xAxisMax'] = numStripPoints * simParams.dt * simParams.stepRepeats;
  plotsObj[3]['xAxisReversed'] = 0; // 0 false, 1 true, when true, xmax on left
  plotsObj[3]['yLeftAxisLabel'] = '';
  plotsObj[3]['yLeftAxisMin'] = 0;
  plotsObj[3]['yLeftAxisMax'] = 1;
  plotsObj[3]['yRightAxisLabel'] = 'yRight';
  plotsObj[3]['yRightAxisMin'] = 0;
  plotsObj[3]['yRightAxisMax'] = 1;
  plotsObj[3]['plotLegendPosition'] = "ne";
  plotsObj[3]['var'] = new Array();
    plotsObj[3]['var'][0] = 1; // 1st var in profile data array
    plotsObj[3]['var'][1] = 2;
  plotsObj[3]['varLabel'] = new Array();
    plotsObj[3]['varLabel'][0] = 'A out';
    plotsObj[3]['varLabel'][1] = 'B out';
  plotsObj[3]['varShow'] = new Array();
    plotsObj[3]['varShow'][0] = 'show'; // 1st var
    plotsObj[3]['varShow'][1] = 'show';
  plotsObj[3]['varYaxis'] = new Array();
    plotsObj[3]['varYaxis'][0] = 'left'; // 1st var
    plotsObj[3]['varYaxis'][1] = 'left';
  plotsObj[3]['varYscaleFactor'] = new Array();
    plotsObj[3]['varYscaleFactor'][0] = 1; // 1st var
    plotsObj[3]['varYscaleFactor'][1] = 1;
  // ALTERNATIVE to separate arrays for variable number, show, axis
  //    might be to have one array per variable equal to an array of info...?
  //
