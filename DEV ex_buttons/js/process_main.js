/*
  Design, text, images and code by Richard K. Herz, 2017
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// DECLARE GLOBAL VARIABLES
// in web labs, some may be declared as local variables in objects
var b1_clicks = 0;
var b2_clicks = 0;

// DISPLAY INITIAL STATE ON OPEN WINDOW
window.onload = openThisLab;

function openThisLab() {
  display_clicks();
} // END OF function openThisLab

function display_clicks() {
  document.getElementById("field_output_field").innerHTML =
  "button 1 has been clicked " + b1_clicks + " times <br>" +
  "button 2 has been clicked " + b2_clicks + " times";
}

function check_button_1() {
  b1_clicks += 1;
  display_clicks();
}

function check_button_2() {
  b2_clicks += 1;
  display_clicks();
}
