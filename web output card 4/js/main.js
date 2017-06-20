// window.onload = openThisLab;
//
// function openThisLab() {
// alert("enter function openThisLab");
// }

function fHandleScrollbar01() {
  let tmpFunc = new Function("return range_Scrollbar01.value;");
  var tValue = tmpFunc();
  document.getElementById("field_Label01").innerHTML = tValue;
}

function fHandleScrollbar02() {
  let tmpFunc = new Function("return range_Scrollbar02.value;");
  var tValue = tmpFunc();
  document.getElementById("field_Label02").innerHTML = tValue;
}

function fHandleScrollbar03() {
  let tmpFunc = new Function("return range_Scrollbar03.value;");
  var tValue = tmpFunc();
  document.getElementById("field_Label03").innerHTML = tValue;
}

function fHandleScrollbar04() {
  let tmpFunc = new Function("return range_Scrollbar04.value;");
  var tValue = tmpFunc();
  document.getElementById("field_Label04").innerHTML = tValue;
}
