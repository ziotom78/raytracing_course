import * as THREE from 'three';

//////////////////////////////////////////////////////////////////////
// Main

var scene = new THREE.Scene();

// Camera
var camera = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 1000);
var renderer = new THREE.WebGLRenderer();
renderer.setClearColor(new THREE.Color(0xaaaaaa));
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Lights
var spotLight = new THREE.PointLight(0xffffff, /*intensity*/ 1.0, /*distance*/ 0.0, /*decay*/ 0.0);
spotLight.position.set(-2, 3, 5);
scene.add(spotLight);

// Meshes
var cubeGeometry = new THREE.BoxGeometry(1, 1, 1);
var material1 = new THREE.MeshLambertMaterial({color: 0xff0000});
var material2 = new THREE.MeshLambertMaterial({color: 0x00ff00});
var interp_material = new THREE.MeshLambertMaterial({color: 0xffff00});
var cube1 = new THREE.Mesh(cubeGeometry, material1);
var cube2 = new THREE.Mesh(cubeGeometry, material2);
var interp_cube = new THREE.Mesh(cubeGeometry, interp_material);

scene.add(cube1);
scene.add(cube2);
scene.add(interp_cube);

cube1.position.x = -2;
cube2.position.x = +2;
interp_cube.position.x = -1.5;

camera.position.z = 5;

var controls = new function() {
    this.cube1rotX = 0.0;
    this.cube1rotY = 0.0;
    this.cube1rotZ = 0.0;

    this.cube2rotX = 0.7;
    this.cube2rotY = -0.4;
    this.cube2rotZ = 0.2;

    this.slerp = 0.5;
}

var gui = new dat.GUI();
gui.add(controls, 'cube1rotX', -Math.PI / 4, Math.PI / 4);
gui.add(controls, 'cube1rotY', -Math.PI / 4, Math.PI / 4);
gui.add(controls, 'cube1rotZ', -Math.PI / 4, Math.PI / 4);
gui.add(controls, 'cube2rotX', -Math.PI / 4, Math.PI / 4);
gui.add(controls, 'cube2rotY', -Math.PI / 4, Math.PI / 4);
gui.add(controls, 'cube2rotZ', -Math.PI / 4, Math.PI / 4);
gui.add(controls, 'slerp', 0, 1);

var quatFromObj = function(obj) {
    var quat = new THREE.Quaternion();
    quat.setFromEuler(new THREE.Euler(obj.rotation.x, obj.rotation.y, obj.rotation.z, 'XYZ'));
    return quat;
}

var animate = function () {
    requestAnimationFrame(animate);

    cube1.rotation.x = controls.cube1rotX;
    cube1.rotation.y = controls.cube1rotY;
    cube1.rotation.z = controls.cube1rotZ;

    cube2.rotation.x = controls.cube2rotX;
    cube2.rotation.y = controls.cube2rotY;
    cube2.rotation.z = controls.cube2rotZ;

    interp_cube.position.x = cube1.position.x + (cube2.position.x - cube1.position.x) * controls.slerp;

    var q1 = quatFromObj(cube1);
    var q2 = quatFromObj(cube2);
    var interp_q = q1.slerp(q2, controls.slerp);

    var interpEuler = new THREE.Euler();
    interpEuler.setFromQuaternion(interp_q, 'XYZ');
    interp_cube.rotation.x = interpEuler.x;
    interp_cube.rotation.y = interpEuler.y;
    interp_cube.rotation.z = interpEuler.z;

    renderer.render(scene, camera);
};

animate();
