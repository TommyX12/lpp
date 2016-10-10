

function print(msg) {
    console.log(msg);
}


function parseDate(str){
    var timeInfo = [];
    var i;
    var buffer = "";
    for (i = 0; i <= str.length; i++){
        var c = str.charAt(i);
        if (c >= '0' && c <= '9') {
            buffer += c;
        } else {
            if (buffer.length > 0) timeInfo.push(parseInt(buffer));
            buffer = "";
        }
    }
    
    if (timeInfo.length != 5) return NaN;
    
    return Date.UTC(timeInfo[0], timeInfo[1]-1, timeInfo[2], timeInfo[3], timeInfo[4], 0);
}

function hsl(r, g, b) {
    
    //http://www.easyrgb.com/index.php?X=MATH&H=18#text18
    
    var var_Min = Math.min( r, g, b )    //Min. value of RGB
    var var_Max = Math.max( r, g, b )    //Max. value of RGB
    var del_Max = var_Max - var_Min             //Delta RGB value
    
    var L = ( var_Max + var_Min ) / 2
    var H = 0.0, S = 0.0
    
    if ( del_Max == 0 )                     //This is a gray, no chroma...
    {
       H = 0                                //HSL results from 0 to 1
       S = 0
    }
    else                                    //Chromatic data...
    {
       if ( L < 0.5 ) S = del_Max / ( var_Max + var_Min )
       else           S = del_Max / ( 2 - var_Max - var_Min )
    
       var del_R = ( ( ( var_Max - r ) / 6 ) + ( del_Max / 2 ) ) / del_Max
       var del_G = ( ( ( var_Max - g ) / 6 ) + ( del_Max / 2 ) ) / del_Max
       var del_B = ( ( ( var_Max - b ) / 6 ) + ( del_Max / 2 ) ) / del_Max
    
       if      ( r == var_Max ) H = del_B - del_G
       else if ( g == var_Max ) H = ( 1 / 3 ) + del_R - del_B
       else if ( b == var_Max ) H = ( 2 / 3 ) + del_G - del_R
    
       if ( H < 0 ) H += 1
       if ( H > 1 ) H -= 1
    }
    
    return {h: H, s: S, l: L};
}

function luma(r, g, b){
    return 0.299 * r + 0.587 * g + 0.114 * b;
}

function clamp(x, min, max){
    return Math.min(Math.max(x, min), max);
}

function map(x, inMin, inMax, outMin, outMax, clampIn){
    if (clampIn === true) x = clamp(x, inMin, inMax);
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

function getRepeatTxt(instance){
    if (instance == null) return "";
    if (instance.repeatMode == "none") return qsTr("[No Repeat]");
    var outStr = "";
    if (instance.repeatMode == "days") outStr = qsTr("Every %1 Days");
    else if (instance.repeatMode == "months") outStr = qsTr("Every %1 Months");
    else if (instance.repeatMode == "years") outStr = qsTr("Every %1 Years");
    outStr = "[" + outStr.arg(instance.repeatParam) + "]";
    
    if (instance.isForever()){
        return outStr;
    }
    else {
        return outStr + " [" + qsTr("Until: ") + Engine.timeToString(instance.repeatUntil) + "]";
    }
}
