
/*
  Design, text, images and code by Richard K. Herz, 2017-2018
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// uses object simParams from file process_units.js

// this file contains common simulation functions
// see file process_units.js for simulation parameter values and
// definitions of the process units

  // DISPLAY INITIAL STATE ON OPEN WINDOW
  window.onload = openThisLab; // can NOT use = openThisLab();

  function openThisLab() {
    var resetFlag = 1; // 0 for no reset, 1 for reset lab
    updateProcessUnits(resetFlag);
    updateDisplay(resetFlag);
    simParams.updateRunCount();
  } // END OF function openThisLab

  function runSimulation() {

    // CALLED BY function runThisLab ON CLICK OF RUN-PAUSE BUTTON

    // HERE, THE INTEGRATION TIME STEP SIZE MUST BE CONSTANT WITHIN ONE DISPLAY
    // INTERVAL TO MAINTAIN CORRESPONDENCE BETWEEN SIM TIME AND REAL TIME
    // FOR A DIFFERENT CASE WHERE THE INTEGRATION TIME STEP SIZE CAN VARY
    // BETWEEN updateProcessUnits YOU NEED
    // THE MORE COMPLEX TIMING METHOD USED IN dynamic-process-v2.livecode

    var resetFlag = 0; // 0 for no reset, 1 for reset lab
    // updateDisplayTimingMs is real time milliseconds between display updates
    var updateDisplayTimingMs = simParams.updateDisplayTimingMs;
    var startDate = new Date(); // need this here
    var startMs;
    var currentMs;
    var elapsedMs;
    // updateMs is computed below in function updateProcess to be real time
    // between finish last display update and start next update process
    var updateMs = 0; // initialize as zero for first call immediately below

    // first call to updateProcess, which then calls itself
    // use setTimeout, since updateProcess by itself does not work
    setTimeout(updateProcess, updateMs);

    function updateProcess() {

      var runningFlag = simParams.runningFlag;
      if (!runningFlag) {
        // exit if runningFlag is not true
        // runningFlag can become not true by click of RUN-PAUSE or RESET buttons
        return;
      }

      // get time at start of repeating updateProcessUnits
      startDate = new Date(); // need this here
      startMs = startDate.getTime();

      // repeating updateProcessUnits must finish before
      // latest real time at which updateDisplay must occur in order
      // to maintain correspondence between sim time and real time
      //
      var i;
      for (i = 0; i < simParams.simStepRepeats; i += 1) {
        updateProcessUnits(resetFlag);
      }

      // update simTime = simulation time elapsed
      simParams.updateSimTime();

      // get time at end of repeating updateProcessUnits and call
      // to updateDisplay from updateDisplay function return value
      currentMs = updateDisplay(resetFlag);

      // Adjust wait until next updateProcess to allow for time taken
      // to do updateProcessUnits and updateDisplay.
      // In order to respond to user input, do not need updateMs > 0.
      // BUT DO NEED updateMs > 0 to keep sync between sim time and real time.
      elapsedMs = currentMs - startMs;
      updateMs = updateDisplayTimingMs - elapsedMs;

      // // DISPLAY TIMING DATA DURING DEVELOPMENT - PERCENT TIME IDLE
      // var tIdleTime = 100*(1-elapsedMs/updateMs);
      // tIdleTime = Number(tIdleTime).toPrecision(2);
      // document.getElementById("dev01").innerHTML = "% idle = " + tIdleTime + "&nbsp;&nbsp;";
      // document.getElementById("dev01").innerHTML = "elapsedMs = " + elapsedMs + "&nbsp;&nbsp;";

      // END updateProcess WITH CALL TO ITSELF AFTER updateMs WAIT
      setTimeout(updateProcess, updateMs);  // updateMs

    } // END OF function updateProcess (inside function runSimulation)

  } // END OF function runSimulation

  function updateProcessUnits(resetFlag) {
    // DO COMPUTATIONS TO UPDATE STATE OF PROCESS
    // step all units but do not display

    var unitList = simParams.processUnits;
    var tmpFunc = new Function();

    // FIRST, have all units update their input connection values
    unitList.forEach(fUpdateInputs);
    function fUpdateInputs(unitName) {
      tmpFunc = new Function(unitName + ".updateInputs();");
      tmpFunc();
    }

    // SECOND, have all units update their state
    unitList.forEach(fUpdateState);
    function fUpdateState(unitName) {

      if (resetFlag) {
        tmpFunc = new Function(unitName + ".reset();");
        tmpFunc();
      }

      tmpFunc = new Function(unitName + ".updateState();");
      tmpFunc();
    }

  } // END OF updateProcessUnits

  function updateDisplay(resetFlag) {

    var unitList = simParams.processUnits;
    // display all units but do not step
    unitList.forEach(fDisplay);
    function fDisplay(unitName) {
      if (resetFlag) {
        var tmpFunc = new Function(unitName + ".reset();");
        tmpFunc();
      }
        var tmpFunc = new Function(unitName + ".display();");
        tmpFunc();
    }

    // GET AND PLOT ALL PLOTS defined in plotsObj in process_plot_info
    // plots are specified in object plotsObj in file process_plot_info.js
    var npl = Object.keys(plotsObj).length; // number of plots
    var p; // used as index
    var data;
    for (p = 0; p < npl; p += 1) {
      data = getPlotData(p);
      plotPlotData(data,p);
    }

    // // NEW - plot space-time plots, if any - NEW
    // plotSpaceTimePlot();

    // RETURN REAL TIME OF THIS DISPLAY UPDATE (milliseconds)
    var thisDate = new Date();
    var thisMs = thisDate.getTime();
    return thisMs;

  }  // END OF function updateDisplay

  function updateUIparams() {
    // Update user-entered inputs from UI to ALL units.
    // Could be called from onclick or onchange in HTML element, if desired.
    // Alternative: in HTML input tag onchange, send unitName.updateUIparams()
    // to method updateUIparams of specific unit involved in that input.

    var unitList = simParams.processUnits;

    unitList.forEach(fUpdateUIparams);
    function fUpdateUIparams(unitName) {
      var tmpFunc = new Function(unitName + ".updateUIparams();");
      tmpFunc();
    }

  }  // END OF function updateUIparams
