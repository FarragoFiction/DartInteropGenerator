var objects = [];//function() { return this; }();

for(var b in window) {
  //if(window.hasOwnProperty(b)) {
    objects.push(b);
  //}
}

console.log(objects);
console.log(window.Boolean);