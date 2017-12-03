/*
  Design, text, images and code by Richard K. Herz, 2017
  Copyrights held by Richard K. Herz
  Licensed for use under the GNU General Public License v3.0
  https://www.gnu.org/licenses/gpl-3.0.en.html
*/

// DISPLAY INITIAL STATE ON OPEN WINDOW
window.onload = check_checkboxes;

function check_checkboxes() {

  var el1 = document.querySelector('#checkbox_Check_1');
  var el2 = document.querySelector('#checkbox_Check_2');

  if (el1.checked && el2.checked) {
    document.getElementById("field_output_field").innerHTML = "checkboxes 1 & 2 are checked";
  }

  if (el1.checked && !el2.checked) {
    document.getElementById("field_output_field").innerHTML = "checkbox 1 is checked";
  }

  if (!el1.checked && el2.checked) {
    document.getElementById("field_output_field").innerHTML = "checkbox 2 is checked";
  }

  if (!el1.checked && !el2.checked) {
    document.getElementById("field_output_field").innerHTML = "neither checkbox is checked";
  }

}
