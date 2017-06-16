/*
  Design, text, images and code by Richard K. Herz, 2017
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// This file defines an object that holds simulation parameter values and
// defines objects that represent process units
// For functions that use these objects, see files
// process_main.js and process_plotter.js.

// =======================================================================
// --- THESE DO NOT WORK IN THIS LOCATION BUT DO WORK IN EITHER
// --- process_plotter or process_plot_info

// var plotData = initPlotData3(simParams.plotVariables.length, simParams.numPlotPoints);

// // data for strip charts
// // [0] is reactant in, [1] is reactant out, [2] is product out
// // 100 plot points + 1 for origin
// var stripData = initPlotData3(3,100);

// // data for profile plots
// // [0] is reactant gas, [1] is product gas, [2] is coverage, [3] is local rate
// // 60 plot points + 1 for origin
// var profileData = initPlotData3(4,60); // holds data for profile plots

// ============================================ ===========================

// ----- ARRAYS TO HOLD WORKING DATA -----------

var y = []; // reactant gas in catalyst layer
var y2 = []; // product gas in catalyst layer
var yNew = []; // new values for reactant gas in layer
var y2New = []; // new values for product gas in layer
var tempArray = []; // for shifting data in strip chart plots
var spaceData = []; // for shifting data in space-time plots
var cinNew = 0;
var cinOld = 0;
var caNew = 0;
var cbNew = 0;

// ----- SEE process_plot_info.js FOR INITIALIZATION OF ---------------
// ----- OTHER DATA ARRAYS --------------------------------------------

// ----- OBJECT TO CONTAIN & SET SIMULATION & PLOT PARAMETERS ---------

var simParams = {

  runButtonID : "button_runButton_1178", // for functions to run, reset, copy data
  loggerURL : "../webAppRunLog.lc",
  runningFlag : false, // set runningFlag to false initially

  // all units use simParams.dt, getting it at each step in unit updateInputs()
  // see method simParams.changeDtByFactor() below to change dt value
  // WARNING: DO NOT CHANGE dt BETWEEN display updates
  dt : 1/75, // time step value, simulation time
  // WANT dt * stepRepeats to be an integer and stepRepeats needs to be an integer
  // for dt = 1/75 and stepRepeats = 1200, product = 16; 1200 = 16*75
  stepRepeats : 1200, // integer number of unit updates between display updates

  // WARNING: IF INCREASE NUM NODES IN CATALYST LAYER BY A FACTOR THEN HAVE TO
  //  REDUCE dt FOR NUMERICAL STABILITY BY SQUARE OF THE FACTOR
  // AND INCREASE stepRepeats BY SAME FACTOR IF WANT SAME SIM TIME BETWEEN
  // DISPLAY UPDATES

  // set updateDisplayTimingMs to zero here because this model takes a long
  // time to compute and need to run as fast as possible
  updateDisplayTimingMs : 0, // real time milliseconds between display updates

  simTime : 0, // (s), time, initialize simulation time, also see resetSimTime

  // LIST ACTIVE PROCESS UNITS
  // processUnits array is the list of names of active process units
  // the order of units in the list is not important

  processUnits : [
    "puCatalystLayer"
  ],

  resetSimTime : function() {
    this.simTime = 0;
  },

  updateSimTime : function(repeats) {
    this.simTime = this.simTime + this.dt;
  },

  // // THIS VERSION IF DO NOT WANT TO UPDATE SIM TIME EACH REPEAT
  // // IN CATALYST LAYER
  // updateSimTime : function(repeats) {
  //   if (repeats >= 1) {
  //     // leave repeats as is
  //   }else{
  //     repeats = 1;
  //   }
  //   this.simTime = this.simTime + repeats * this.dt;
  // },

  // runningFlag value can change by click of RUN-PAUSE or RESET buttons
  // calling functions toggleRunningFlag and stopRunningFlag
  toggleRunningFlag : function() {
    this.runningFlag = !this.runningFlag;
  },

  stopRunningFlag : function() {
    this.runningFlag = false;
  },

  changeDtByFactor : function(factor) {
    // WARNING: do not change dt except immediately before or after a display update
    // in order to maintain sync between sim time and real time
    this.dt = factor * this.dt;
  }

}; // END var simParams

// ------------ PROCESS UNIT OBJECT DEFINITIONS ----------------------

// EACH PROCESS UNIT DEFINITION MUST CONTAIN AT LEAST THESE FOUR FUNCTIONS:
//   reset, updateUIparams, updateInputs, updateState, display
// WARNING: THESE FUNCTION DEFINITIONS MAY BE EMPTY BUT MUST BE PRESENT

// -------------------------------------------------------------------

var puCatalystLayer = {
  //
  // USES OBJECT simParams
  // OUTPUT CONNECTIONS FROM THIS UNIT TO OTHER UNITS
  //   puController.command.value
  // INPUT CONNECTIONS TO THIS UNIT FROM OTHER UNITS, see updateInputs below
  // OLD inputPV : "puWaterTank.level.value", // PV = Process Variable value to be controlled
  // INPUT CONNECTIONS TO THIS UNIT FROM HTML UI CONTROLS, see updateUIparams below
  inputModel01 : "radio_Model_1",
  inputModel02 : "radio_Model_2",
  inputCmax : "range_setCmax_slider_1200",
  inputSliderReadout : "field_setCmax_value_1199",
  inputRadioConstant : "radio_Constant_1215",
  inputCheckBoxFeed : "checkbox_on_1231",
  inputRadioSine : "radio_Sine_1214",
  inputRadioSquare : "radio_Square_1216",
  inputCyclePeriod : "input_field_enterCyclePeriod_1220",
  inputDuty : "input_field_enterDuty_1218",
  inputKflow : "input_field_enterKflow_1203",
  inputKads : "input_field_enterKads_1204",
  inputKdiff : "input_field_enterKdiff_1206",
  inputThieleMod : "input_field_enterThieleMod_1209",
  inputAlpha :  "input_field_enterAlpha_1210",
  inputBscale : "input_field_enterBscale_1212",
  // DISPLAY CONNECTIONS FROM THIS UNIT TO HTML UI CONTROLS, see updateDisplay below
  //   no user entered values for this unit
  // ---- NO EXPLICIT REF TO EXTERNAL VALUES BELOW THIS LINE EXCEPT simParams.dt ----

  // define "initialVarName" values for reset function and
  // so that this process unit will run if units that supply inputs and
  // html inputs are not present in order to make units more independent

  initialCmax : 1,
  initialKflow : 2.5, // Q/Vp/k-1 = (Q/Vc/k-1) / (Vp/Vc)
  initialKads : 1,
  initialKdiff : 0.003,
  initialPhi : 34, // Phi = ThieleMod
  initialAlpha : 10,
  initialModel : 2, // use integers 1,2 - used in Math.pow(), selects rate determining step
  initialShape : 'sine', // constant, off, sine, square
  initialPeriod : 500, // 0.007854 = Math.PI / 400
  initialDuty : 50, // percent on, duty cycle for square cycling
  initialBscale : 1,

  // // WARNING: numNodes here should equal plotsObj[plotNumber]['numberPoints']
  // //          in the PROFILE type plot in which these node profile data are plotted
  // numNodes : 60, // IF INCREASE numNodes THEN HAVE TO CHANGE dt & stepRepeats
  // eps : 0.3, // epsilon, layer void fraction, keep constant
  // phaseShift : 1.5 * Math.PI, // keep constant
  // Vratio : 2, // layer/cell volume ratio, keep constant
  //   KdOeps : 0.01,
  //
  // // new params needed to couple mixing cell to catalyst layer
  //   Kflow : 5, // Q/Vc/k-1 = d'less space time

  // define the main variables which will not be plotted or save-copy data

  // NEW FOR SQUARE CYCLING WITH DUTY CYCLE
  cycleTime : 0,
  frequency : 0, // update in updateUIparams
  sineFunc : 0,
  sineFuncOLD : 0,

  dt : 0.1, // default time step, changed below in updateInputs

  // WARNING: have to change dt and stepRepeats if change numNodes
  // WARNING: numNodes is accessed  in process_plot_info.js
  numNodes : 50,

  // XXX WARNING: THESE DO NOT HAVE ANY EFFECT HERE WHEN
  //     THEY ARE ALSO SET IN updateUIparams
  //     BUT WHEN NOT SET IN updateUIparams THEN setting to
  //     this.initial___ HAS NO EFFECT AND GET NaN
  // if list here must supply a value (e.g., this.initial___) but if not
  // list here then apparently is created in updateUIparams...
  Cmax : this.initialCmax,
  // user will vary Kflow space time based on pellet/layer volume Vp
  Kflow : this.initialKflow, // d'less space time, Q/Vp/k-1 = (Q/Vc/k-1)/(Vp/Vc)
  Kads : this.initialKads,
  Kdiff : this.initialKdiff,
  phi : this.initialPhi,
  alpha : this.initialAlpha,
  model : this.initialModel, // use integers 1,2 - used in Math.pow(), selects rate determining step
  shape : this.initialShape,
  period : this.initialPeriod,
  duty : this.initialDuty,
  Bscale : this.initialBscale, // SEARCH FOR XXX TEMPORARY in plotter JS

  // variables for average rate
  AinSum : 0,
  BoutSum : 0,
  BoutCounter : 0,
  aveRate  : 0,
  aveConversion : 0,

  // variables to be plotted are defined as objects
  // with the properties: value, name, label, symbol, dimensional units
  // name used for copy-save data column headers, label for plot legend

  // y : {
  //   value  : 0,
  //   name   : "y",
  //   label  : "y",
  //   symbol : "y",
  //   units  : "(d'less)"
  // },

  reset : function() {
    // On 1st load or reload page, the html file fills the fields with html file
    // values and calls reset, which needs updateUIparams to get values in fields.
    // On click reset button but not reload page, unless do something else here,
    // reset function will use whatever last values user has entered.
    this.updateUIparams(); // this first, then set other values as needed
    // set state variables not set by updateUIparams to initial settings

    // this.command.value = this.initialCommand;
    // this.errorIntegral = this.initialErrorIntegral;

    for (k = 0; k <= this.numNodes; k += 1) {
      y[k] = 0;
      y2[k] = 0;
      yNew[k] = 0;
      y2New[k] = 0;
    }

    cin = 0;
    ca = 0;
    cb = 0;
    cinNew = 0;
    caNew = 0;
    cbNew = 0;

    var kn = 0;
    for (k=0; k<=this.numNodes; k+=1) {
      kn = k/this.numNodes;
      // x-axis values
      // x-axis values will not change during sim
      // XXX change to get number vars for this plotsObj variable
      //     so can put in repeat - or better yet, a function
      //     and same for y-axis below
      profileData[0][k][0] = kn;
      profileData[1][k][0] = kn;
      profileData[2][k][0] = kn;
      profileData[3][k][0] = kn;
      // y-axis values
      profileData[0][k][1] = 0;
      profileData[1][k][1] = 0;
      profileData[2][k][1] = 0;
      profileData[3][k][1] = 0;
    }

    // XXX also need to reset strip chart data

    // WARNING - if change a value to see initialization here
    // then reset it to zero below this line or will get results at this node
    // document.getElementById("dev01").innerHTML = "RESET time = " + simParams.simTime.toFixed(0) + "; y = " + y[0];

  }, // end reset

  updateUIparams : function() {
    //
    // SPECIFY REFERENCES TO HTML UI COMPONENTS ABOVE in this unit definition
    //
    // GET INPUT PARAMETER VALUES FROM HTML UI CONTROLS
    //
    // The following IF structures provide for unit independence
    // such that when input doesn't exist, you get "initial" value
    //
    // EXAMPLE FOR SETTING VALUE OF AN OBJECT WITH MULTIPLE properties
    //   THUS set value of this.setPoint.value
    // if (document.getElementById(this.inputSetPoint)) {
    //   let tmpFunc = new Function("return " + this.inputSetPoint + ".value;");
    //   this.setPoint.value = tmpFunc();
    // } else {
    //   this.setPoint.value = this.initialSetPoint;
    // }
    //
    // EXAMPLE SETTING VALUE OF SIMPLE VARIABLE (no .value = )
    // if (document.getElementById(this.inputCmax)) {
    //   let tmpFunc = new Function("return " + this.inputCmax + ".value;");
    //   this.Cmax = tmpFunc();
    // } else {
    //   this.Cmax= this.initialCmax;
    // }

    if (document.getElementById(this.inputCmax)) {
      let tmpFunc = new Function("return " + this.inputCmax + ".value;");
      this.Cmax = tmpFunc();
    } else {
      this.Cmax= this.initialCmax;
    }

    // update the readout field of range slider
    if (document.getElementById(this.inputSliderReadout)) {
      document.getElementById(this.inputSliderReadout).innerHTML = this.Cmax;
    }

    if (document.getElementById(this.inputCyclePeriod)) {
      let tmpFunc = new Function("return " + this.inputCyclePeriod + ".value;");
      this.period = tmpFunc();
    } else {
      this.period = this.initialPeriod;
    }

    // NEW FOR SQUARE CYCLING WITH DUTY
    this.frequency = 2 * Math.PI / this.period;

    if (document.getElementById(this.inputDuty)) {
      let tmpFunc = new Function("return " + this.inputDuty + ".value;");
      this.duty = tmpFunc();
    } else {
      this.duty= this.initialDuty;
    }

    if (document.getElementById(this.inputKflow)) {
      let tmpFunc = new Function("return " + this.inputKflow + ".value;");
      this.Kflow = tmpFunc();
    } else {
      this.Kflow = this.initialKflow;
    }

    if (document.getElementById(this.inputKads)) {
      let tmpFunc = new Function("return " + this.inputKads + ".value;");
      this.Kads = tmpFunc();
    } else {
      this.Kads = this.initialKads;
    }

    if (document.getElementById(this.inputKdiff)) {
      let tmpFunc = new Function("return " + this.inputKdiff + ".value;");
      this.Kdiff = tmpFunc();
    } else {
      this.Kdiff = this.initialKdiff;
    }

    // phi << ThieleMod
    if (document.getElementById(this.inputThieleMod)) {
      let tmpFunc = new Function("return " + this.inputThieleMod + ".value;");
      this.phi = tmpFunc();
    } else {
      this.phi = this.initialPhi;
    }

    if (document.getElementById(this.inputAlpha)) {
      let tmpFunc = new Function("return " + this.inputAlpha + ".value;");
      this.alpha = tmpFunc();
    } else {
      this.alpha = this.initialAlpha;
    }

    if (document.getElementById(this.inputBscale)) {
      let tmpFunc = new Function("return " + this.inputBscale + ".value;");
      this.Bscale = tmpFunc();
    } else {
      this.Bscale = this.initialBscale;
    }
    // change input y-axis scale factor for plotting of B out
    plotsObj[3]['varYscaleFactor'][1] = this.Bscale; // this.Bscale;

    // RADIO BUTTONS & CHECK BOX
    // at least for now, do not check existence of UI element as above
    // Model radio buttons - selects rate determing step
    var m01 = document.querySelector('#' + this.inputModel01);
    var m02 = document.querySelector('#' + this.inputModel02);
    if (m01.checked) {
      this.model = 1;
    } else {
      this.model = 2;
    }
    // Input shape radio buttons
    var el0 = document.querySelector('#' + this.inputRadioConstant);
    var el1 = document.querySelector('#' + this.inputRadioSine);
    var el2 = document.querySelector('#' + this.inputRadioSquare);
    var el3 = document.querySelector('#' + this.inputCheckBoxFeed);
    if (el2.checked) {
      this.shape = 'square';
    } else if (el1.checked) {
      this.shape = 'sine';
    } else {
      // assume constant checked
      if (el3.checked) {
        this.shape = 'constant';
      } else {
        this.shape = 'off';
      }
    }

    var Krxn = Math.pow(this.phi, 2)*this.Kdiff/0.3/this.alpha/this.Kads;
    // note eps is local to updateState, so use 0.3 here
    document.getElementById("field_Krxn_1223").innerHTML = Krxn.toFixed(4);

    // reset average rate after any change
    this.AinSum = 0;
    this.BoutSum = 0;
    this.BoutCounter = 0;
    this.aveRate = 0;
    this.aveConversion = 0;

  }, // end of updateUIparams()

  updateInputs : function() {
    //
    // SPECIFY REFERENCES TO INPUTS ABOVE in this unit definition
    //
    // GET INPUT CONNECTION VALUES FROM OTHER UNITS FROM PREVIOUS TIME STEP,
    // SINCE updateInputs IS CALLED BEFORE updateState IN EACH TIME STEP
    //
    this.dt = simParams.dt; // all units need to use same dt
    //
    // The following TRY-CATCH structures provide for unit independence
    // such that when input doesn't exist, you get "initial" value

    // try {
    // //   let tmpFunc = new Function("return " + this.inputPV + ";");
    // //   this.PV = tmpFunc();
    // //   // note: can't test for definition of this.inputVAR because any
    // //   // definition is true BUT WHEN try to get value of bad input
    // //   // to see if value is undefined then get "uncaught reference" error
    // //   // that the value of the bad input specified is undefined,
    // //   // which is why use try-catch structure here
    // }
    // catch(err) {
    // //   this.PV = this.initialPV;
    // }

  },

  updateState : function() {
    // BEFORE REPLACING PREVIOUS STATE VARIABLE VALUE WITH NEW VALUE, MAKE
    // SURE THAT VARIABLE IS NOT ALSO USED TO UPDATE ANOTHER STATE VARIABLE HERE -
    // IF IT IS, MAKE SURE PREVIOUS VALUE IS USED TO UPDATE THE OTHER
    // STATE VARIABLE

    // document.getElementById("dev01").innerHTML = "UPDATE time = " + simParams.simTime.toFixed(0) + "; y = " + y[20];

    var eps = 0.3; // layer void fraction, constant
    var Vratio = 2; // layer-pellet/cell volume ratio Vp/Vc, keep constant
    var phaseShift = 1.5 * Math.PI; // keep constant

    // compute these products outside of repeat

    // XXX check, note I compute 0 to this.numNodes points, therefore this.numNodes divisions
    var dz = 1/this.numNodes; // dless distance between nodes in layer

    var inverseDz2 = Math.pow(1/dz, 2);
    var KflowCell = this.Kflow*Vratio; // Q/Vc/k-1 = (Q/Vp/k-1)*(Vp/Vc)
    var KdOeps = this.Kdiff / eps;
    var KdOepsOalpha = KdOeps / this.alpha;
    var dtKdOepsOalpha = this.dt * KdOepsOalpha;
    var dtKdOeps = this.dt * KdOeps;
    var phi2 = Math.pow(this.phi, 2);
    var flowFactor = this.Kflow / this.alpha / eps; // for aveRate

    var secondDeriv = 0;
    var D2 = 0;
    var phi2overD2 = 0;
    var tNewFac = 0;
    var i = 0; // used as index
    var v = 0; // used as index
    var k = 0; // used as index
    var flowRate = 0;
    var diffRate = 0;
    var numStripPoints = 0;

    // document.getElementById("dev01").innerHTML = "UPDATE time = " + simParams.simTime.toFixed(0) + "; y = " + inverseDz2;

    // NEW - MOVE ALL THE STEPS BETWEEN DISPLAYS INTO THIS METHOD
    // RATHER THAN CALLING EACH ONE FROM MAIN.JS
    for (i=0; i<simParams.stepRepeats; i+=1) {

    // XXX BUT IF RESET IS TRUE THEN DON'T WANT TO DO ANY STEPPING HERE...

        // boundary condition at inner sealed face
        k = 0;

        D2 = Math.pow((1 + this.Kads * y[k]), this.model); // this.model should be 1 or 2
        phi2overD2 = phi2 / D2;
        secondDeriv = ( 2 * y[k+1] - 2 * y[k] ) * inverseDz2;

        tNewFac = 1 / (1/this.alpha + this.Kads/D2); // to allow any alpha (as long as quasi-equil established)
        // replaces (D2/Kads) which is for large alpha

        yNew[k] = y[k] + dtKdOepsOalpha * tNewFac * ( secondDeriv - phi2overD2 * y[k] ); // for LARGE ALPHA

        // now do for y2
        secondDeriv = ( 2*y2[k+1] - 2*y2[k] ) * inverseDz2;
        y2New[k] = y2[k]  + dtKdOeps * ( secondDeriv + phi2overD2 * y[k] );

       // internal nodes
       for (k = 1; k < this.numNodes; k += 1) {

          D2 = Math.pow(( 1 + this.Kads * y[k] ), this.model); // this.model should be 1 or 2
          phi2overD2 = phi2 / D2;
          secondDeriv = ( y[k-1] - 2*y[k] + y[k+1] ) * inverseDz2;

          tNewFac = 1 / (1/this.alpha + this.Kads/D2); // to allow any alpha (as long as quasi-equil established)
          // replaces D2/Kads which is for large alpha

          yNew[k] = y[k]  + dtKdOepsOalpha * tNewFac * ( secondDeriv - phi2overD2 * y[k] ); // for LARGE ALPHA

          // now do for y2
          secondDeriv = ( y2[k-1] - 2*y2[k] + y2[k+1] ) * inverseDz2;
          y2New[k] = y2[k]  + dtKdOeps * ( secondDeriv + phi2overD2 * y[k] );

      } // end repeat

      // boundary condition at outer bulk face

      k = this.numNodes;

      // reactant A feed to reactor
      // cinNew = this.Cmax * 0.5 * (1 + Math.sin( this.frequency * simParams.simTime  + phaseShift) );
      this.sineFuncOLD = this.sineFunc; // need for square cycle with duty fraction
      this.sineFunc = 0.5 * (1 + Math.sin( this.frequency * simParams.simTime  + phaseShift) );

      // NEW FOR SQUARE CYCLING WITH DUTY CYCLE
      this.cycleTime = this.cycleTime + this.dt;

      cinOld = cinNew;

      switch(this.shape) {
        case 'off':
          cinNew = 0;
          break;
        case 'constant':
          cinNew = this.Cmax;
          break;
        case 'sine':
          cinNew = this.Cmax * this.sineFunc;
          break;
        case 'square':
          if (this.sineFuncOLD <= 0.5 && this.sineFunc > 0.5) {
            // we are entering new cycle
            // start timer and switch cin
            this.cycleTime = 0;
            cinNew = this.Cmax;
          } else {
            // within sine cycle
            // check cycleTime to see what to do
            if (this.cycleTime < this.duty/100 * this.period) {
              // do nothing
            } else {
              cinNew = 0;
            }
          }
          break;
        default:
          cinNew = this.Cmax;
      }

      // force cinNew to be a number, if not, then
      // 0 and 1 values get treated as text when summing for aveConversion
      cinNew = Number(cinNew);

      // compute average rate and conversion
      // need to update only after complete cycles or get values
      // always changing - and works OK for constant feed as well
      if (this.sineFuncOLD <= 0.5 && this.sineFunc > 0.5) {
        // we are entering new cycle
        // start timer
        this.cycleTime = 0;
        // compute averages only after complete cycles
        if (this.BoutCounter > 0) {
          // compute ave d'ess TOF = ave B formed per site per unit d'less time
          this.aveRate = flowFactor * this.BoutSum / this.BoutCounter;
        }
        if (this.AinSum > 0) {
          this.aveConversion = this.BoutSum / this.AinSum;
        }
        // reset variables used to compute averages
        this.AinSum = 0;
        this.BoutSum = 0;
        this.BoutCounter = 0;
      } else {
        // we are in a cycle so update variables used to compute averages
        this.AinSum = this.AinSum + cinNew;
        this.BoutSum = this.BoutSum + cbNew;
        this.BoutCounter = this.BoutCounter + 1;
      }

      numStripPoints = plotsObj[2]['numberPoints'];

      // WARNING: do not use stripData for concentrations used in computations
      // because they are only updated after this repeat of stepRepeats is done

      // reactant A balance in mixing cell with diffusion in/out of layer
      flowRate = KflowCell * (cinOld - y[k]);
      diffRate = this.Kdiff*Vratio*this.numNodes*(y[k]-y[k-1]);
      dcadt = flowRate - diffRate;
      caNew = y[k] + dcadt * this.dt;
      yNew[k] = caNew;

      // document.getElementById("dev01").innerHTML = "flowRate = " + flowRate + "; diffRate = " + diffRate;
      // document.getElementById("dev01").innerHTML = "y[k] = " + y[k] + "; dcadt * this.dt = " + dcadt * this.dt;

      // product B balance in mixing cell with diffusion in/out of layer
      flowRate = KflowCell * (0 - y2[k]);
      diffRate = this.Kdiff*Vratio*this.numNodes*(y2[k]-y2[k-1]);
      dcbdt = flowRate - diffRate;
      cbNew = y2[k] + dcbdt * this.dt;

      // document.getElementById("dev02").innerHTML = "flowRate = " + flowRate + "; diffRate = " + diffRate;
      // document.getElementById("dev02").innerHTML = "y2[k] = " + y2[k] + "; dcbdt * this.dt = " + dcbdt * this.dt;

      y2New[k] = cbNew;

       // document.getElementById("dev01").innerHTML = "UPDATE BOUNDARY time = " + simParams.simTime.toFixed(0) + "; y = " +  yNew[k].toFixed(3);

       // copy temp y and y2 to current y and y2
      y = yNew;
      y2 = y2New;

       // update simTime = simulation time elapsed
       simParams.updateSimTime();
       // IF WANT TO MOVE THIS OUTSIDE REPEAT THEN simParams.simTime IN BOUNDARY AT face
       // DOES NOT CHANGE SO HAVE TO FIX THAT

    } // END NEW FOR REPEAT for (i=0; i<simParams.stepRepeats; i+=1)

    // HANDLE PROFILE PLOT DATA

    // copy y values to profileData array which holds data for plotting

    // XXX CONSIDER RE-ORDERING LAST TWO INDEXES IN profileData SO CAN USE
    //     SIMPLE ASSIGNMENT FOR ALL Y VALUES, e.g.,
    // profileData[0][1][k] = y;

    for (k=0; k<=this.numNodes; k+=1) {
      profileData[0][k][1] = y[k];
      profileData[1][k][1] = y2[k];
      // update arrays for coverage and rate
      // note that these values are computed above in repeat to get reactant and
      // product gas conc but no need to update coverage and rate arrays inside repeat
      // since this sim assumes pseudo-SS between reactant gas and coverage
      profileData[2][k][1] = this.Kads * y[k] / (1 + this.Kads * y[k]); // coverage
      profileData[3][k][1] = this.Kads * y[k] / Math.pow( (1 + this.Kads * y[k]), this.model); // rate, this.model should be 1 or 2
    }

    // HANDLE SPACE-TIME DATA

    // spaceTimeData[v][t][s] - variable, time, space (profile in layer)
    // get 2D array for one variable at a time
    v = 0; // first variable = rate
    tempArray = spaceTimeData[v];
    // get rate profile data, variable 3 in profileData array
    for (k = 0; k <= this.numNodes; k += 1) {
      spaceData[k] = profileData[3][k][1]; // use rate computed above
    }

    // // TRY UNSUCCESSFULLY TO USE shift & push to update spaceTimeData array
    // // shift & push worked OK on 1D arrays for strip charts
    // // delete first and oldest element which is a layer profile
    // tempArray.shift();
    // // add the new layer profile at end
    // tempArray.push(spaceData);

    /*
    BUT SHIFT & PUSH DO NOT WORK
    spaceData is changing with time as expected
    trouble is that all of spaceTimeData is getting "filled" with
    same copy of the time varying spaceData instead of just one strip
    getting added to end...
    strips are getting deleted and new strips added to end
    but looks like all non-zero strips are getting filled with current
    spaceData...
    */

    // use repeats to update the spaceTimeData array
    for (t = 0; t < numStripPoints; t += 1) { // NOTE < numStripPoints, don't do last one here
      // numStripPoints defined in process_plot_info.js
      for (s = 0; s <= this.numNodes; s +=1) { // NOTE <= this.numNodes
        tempArray[t][s] = tempArray[t+1][s];
      }
    }
    // now update the last time
    for (s = 0; s <= this.numNodes; s +=1) { // NOTE <= this.numNodes
      tempArray[numStripPoints][s] = spaceData[s];
      // numStripPoints defined in process_plot_info.js
    }
    // update the variable being processed
    spaceTimeData[v] = tempArray;

    // HANDLE STRIP CHART DATA

    // XXX see if can make actions below for strip chart into general function

    // copy gas in and out data to stripData array
    // update plotData with new data

    // handle cin - feed of reactant gas to mixing cell
    v = 0;
    tempArray = stripData[v]; // work on one plot variable at a time
    // delete first and oldest element which is an [x,y] pair array
    tempArray.shift();
    // add the new [x.y] pair array at end
    tempArray.push( [ 0, cinNew ] );
    // update the variable being processed
    stripData[v] = tempArray;

    // handle ca - reactant in mixing cell gas
    v = 1;
    tempArray = stripData[v]; // work on one plot variable at a time
    // delete first and oldest element which is an [x,y] pair array
    tempArray.shift();
    // add the new [x.y] pair array at end
    tempArray.push( [ 0, caNew ] );
    // update the variable being processed
    stripData[v] = tempArray;

    // handle cb - product gas in mixing cell gas
    v = 2;
    tempArray = stripData[v]; // work on one plot variable at a time
    // delete first and oldest element which is an [x,y] pair array
    tempArray.shift();
    // add the new [x.y] pair array at end
    // don't scale cbNew here or then gets fed back into calc above
    // need to add a scale factor when plotting variable
    tempArray.push( [ 0, cbNew ] );
    // update the variable being processed
    stripData[v] = tempArray;

    // // recording flowRate and diffRate below are for development
    // // WARNING: if want to use this then need to dimension stripData to hold them
    // //          when initialize stripData in process_plot_info.js
    //
    // // handle flowRate - gas in mixing cell gas
    // v = 3;
    // tempArray = stripData[v]; // work on one plot variable at a time
    // // delete first and oldest element which is an [x,y] pair array
    // tempArray.shift();
    // // add the new [x.y] pair array at end
    // // don't scale cbNew here or then gets fed back into calc above
    // // need to add a scale factor when plotting variable
    // tempArray.push( [ 0, flowRate ] );
    // // update the variable being processed
    // stripData[v] = tempArray;
    //
    // // handle diffRate - gas in mixing cell gas
    // v = 4;
    // tempArray = stripData[v]; // work on one plot variable at a time
    // // delete first and oldest element which is an [x,y] pair array
    // tempArray.shift();
    // // add the new [x.y] pair array at end
    // // don't scale cbNew here or then gets fed back into calc above
    // // need to add a scale factor when plotting variable
    // tempArray.push( [ 0, diffRate ] );
    // // update the variable being processed
    // stripData[v] = tempArray;

    // re-number the x-axis values to equal time values
    // so they stay the same after updating y-axis values
    var timeStep = simParams.dt * simParams.stepRepeats;
    for (v = 0; v < numStripVars; v += 1) {
      // numStripVars defined in process_plot_info.js
      for (p = 0; p <= numStripPoints; p += 1) { // note = in p <= numStripPoints
        // numStripPoints defined in process_plot_info.js
        // note want p <= pnumStripPoints so get # 0 to  # numStripPoints of points
        // want next line for newest data at max time
        // stripData[v][p][0] = p * timeStep;
        // want next line for newest data at zero time
        stripData[v][p][0] = (numStripPoints - p) * timeStep;
      }
    }

  }, // end updateState method

  display : function() {
    document.getElementById("field_aveRate_1237").innerHTML = this.aveRate.toExponential(3);
    document.getElementById("field_aveConversion_1238").innerHTML = this.aveConversion.toFixed(4);
    // document.getElementById("dev01").innerHTML = "aveRate = " + this.aveRate;
    // document.getElementById("dev00").innerHTML = "sim time = " + simParams.simTime.toFixed(0);
    // document.getElementById("dev00").innerHTML = "B scale = " + this.Bscale;
    // // WARNING: to use info for flowRate and diffRate below
    // //          need to activate code above that saves that data
    // var tempArray = [];
    // var p = 0; // index
    // var numStripPoints = plotsObj[2]['numberPoints'];
    // for (p = 0; p <= numStripPoints; p += 1) {
    //   tempArray[p] = stripData[0][p][1];
    // }
    // document.getElementById("dev01").innerHTML = "cin = " + tempArray;
    // for (p = 0; p <= numStripPoints; p += 1) {
    //   tempArray[p] = stripData[1][p][1];
    // }
    // document.getElementById("dev02").innerHTML = "ca = " + tempArray;
    // for (p = 0; p <= numStripPoints; p += 1) {
    //   tempArray[p] = stripData[3][p][1];
    // }
    // document.getElementById("dev03").innerHTML = "flowRate = " + tempArray;
    // for (p = 0; p <= numStripPoints; p += 1) {
    //   tempArray[p] = stripData[4][p][1];
    // }
    // document.getElementById("dev04").innerHTML = "diffRate = " + tempArray;
}

}; // END var puCatalystLayer
