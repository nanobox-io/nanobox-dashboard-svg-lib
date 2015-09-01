shadowIcons = new pxicons.ShadowIcons()
# shadowIcons.svgReplaceWithString pxSvgIconString, $("body")
# OPTION 1 :
# Use the javascript formatted string found in pagoda-svg-icons.js
console.time "Time Test"
shadowIconsInstance.svgReplaceWithString pxSvgIconString, $("body")
console.timeEnd "Time Test"
