/*
  Design, text, images and code by Richard K. Herz, 2017-2018
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// This file defines an object that holds simulation parameter values and
// defines objects that represent process units
// For functions that use these objects, see files
// process_main.js and process_plotter.js.

// ----- ARRAYS TO HOLD WORKING DATA -----------

var tempArray = []; // for shifting data in strip chart plots
// var spaceData = []; // for shifting data in space-time plots

// ----- SEE process_plot_info.js FOR INITIALIZATION OF ---------------
// ----- OTHER DATA ARRAYS --------------------------------------------

// ----- OBJECT TO CONTAIN & SET SIMULATION & PLOT PARAMETERS ---------

var simParams = {

  runningFlag : false, // set runningFlag to false initially
  runButtonID : "button_runButton", // for functions to run, reset, copy data
  // URLs for methods updateRunCount and updateCurrentRunCountDisplay below
  runLoggerURL : "../webAppRunLog.lc",
  runCurrrentRunCountURL : "../webAppCurrentCount.lc",
  // warning: this.runCounterFieldID does NOT work below in logger URL methods
  // need literal field ID string in methods below
  runCounterFieldID : "field_run_counter", // not used, see 2 lines above

  // all units use simParams.simTimeStep, getting it at each step in unit updateInputs()
  // see method simParams.changeSimTimeStep() below to change simTimeStep value
  // WARNING: DO NOT CHANGE simTimeStep BETWEEN display updates

  simStepRepeats : 40, // integer number of unit updates between display updates
  simTimeStep : 0.1, // time step value, simulation time, of main repeat

  // individual units may do more steps in one unit updateState()
  // see individual units for any unitTimeStep and unitStepRepeats

  updateDisplayTimingMs : 50, // real time milliseconds between display updates

  simTime : 0, // (s), time, initialize simulation time, also see resetSimTime

  // LIST ACTIVE PROCESS UNITS
  // processUnits array is the list of names of active process units
  // the order of units in the list is not important

  processUnits : [
    "unit_1", "unit_2", "unit_3", "unit_4", "unit_5"
  ],

  // NOT ACTIVE YET
  updateRunCount : function() {
    // // need literal "field_run_counter" below - this.runCounterFieldID does NOT work
    // $.post(this.runLoggerURL,{webAppNumber: "2, rxn-diff"}) .done(function(data) {
    //   document.getElementById("field_run_counter").innerHTML = "<i>Total runs = " + data + "</i>"; } );
  },

  // NOT ACTIVE YET
  updateCurrentRunCountDisplay : function() {
    // // need literal "field_run_counter" below - this.runCounterFieldID does NOT work
    // $.post(this.runCurrrentRunCountURL) .done(function(data) {
    //   document.getElementById("field_run_counter").innerHTML = "<i>Total runs = " + data + "</i>"; } );
  },

  resetSimTime : function() {
    this.simTime = 0;
  },

  updateSimTime : function() {
    this.simTime = this.simTime + this.simTimeStep;
  },

  // runningFlag value can change by click of RUN-PAUSE or RESET buttons
  // calling functions toggleRunningFlag and stopRunningFlag
  toggleRunningFlag : function() {
    this.runningFlag = !this.runningFlag;
  },

  stopRunningFlag : function() {
    this.runningFlag = false;
  },

  changeSimTimeStep : function(factor) {
    // WARNING: do not change simTimeStep except immediately before or after a
    // display update in order to maintain sync between sim time and real time
    this.simTimeStep = factor * this.simTimeStep;
  }

}; // END var simParams

// ------------ PROCESS UNIT OBJECT DEFINITIONS ----------------------

// EACH PROCESS UNIT DEFINITION MUST CONTAIN AT LEAST THESE 5 FUNCTIONS:
//   reset, updateUIparams, updateInputs, updateState, display
// WARNING: THESE FUNCTION DEFINITIONS MAY BE EMPTY BUT MUST BE PRESENT

// -------------------------------------------------------------------

// unit_1 - reactor feed - OBJECT DEFINITION
var unit_1 = {
  //
  // unit_1 IS REACTOR FEED
  //
  // USES OBJECT simParams
  // OUTPUT CONNECTIONS FROM THIS UNIT TO OTHER UNITS
  //   unit_2 USES unit_1.rate
  //   unit_2 USES unit_1.conc
  //   unit_2 USES unit_1.TTemp
  //   (1) reactor feed, (2) reactor, (3) feed to jacket, (4) jacket, (5) controller
  // INPUT CONNECTIONS TO THIS UNIT FROM OTHER UNITS, see updateInputs below
  //   none
  // INPUT CONNECTIONS TO THIS UNIT FROM HTML UI CONTROLS, see updateUIparams below

  // variables defined here are available to all functions inside this unit

  initialRate	: 0, // (m3/s), feed flow rate
  rate      : this.initialRate, // (m3/s), feed flow rate

  initialConc	: 0,
  conc      : this.initialConc,

  initialTTemp	: 300, // (K), TTemp = temperature
  TTemp     : this.initialTTemp,

  reset : function(){
    // On 1st load or reload page, the html file fills the fields with html file
    // values and calls reset, which needs updateUIparams to get values in fields.
    // On click reset button but not reload page, unless do something else here,
    // reset function will use whatever last values user has entered.
    this.updateUIparams(); // this first, then set other values as needed
    // set state variables not set by updateUIparams to initial settings
    //    no more here
  },  // << COMMAS ARE REQUIRED AT END OF EACH OBJECT PROPERTY & FUNCTION EXCEPT LAST ONE (NO ;)

  updateUIparams : function(){
    // (1) enterFeedConc, enterFeedTTemp, enterFeedFlowRate
    this.conc = Number(input_field_enterFeedConc.value);
    this.TTemp = Number(input_field_enterFeedTTemp.value);
    this.rate = Number(input_field_enterFeedFlowRate.value);
  },

  updateInputs : function(){
    // GET INPUT CONNECTION VALUES FROM OTHER UNITS FROM PREVIOUS TIME STEP,
    // SINCE updateInputs IS CALLED BEFORE updateState IN EACH TIME STEP
    //    none for this unit
  },

  updateState : function(){
    // BEFORE REPLACING PREVIOUS STATE VARIABLE VALUE WITH NEW VALUE, MAKE
    // SURE THAT VARIABLE IS NOT ALSO USED TO UPDATE ANOTHER STATE VARIABLE -
    // IF IT IS, MAKE SURE PREVIOUS VALUE IS USED TO UPDATE THE OTHER
    // STATE VARIABLE
    //    nothing to do here for this unit
  }, // end updateState method

  display		: function(){
    // document.getElementById("demo01").innerHTML = "unit_1.rate = " + this.rate;
  } // end display method

}; // END var unit_1

// unit_2 - reactor - OBJECT DEFINITION
var unit_2 = {
  //
  // unit_2 IS REACTOR
  //
  // USES OBJECT simParams
  // OUTPUT CONNECTIONS FROM THIS UNIT TO OTHER UNITS
  //   unit_5 USES unit_2.TTemp
  // INPUT CONNECTIONS TO THIS UNIT FROM OTHER UNITS, see updateInputs below
  //   unit_2 USES unit_1.rate // flow rate
  //   unit_2 USES unit_1.conc
  //   unit_2 USES unit_1.TTemp // TTemp = temperature
  //   unit_2 USES unit_4.TTemp
  //   unit_2 USES unit_4.UA
  //   (1) reactor feed, (2) reactor, (3) feed to jacket, (4) jacket, (5) controller
  // INPUT CONNECTIONS TO THIS UNIT FROM HTML UI CONTROLS, see updateUIparams below

  // variables defined here are available to all functions inside this unit

  initialTTemp 	: 300, // (K), TTemp = temperature in Kelvin
  TTemp     : this.initialTTemp, // (K), TTemp = temperature in Kelvin
  initialConc   : 0, // (mol/m3), reactant concentration
  conc      : this.initialConc, // (mol/m3), reactant concentration
  vol				: 0.1, // (m3), volume of reactor contents = constant with flow rate

  // parameters for essentially irreversible first-order reaction
  k300      : 5e-6, // (1/s), reaction rate coefficient value at 300 K
  Ea        : 200, // (kJ/mol), reaction activation energy
  delH      : -250, // (kJ/mol), reaction heat of reaction (exothermic < 0)
  Rg        : 8.3144598E-3, // (kJ/mol/K), ideal gas constant
  rho       : 1000, // (kg/m3), reactant liquid density
  Cp        : 2.0, // (kJ/kg/K), reactant liquid heat capacity

  flowRate  : 0, // will get flowRate from unit 1 in updateInputs
  concIn    : 0, // will get concIn from unit 1 in updateInputs
  TTemp1    : 0, // will get TTemp1 from unit 1 in updateInputs
  TTemp4    : 0, // will get TTemp4 from unit 4 in updateInputs
  UA        : 0, // will get UA from unit 4 in updateInputs

  reset : function(){
    // On 1st load or reload page, the html file fills the fields with html file
    // values and calls reset, which needs updateUIparams to get values in fields.
    // On click reset button but not reload page, unless do something else here,
    // reset function will use whatever last values user has entered.
    this.updateUIparams(); // this first, then set other values as needed
    // set state variables not set by updateUIparams to initial settings
    this.TTemp = this.initialTTemp; // (K), TTemp = temperature in Kelvin
    this.conc = this.initialConc;
  },  // << COMMAS ARE REQUIRED AT END OF EACH OBJECT PROPERTY & FUNCTION EXCEPT LAST ONE (NO ;)

  updateUIparams : function(){
    this.k300 = Number(input_field_enterk300.value);
    this.Ea = Number(input_field_enterEa.value);
    this.delH = Number(input_field_enterdelH.value);
  },

  updateInputs : function(){
    // GET INPUT CONNECTION VALUES FROM OTHER UNITS FROM PREVIOUS TIME STEP,
    // SINCE updateInputs IS CALLED BEFORE updateState IN EACH TIME STEP
    this.flowRate = unit_1.rate;
    this.concIn = unit_1.conc;
    this.TTemp1 = unit_1.TTemp;
    this.TTemp4 = unit_4.TTemp;
    this.UA = unit_4.UA;
  },

  updateState : function(){
    // BEFORE REPLACING PREVIOUS STATE VARIABLE VALUE WITH NEW VALUE, MAKE
    // SURE THAT VARIABLE IS NOT ALSO USED TO UPDATE ANOTHER STATE VARIABLE -
    // IF IT IS, MAKE SURE PREVIOUS VALUE IS USED TO UPDATE THE OTHER
    // STATE VARIABLE

    var krxn = this.k300 * Math.exp(-(this.Ea/this.Rg)*(1/this.TTemp - 1/300));
    var rate = -krxn * this.conc;
    var invTau = this.flowRate / this.vol; // inverse of space time = space velocity

    var dCdt = invTau * (this.concIn - this.conc) + rate;
    var dC = simParams.simTimeStep * dCdt;
    // update conc
    this.conc = this.conc + dC;
    if (this.conc < 0){this.conc = 0;}

    var dTdt = invTau*(this.TTemp1 - this.TTemp) + rate*this.delH/(this.rho*this.Cp) +
               (this.TTemp4 - this.TTemp) * this.UA /(this.vol*this.rho*this.Cp);
    var dTTemp = simParams.simTimeStep * dTdt;
    // update TTemp
    this.TTemp = this.TTemp + dTTemp;

  }, // end updateState method

  display : function() {

    // document.getElementById("demo01").innerHTML = "unit_1.rate = " + this.rate;
    var el = document.querySelector("#div_PLOTDIV_reactorContents");
    // reactant is blue, product is red, this.conc is reactant conc
    // xxx assume here max conc is 400 but should make it a variable
    var concB = Math.round((this.conc)/400 * 255);
    var concR = 255 - concB;
    var concColor = "rgb(" + concR + ", 0, " + concB + ")";
    // alert("concColor = " + concColor); // check results
    // "background-color" in index.css did not work
    el.style.backgroundColor = concColor;

    // HANDLE STRIP CHART DATA

    var v = 0; // used as index
    var p = 0; // used as index
    var numStripPoints = plotsObj[0]['numberPoints'];

    // XXX see if can make actions below for strip chart into general function

    // handle reactant conc
    v = 0;
    tempArray = stripData[v]; // work on one plot variable at a time
    // delete first and oldest element which is an [x,y] pair array
    tempArray.shift();
    // add the new [x.y] pair array at end
    tempArray.push( [ 0, this.conc ] );
    // update the variable being processed
    stripData[v] = tempArray;

    // handle reactor T
    v = 1;
    tempArray = stripData[v]; // work on one plot variable at a time
    // delete first and oldest element which is an [x,y] pair array
    tempArray.shift();
    // add the new [x.y] pair array at end
    tempArray.push( [ 0, this.TTemp ] );
    // update the variable being processed
    stripData[v] = tempArray;

    // re-number the x-axis values to equal time values
    // so they stay the same after updating y-axis values
    var timeStep = simParams.simTimeStep * simParams.simStepRepeats;
    for (v = 0; v < 2; v += 1) {
      // only need to do for vars 0 and 1 in this display method
      // to do all vars, for (v = 0; v < numStripVariables; v += 1)
      for (p = 0; p <= numStripPoints; p += 1) { // note = in p <= numStripPoints
        // note want p <= numStripPoints so get # 0 to  # numStripPoints of points
        // want next line for newest data at max time
        stripData[v][p][0] = p * timeStep;
        // want next line for newest data at zero time
        // stripData[v][p][0] = (numStripPoints - p) * timeStep;
      }
    }

  } // end display method

}; // END var unit_2

// unit_3 - feed to heat transfer jacket - OBJECT DEFINITION
var unit_3 = {
  //
  // unit_3 IS FEED TO HEAT TRANSFER JACKET
  //
  // USES OBJECT simParams
  // OUTPUT CONNECTIONS FROM THIS UNIT TO OTHER UNITS
  //   unit_4 USES unit_3.rate
  //   unit_4 USES unit_3.TTemp // TTemp = temperature
  //   (1) reactor feed, (2) reactor, (3) feed to jacket, (4) jacket, (5) controller
  // INPUT CONNECTIONS TO THIS UNIT FROM OTHER UNITS, see updateInputs below
  //   unit_3 USES unit_5.command
  // INPUT CONNECTIONS TO THIS UNIT FROM HTML UI CONTROLS, see updateUIparams below

  // variables defined here are available to all functions inside this unit

  initialRate	: 1, // (m3/s), heat transfer liquid flow rate
  rate      : this.initialRate,

  initialTTemp	: 350, // (K), TTemp = temperature
  TTemp		: this.initialTTemp,

  command : 0, // get command from unit 5 in updateInputs

  reset : function(){
    // On 1st load or reload page, the html file fills the fields with html file
    // values and calls reset, which needs updateUIparams to get values in fields.
    // On click reset button but not reload page, unless do something else here,
    // reset function will use whatever last values user has entered.
    this.updateUIparams(); // this first, then set other values as needed
    // this.rate set by updateUIparams
    // set state variables not set by updateUIparams to initial settings
    this.TTemp = this.initialTTemp;
  },  // << COMMAS ARE REQUIRED AT END OF EACH OBJECT PROPERTY & FUNCTION EXCEPT LAST ONE (NO ;)

  updateUIparams : function(){
    this.rate = Number(input_field_enterJacketFlowRate.value);
  },

  updateInputs : function(){
    // GET INPUT CONNECTION VALUES FROM OTHER UNITS FROM PREVIOUS TIME STEP,
    // SINCE updateInputs IS CALLED BEFORE updateState IN EACH TIME STEP
    this.command = unit_5.command;
  },

  updateState : function(){
    // BEFORE REPLACING PREVIOUS STATE VARIABLE VALUE WITH NEW VALUE, MAKE
    // SURE THAT VARIABLE IS NOT ALSO USED TO UPDATE ANOTHER STATE VARIABLE -
    // IF IT IS, MAKE SURE PREVIOUS VALUE IS USED TO UPDATE THE OTHER
    // STATE VARIABLE

    // get feed T from controller command
    this.TTemp = this.command;

  }, // end updateState method

  display : function(){
    // document.getElementById("demo01").innerHTML = "unit_1.rate = " + this.rate;

    // HANDLE STRIP CHART DATA

    var v = 0; // used as index
    var p = 0; // used as index
    var numStripPoints = plotsObj[0]['numberPoints'];

    // XXX see if can make actions below for strip chart into general function

    // handle jacket inlet T
    v = 2;
    tempArray = stripData[v]; // work on one plot variable at a time
    // delete first and oldest element which is an [x,y] pair array
    tempArray.shift();
    // add the new [x.y] pair array at end
    tempArray.push( [ 0, this.TTemp ] );
    // update the variable being processed
    stripData[v] = tempArray;

    // re-number the x-axis values to equal time values
    // so they stay the same after updating y-axis values
    var timeStep = simParams.simTimeStep * simParams.simStepRepeats;
    v = 2; // just one var in this display method, so don't need repeat
    // to do all vars, for (v = 0; v < numStripVariables; v += 1)
    for (p = 0; p <= numStripPoints; p += 1) { // note = in p <= numStripPoints
      // note want p <= numStripPoints so get # 0 to  # numStripPoints of points
      // want next line for newest data at max time
      stripData[v][p][0] = p * timeStep;
      // want next line for newest data at zero time
      // stripData[v][p][0] = (numStripPoints - p) * timeStep;
    }

  } // end display method

}; // END var unit_3

// unit_4 - heat transfer jacket - OBJECT DEFINITION
var unit_4 = {
  //
  // unit_4 IS HEAT TRANSFER JACKET
  //
  // USES OBJECT simParams
  // OUTPUT CONNECTIONS FROM THIS UNIT TO OTHER UNITS
  //   unit_2 USES unit_4.TTemp // TTemp = temperature
  //   (1) reactor feed, (2) reactor, (3) feed to jacket, (4) jacket, (5) controller
  // INPUT CONNECTIONS TO THIS UNIT FROM OTHER UNITS, see updateInputs below
  //   unit_4 USES unit_2.TTemp
  //   unit_4 USES unit_3.rate // flow rate
  //   unit_4 USES unit_3.TTemp
  // INPUT CONNECTIONS TO THIS UNIT FROM HTML UI CONTROLS, see updateUIparams below

  // variables defined here are available to all functions inside this unit

  vol       : 0.02, // (m3), heat transfer jacket volume
  rho       : 1000, // (kg/m3), heat transfer liquid density
  Cp        : 2.0, // (kJ/kg/K), heat transfer liquid heat capacity

  initialTTemp	: 350, // (K), TTemp = temperature
  TTemp     : this.initialTTemp,

  flowRate  : 0, // will get flowRate from unit 3 in updateInputs
  TTemp2    : 0, // will get TTemp2 from unit 2 in updateInputs
  TTemp3    : 0, // will get TTemp3 from unit 3 in updateInputs

  reset : function(){
    // On 1st load or reload page, the html file fills the fields with html file
    // values and calls reset, which needs updateUIparams to get values in fields.
    // On click reset button but not reload page, unless do something else here,
    // reset function will use whatever last values user has entered.
    this.updateUIparams(); // this first, then set other values as needed
    // set state variables not set by updateUIparams to initial settings
    this.TTemp = this.initialTTemp;
  },  // << COMMAS ARE REQUIRED AT END OF EACH OBJECT PROPERTY & FUNCTION EXCEPT LAST ONE (NO ;)

  updateUIparams : function(){
    this.UA = Number(input_field_enterjacketUA.value); // (kJ/s/K), heat transfer area * coefficient
  },

  updateInputs : function(){
    // GET INPUT CONNECTION VALUES FROM OTHER UNITS FROM PREVIOUS TIME STEP,
    // SINCE updateInputs IS CALLED BEFORE updateState IN EACH TIME STEP
    this.flowRate = unit_3.rate;
    this.TTemp2 = unit_2.TTemp;
    this.TTemp3 = unit_3.TTemp;
  },

  updateState : function(){
    // BEFORE REPLACING PREVIOUS STATE VARIABLE VALUE WITH NEW VALUE, MAKE
    // SURE THAT VARIABLE IS NOT ALSO USED TO UPDATE ANOTHER STATE VARIABLE -
    // IF IT IS, MAKE SURE PREVIOUS VALUE IS USED TO UPDATE THE OTHER
    // STATE VARIABLE

    var invTau = this.flowRate/ this.vol;

    var dTdt = invTau*(this.TTemp3 - this.TTemp) +
               (this.TTemp2- this.TTemp) * this.UA/(this.vol*this.rho*this.Cp);
    var dTTemp = simParams.simTimeStep * dTdt;
    // update TTemp
    this.TTemp = this.TTemp + dTTemp;

  }, // end updateState method

  display		: function(){
    // document.getElementById("demo01").innerHTML = "unit_1.rate = " + this.rate;

    // HANDLE STRIP CHART DATA

    var v = 0; // used as index
    var p = 0; // used as index
    var numStripPoints = plotsObj[0]['numberPoints'];

    // XXX see if can make actions below for strip chart into general function

    // handle jacket T
    v = 3;
    tempArray = stripData[v]; // work on one plot variable at a time
    // delete first and oldest element which is an [x,y] pair array
    tempArray.shift();
    // add the new [x.y] pair array at end
    tempArray.push( [ 0, this.TTemp ] );
    // update the variable being processed
    stripData[v] = tempArray;

    // re-number the x-axis values to equal time values
    // so they stay the same after updating y-axis values
    var timeStep = simParams.simTimeStep * simParams.simStepRepeats;
    v = 3; // just one var in this display method, so don't need repeat
    // to do all vars, for (v = 0; v < numStripVariables; v += 1)
    for (p = 0; p <= numStripPoints; p += 1) { // note = in p <= numStripPoints
      // note want p <= numStripPoints so get # 0 to  # numStripPoints of points
      // want next line for newest data at max time
      stripData[v][p][0] = p * timeStep;
      // want next line for newest data at zero time
      // stripData[v][p][0] = (numStripPoints - p) * timeStep;
    }

  } // end display method

}; // END var unit_4

// unit_5 - reactor temperature controller - OBJECT DEFINITION
var unit_5 = {
  //
  // unit_5 IS REACTOR TEMPERATURE CONTORLLER
  //
  // USES OBJECT simParams
  // OUTPUT CONNECTIONS FROM THIS UNIT TO OTHER UNITS
  //   unit_3 USES unit_5.command - manipulated variable
  //   (1) reactor feed, (2) reactor, (3) feed to jacket, (4) jacket, (5) controller
  // INPUT CONNECTIONS TO THIS UNIT FROM OTHER UNITS, see updateInputs below
  //   unit_5 USES unit_2.TTemp - controlled variable
  // INPUT CONNECTIONS TO THIS UNIT FROM HTML UI CONTROLS, see updateUIparams below

  // variables defined here are available to all functions inside this unit

  setPoint		: 330, // (K) desired reactor temperature
  gain				: 100, // controller gain
  resetTime   : 3, // integral mode reset time
  manualBias  : 300, // (K), command at zero error
  initialCommand  : 300, // controller command signal (coef for unit_2)
  command         : this.initialCommand,
  errorIntegral   : 0, // integral error

  mode        : "manual", // auto or manual, see changeMode() below
  manualCommand : 348,

  TTemp2  : 0, // will get TTemp2 from unit 2 in updateInputs

  reset : function(){
    // On 1st load or reload page, the html file fills the fields with html file
    // values and calls reset, which needs updateUIparams to get values in fields.
    // On click reset button but not reload page, unless do something else here,
    // reset function will use whatever last values user has entered.
    this.updateUIparams(); // this first, then set other values as needed
    // set state variables not set by updateUIparams to initial settings
    this.errorIntegral = 0;
    this.command = this.initialCommand;
  },  // << COMMAS ARE REQUIRED AT END OF EACH OBJECT PROPERTY & FUNCTION EXCEPT LAST ONE (NO ;)

  changeMode : function(){
    // below does not work when html input tag id="input.radio_controllerAUTO"
    // use instead id="radio_controllerAUTO" - same for MANUAL & AUTO
    var el = document.querySelector("#radio_controllerAUTO");
    var el2 = document.querySelector("#enterJacketFeedTTemp");
    if (el.checked){
      // alert("controller in AUTO mode");
      this.mode = "auto"
      // TWO LINES BELOW USED WHEN TOGGLE THIS INPUT HIDDEN-VISIBLE
      //   el2.type = "hidden";
      //   document.getElementById("enterJacketFeedTTempLABEL").style.visibility = "hidden";
    } else {
      // alert("controller in MANUAL mode");
      this.mode = "manual"
      // TWO LINES BELOW USED WHEN TOGGLE THIS INPUT HIDDEN-VISIBLE
      //   el2.type = "input";
      //   document.getElementById("enterJacketFeedTTempLABEL").style.visibility = "visible";
    }
  }, // end changeMode function

  updateUIparams : function(){
    this.resetTime = Number(input_field_enterResetTime.value);
    this.gain = Number(input_field_enterGain.value);
    this.setPoint = Number(input_field_enterSetpoint.value);
    // at least for input below, value returned is not a number, probably text
    // so convert this and others to numbers
    // noticed problem in process_units copyData function, .toFixed(2) didn't work
    // MAYBE RELATED TO HOW INPUT DEFINED IN HTML???
    this.manualCommand = Number(input_field_enterJacketFeedTTemp.value);
  },

  updateInputs : function(){
    // GET INPUT CONNECTION VALUES FROM OTHER UNITS FROM PREVIOUS TIME STEP,
    // SINCE updateInputs IS CALLED BEFORE updateState IN EACH TIME STEP
    this.TTemp2 = unit_2.TTemp;
  },

  updateState : function(){
    // BEFORE REPLACING PREVIOUS STATE VARIABLE VALUE WITH NEW VALUE, MAKE
    // SURE THAT VARIABLE IS NOT ALSO USED TO UPDATE ANOTHER STATE VARIABLE -
    // IF IT IS, MAKE SURE PREVIOUS VALUE IS USED TO UPDATE THE OTHER
    // STATE VARIABLE

    // compute new value of PI controller command
    var error = this.setPoint - this.TTemp2;
    this.command = this.manualBias + this.gain *
                  (error + (1/this.resetTime) * this.errorIntegral);

    // stop integration at command limits
    // to prevent integral windup
    if (this.command > 450){
      this.command = 450;
    } else if (this.command < 200){
      this.command = 200;
    } else {
      // not at limit, OK to update integral of error
      // update errorIntegral only after it is used above to update this.command
      this.errorIntegral = this.errorIntegral + error * simParams.simTimeStep; // update integral of error
    }

    if (this.mode == "manual"){
      // replace command with value entered in input in page
      // var el = document.querySelector("#enterJacketFeedTTemp");
      // this.command = el.value;
      this.command = this.manualCommand;
    } else {
      // in auto mode, use command computed above
    }

  }, // end updateState method

  display : function(){
    // document.getElementById("demo05").innerHTML = "unit_5.command = " + this.command;
  } // end display METHOD

}; // END var unit_5
