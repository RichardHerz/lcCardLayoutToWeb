function copyData(){

	var tText; // we will put the data into this variable

  tText = '<p>Copy and paste these data into a text file for loading into your analysis program.</p>';
  tText += '<p>time (s), reactant conc (mol/m<sup>3</sup>), reactor T (K), jacket inlet T (K), jacket T (K)</>'

  // gConcData, gTTempData, gJacketTTempDataINLET, gJacketTTempData
  // values must be numbers for .toFixed(2) to work, use Number() conversion
  // when getting values from input fields

  tText += '<p>';

  var k;
  var tItemDelimiter = ', &nbsp;'
  for (k = 1; k <= gNumberPlotPoints; k++){
    tText += gConcData[k][0].toFixed(2) + tItemDelimiter + // [k][0] is time
             gConcData[k][1].toFixed(2) + tItemDelimiter +
             gTTempData[k][1].toFixed(2) + tItemDelimiter +
             gJacketTTempDataINLET[k][1].toFixed(2) + tItemDelimiter +
             gJacketTTempData[k][1].toFixed(2) +
             '<br>' // use <br> not <p> or get empty line between each row
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