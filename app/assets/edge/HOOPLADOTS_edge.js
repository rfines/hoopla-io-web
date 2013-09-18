/**
 * Adobe Edge: symbol definitions
 */
(function($, Edge, compId){
//images folder
var im='/client/images/';

var fonts = {};


var resources = [
];
var symbols = {
"stage": {
   version: "2.0.1",
   minimumCompatibleVersion: "2.0.0",
   build: "2.0.1.268",
   baseState: "Base State",
   initialState: "Base State",
   gpuAccelerate: false,
   resizeInstances: false,
   content: {
         dom: [
         {
            id:'_3dots',
            type:'rect',
            rect:['173','95','auto','auto','auto','auto']
         }],
         symbolInstances: [
         {
            id:'_3dots',
            symbolName:'_3dots'
         }
         ]
      },
   states: {
      "Base State": {
         "${_Stage}": [
            ["color", "background-color", 'rgba(255,255,255,0.00)'],
            ["style", "width", '550px'],
            ["style", "height", '400px'],
            ["style", "overflow", 'hidden']
         ],
         "${__3dots}": [
            ["subproperty", "filter.grayscale", '0'],
            ["transform", "scaleY", '1'],
            ["transform", "rotateZ", '0deg'],
            ["transform", "scaleX", '1'],
            ["style", "left", '173px']
         ]
      }
   },
   timelines: {
      "Default Timeline": {
         fromState: "Base State",
         toState: "",
         duration: 2000,
         autoPlay: true,
         timeline: [
            { id: "eid15", tween: [ "transform", "${__3dots}", "scaleY", '0.70004', { fromValue: '1'}], position: 0, duration: 1000 },
            { id: "eid13", tween: [ "transform", "${__3dots}", "scaleY", '0.99889', { fromValue: '0.70004'}], position: 1000, duration: 1000 },
            { id: "eid6", tween: [ "style", "${__3dots}", "left", '173px', { fromValue: '173px'}], position: 0, duration: 0 },
            { id: "eid5", tween: [ "style", "${__3dots}", "left", '173px', { fromValue: '173px'}], position: 1000, duration: 0 },
            { id: "eid14", tween: [ "transform", "${__3dots}", "scaleX", '0.70004', { fromValue: '1'}], position: 0, duration: 1000 },
            { id: "eid12", tween: [ "transform", "${__3dots}", "scaleX", '0.99889', { fromValue: '0.70004'}], position: 1000, duration: 1000 },
            { id: "eid21", tween: [ "color", "${_Stage}", "background-color", 'rgba(255,255,255,0.00)', { animationColorSpace: 'RGB', valueTemplate: undefined, fromValue: 'rgba(255,255,255,0.00)'}], position: 2000, duration: 0 },
            { id: "eid8", tween: [ "transform", "${__3dots}", "rotateZ", '180deg', { fromValue: '0deg'}], position: 0, duration: 1000 },
            { id: "eid9", tween: [ "transform", "${__3dots}", "rotateZ", '360deg', { fromValue: '180deg'}], position: 1000, duration: 1000 },
            { id: "eid17", tween: [ "subproperty", "${__3dots}", "filter.grayscale", '1', { fromValue: '0'}], position: 0, duration: 1000 },
            { id: "eid18", tween: [ "subproperty", "${__3dots}", "filter.grayscale", '0', { fromValue: '1'}], position: 1000, duration: 1000 }         ]
      }
   }
},
"_3dots": {
   version: "2.0.1",
   minimumCompatibleVersion: "2.0.0",
   build: "2.0.1.268",
   baseState: "Base State",
   initialState: "Base State",
   gpuAccelerate: false,
   resizeInstances: false,
   content: {
   dom: [
   {
      rect: ['0px','61px','99px','99px','auto','auto'],
      borderRadius: ['50%','50%','50%','50%'],
      id: 'EllipseCopy',
      stroke: [0,'rgba(0,0,0,1)','none'],
      type: 'ellipse',
      fill: ['rgba(0,171,185,1.00)']
   },
   {
      rect: ['105px','0px','99px','99px','auto','auto'],
      borderRadius: ['50%','50%','50%','50%'],
      id: 'EllipseCopy2',
      stroke: [1,'rgba(0,0,0,1)','none'],
      type: 'ellipse',
      fill: ['rgba(61,63,66,1.00)']
   },
   {
      rect: ['99px','111px','99px','99px','auto','auto'],
      borderRadius: ['50%','50%','50%','50%'],
      transform: [],
      id: 'EllipseCopy3',
      stroke: [0,'rgba(0,0,0,1)','none'],
      type: 'ellipse',
      fill: ['rgba(182,216,0,1.00)']
   }],
   symbolInstances: [
   ]
   },
   states: {
      "Base State": {
         "${symbolSelector}": [
            ["style", "height", '210px'],
            ["style", "width", '204px']
         ],
         "${_EllipseCopy}": [
            ["color", "background-color", 'rgba(0,171,185,1.00)'],
            ["style", "left", '0px'],
            ["style", "top", '61px']
         ],
         "${_EllipseCopy2}": [
            ["color", "background-color", 'rgba(61,63,66,1.00)'],
            ["style", "border-width", '1px'],
            ["style", "border-style", 'none'],
            ["style", "left", '105px'],
            ["style", "top", '0px']
         ],
         "${_EllipseCopy3}": [
            ["style", "top", '111px'],
            ["style", "left", '99px'],
            ["color", "background-color", 'rgba(182,216,0,1.00)']
         ]
      }
   },
   timelines: {
      "Default Timeline": {
         fromState: "Base State",
         toState: "",
         duration: 0,
         autoPlay: true,
         timeline: [
         ]
      }
   }
}
};


Edge.registerCompositionDefn(compId, symbols, fonts, resources);

/**
 * Adobe Edge DOM Ready Event Handler
 */
$(window).ready(function() {
     Edge.launchComposition(compId);
});
})(jQuery, AdobeEdge, "hoopla_dots_loader");
