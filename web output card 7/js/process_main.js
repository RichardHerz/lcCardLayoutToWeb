/*
  Design, text, images and code by Richard K. Herz, 2017
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// DISPLAY INITIAL STATE ON OPEN WINDOW
window.onload = check_radio_buttons;

function check_radio_buttons() {

  var el1 = document.querySelector('#radio_Radio_button_1');
  var el2 = document.querySelector('#radio_Radio_button_2');

  if (el1.checked && el2.checked) {
    document.getElementById("field_output_field").innerHTML = "buttons 1 & 2 are checked";
  }

  if (el1.checked && !el2.checked) {
    document.getElementById("field_output_field").innerHTML = "button 1 is checked";
  }

  if (!el1.checked && el2.checked) {
    document.getElementById("field_output_field").innerHTML = "button 2 is checked";
  }

  if (!el1.checked && !el2.checked) {
    document.getElementById("field_output_field").innerHTML = "neither button is checked";
  }

}
