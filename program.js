// Write split function that gets a string and splits it based on a delimiter character

function split(str, delimiter) {
    var result = [];
    var temp = '';
    for (var i = 0; i < str.length; i++) {
        if (str[i] === delimiter) {
            result.push(temp);
            temp = '';
        } else {
            temp += str[i];
        }
    }
    result.push(temp);
    return result;
}

var str = 'a,b,c,d,e,f,g';
console.log(split(str, ',')); // ['a', 'b', 'c', 'd', 'e', 'f', 'g']
