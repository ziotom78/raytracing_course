/* Shamelessy taken from https://codepen.io/erucipe/pen/gpBgpR */

var barycentricCanvas = document.getElementById("barycentric-coordinates-canvas");

barycentricCanvasWidth = barycentricCanvas.width;
barycentricCanvasHeight = barycentricCanvas.height;

barycentricCanvas.className = 'touchable';

barycentricContext = barycentricCanvas.getContext("2d");

var touched = false;
var selectedPoint = null;

var lerp = function(a, b, t) {
    return a + (b - a) * t;
};

var vec2 = {};
vec2.add = function(a, b) {
    return [ a[0] + b[0], a[1] + b[1] ];
};
vec2.sub = function(a, b) {
    return [ a[0] - b[0], a[1] - b[1] ];
};
vec2.scale = function(v, k) {
    return [ v[0] * k, v[1] * k ];
};
vec2.length = function(v) {
    return Math.sqrt(v[0]*v[0] + v[1]*v[1]);
};
vec2.distance = function(a, b) {
    var dx = b[0] - a[0];
    var dy = b[1] - a[1];
    return Math.sqrt(dx*dx + dy*dy);
};
vec2.dot = function(a, b) {
    return a[0]*b[0] + a[1]*b[1];
};
vec2.normalize = function(v) {
    var d = Math.sqrt(v[0]*v[0] + v[1]*v[1]);
    return d > 0 ? [ v[0] / d, v[1] / d ] : v;
};
vec2.area = function(a, b) {
    return a[0]*b[1] - b[0]*a[1];
};
vec2.angle = function(a, b) {
    return Math.acos(vec2.dot(a, b) / (vec2.length(a) * vec2.length(b)));
};

var barycentric = function(tri, p) {
    var v0 = vec2.sub(tri[1], tri[0]);
    var v1 = vec2.sub(tri[2], tri[0]);
    var v2 = vec2.sub(p, tri[0]);
    var d00 = vec2.dot(v0, v0);
    var d01 = vec2.dot(v0, v1);
    var d11 = vec2.dot(v1, v1);
    var d20 = vec2.dot(v2, v0);
    var d21 = vec2.dot(v2, v1);
    var denom = d00 * d11 - d01 * d01;
    var v = (d11 * d20 - d01 * d21) / denom;
    var w = (d00 * d21 - d01 * d20) / denom;
    var u = 1 - v - w;
    return [u, v, w];
};

var tri = [
    [barycentricCanvasWidth * 0.5, barycentricCanvasHeight * 0.25],
    [barycentricCanvasWidth * 0.25, barycentricCanvasHeight * 0.75],
    [barycentricCanvasWidth * 0.75, barycentricCanvasHeight * 0.75]
];

var bary_point = [barycentricCanvasWidth * 0.5, barycentricCanvasHeight * 0.5];

var tri_point_names = ['A', 'B', 'C'];
var tri_colors = [ [1, 0, 0], [0, 1, 0], [0, 0, 1] ];

var getColorString = function(c, a) {
    var r = Math.floor(c[0] * 255);
    var g = Math.floor(c[1] * 255);
    var b = Math.floor(c[2] * 255);
    return 'rgba(' + r + ',' + g + ',' + b + ',' + a + ')';
};

var drawTriangle = function(tri) {
    var pa = tri[0], pb = tri[1], pc = tri[2];
    barycentricContext.beginPath();
    barycentricContext.moveTo(pa[0], pa[1]);
    barycentricContext.lineTo(pb[0], pb[1]);
    barycentricContext.lineTo(pc[0], pc[1]);
    barycentricContext.closePath();
};

var getNearestPoint = function(p, pts) {
    var min_d = Number.MAX_VALUE, d = 0;
    var res = null;
    for(var i = 0; i < pts.length; i++) {
        var pt = pts[i];
        d = vec2.distance(p, pt);
        if(d < min_d) {
            min_d = d;
            res = pt;
        }
    }
    return { 'point': res, 'distance': min_d };
};

var update = function() {
};

var draw = function() {
    barycentricContext.font = "20px Georgia";
    
    barycentricContext.clearRect(0, 0, barycentricCanvasWidth, barycentricCanvasHeight);
    
    var bary_coords = barycentric(tri, bary_point);
    
    barycentricContext.strokeStyle = 'rgba(0, 0, 0, 1)';
    barycentricContext.lineWidth = 2;
    drawTriangle(tri);
    barycentricContext.stroke();
    barycentricContext.lineWidth = 1;
    
    if(bary_coords[0] >= 0 && bary_coords[1] >= 0 && bary_coords[2] >= 0) {
        barycentricContext.fillStyle = getColorString([1, 0, 0], 0.1);
        drawTriangle([bary_point, tri[1], tri[2]]);
        barycentricContext.fill();

        barycentricContext.fillStyle = getColorString([0, 1, 0], 0.1);
        drawTriangle([bary_point, tri[0], tri[2]]);
        barycentricContext.fill();

        barycentricContext.fillStyle = getColorString([0, 0, 1], 0.1);
        drawTriangle([bary_point, tri[0], tri[1]]);
        barycentricContext.fill();
    }
    
    var a = tri[0], b = tri[1], c = tri[2];    
    
    var ab = vec2.sub(b, a);
    var bc = vec2.sub(c, b);
    var ca = vec2.sub(a, c);
    var ac = vec2.sub(c, a);
    var area = vec2.area(ab, ac);
    
    var d_ab = vec2.length(ab);
    var to_ab = bary_coords[2] * area / d_ab;
    var r_ab = vec2.scale(vec2.normalize([ab[1], -ab[0]]), to_ab);
    
    var d_bc = vec2.length(bc);
    var to_bc = bary_coords[0] * area / d_bc;
    var r_bc = vec2.scale(vec2.normalize([bc[1], -bc[0]]), to_bc);
    
    var d_ca = vec2.length(ca);
    var to_ca = bary_coords[1] * area / d_ca;
    var r_ca = vec2.scale(vec2.normalize([ca[1], -ca[0]]), to_ca);
    
    barycentricContext.strokeStyle = 'rgba(0, 0, 0, 0.25)';
    barycentricContext.beginPath();
    barycentricContext.moveTo(bary_point[0], bary_point[1]);
    barycentricContext.lineTo(bary_point[0] + r_ab[0], bary_point[1] + r_ab[1]);
    barycentricContext.moveTo(bary_point[0], bary_point[1]);
    barycentricContext.lineTo(bary_point[0] + r_bc[0], bary_point[1] + r_bc[1]);
    barycentricContext.moveTo(bary_point[0], bary_point[1]);
    barycentricContext.lineTo(bary_point[0] + r_ca[0], bary_point[1] + r_ca[1]);
    barycentricContext.stroke();
    
    var ext = Math.max(barycentricCanvasWidth, barycentricCanvasHeight) * 2;
    barycentricContext.beginPath();
    barycentricContext.moveTo(a[0], a[1]);
    barycentricContext.lineTo(a[0] - ab[0] * ext, a[1] - ab[1] * ext);
    barycentricContext.moveTo(a[0], a[1]);
    barycentricContext.lineTo(a[0] + ca[0] * ext, a[1] + ca[1] * ext);
    barycentricContext.moveTo(b[0], b[1]);
    barycentricContext.lineTo(b[0] + ab[0] * ext, b[1] + ab[1] * ext);
    barycentricContext.moveTo(b[0], b[1]);
    barycentricContext.lineTo(b[0] - bc[0] * ext, b[1] - bc[1] * ext);
    barycentricContext.moveTo(c[0], c[1]);
    barycentricContext.lineTo(c[0] - ca[0] * ext, c[1] - ca[1] * ext);
    barycentricContext.moveTo(c[0], c[1]);
    barycentricContext.lineTo(c[0] + bc[0] * ext, c[1] + bc[1] * ext);
    barycentricContext.stroke();
    
    barycentricContext.strokeStyle = 'rgba(0, 0, 0, 0.5)';
    for(var i = 0; i < tri.length; i++) {
        var p = tri[i];
        barycentricContext.beginPath();
        barycentricContext.arc(p[0], p[1], 5, 0, Math.PI * 2);
        barycentricContext.fillStyle = getColorString(tri_colors[i], 1);
        barycentricContext.fill();
        barycentricContext.stroke();
    }
    
    barycentricContext.fillStyle = getColorString(bary_coords, 1);
    barycentricContext.beginPath();
    barycentricContext.arc(bary_point[0], bary_point[1], 5, 0, Math.PI * 2);
    barycentricContext.fill();
    barycentricContext.stroke();
    
    barycentricContext.fillStyle = 'black';
    for(var i = 0; i < tri_point_names.length; i++) {
        var p = tri[i];
        var name = tri_point_names[i];
        barycentricContext.fillText(name, p[0] + 8, p[1]);
    }
    
    var bary_string = bary_coords.map(function(item) { return item.toFixed(2); }).join(', ');
    
    barycentricContext.fillText(bary_string, bary_point[0] + 8, bary_point[1]);
};

var getTouchCoord = function(e) {
    var p = [0, 0];
    if(e.targetTouches) {
        p[0] = e.targetTouches[0].offsetX;
        p[1] = e.targetTouches[0].offsetY;
    }
    else {
        p[0] = e.offsetX;
        p[1] = e.offsetY;
    }
    return p;
};

var touchstart = function(e) {
    if(e.target.className === 'touchable') {
        e.preventDefault();
        var p = getTouchCoord(e);
        touched = true;
        
        var tp = getNearestPoint(p, tri);
        if(tp.distance < 10) {
            selectedPoint = tp.point;
            barycentricCanvas.style.cursor = 'pointer';
        }
        else {
            bary_point[0] = p[0];
            bary_point[1] = p[1];
        }
    }
};

var touchend = function(e) {
    if(e.target.className === 'touchable') {
        e.preventDefault();
        touched = false;
        selectedPoint = null;
        barycentricCanvas.style.cursor = 'crosshair';
    }
};

var touchmove = function(e) {
    if(e.target.className === 'touchable') {
        e.preventDefault();
        var p = getTouchCoord(e);
        if(touched) {
            if(selectedPoint) {
                selectedPoint[0] = p[0];
                selectedPoint[1] = p[1];
            }
        }
        else {
            var tp = getNearestPoint(p, tri);
            if(tp.distance < 10) {
                barycentricCanvas.style.cursor = 'pointer';
            }
            else {
                barycentricCanvas.style.cursor = 'crosshair';
            }
        }
    }
};

barycentricCanvas.addEventListener('mousedown', touchstart, false);
barycentricCanvas.addEventListener('mouseup', touchend, false);
barycentricCanvas.addEventListener('mousemove', touchmove, false);
barycentricCanvas.addEventListener('touchstart', touchstart, false);
barycentricCanvas.addEventListener('touchend', touchend, false);
barycentricCanvas.addEventListener('touchmove', touchmove, false);

var loop = function() {
    update();
    draw();
    requestAnimationFrame(loop);
};

document.addEventListener('barycentric-coordinates-demo', function() {
    loop();
});
