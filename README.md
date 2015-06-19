![header](http://nano-assets.gopagoda.io/readme-headers/nanobox-dashboard-svg-lib.png)

## Installation
```
bower install nanobox-core/svgs-dashboard-nano --save
```

## Local Dependencies
```
rel/nanobox-dashboard.css
rel/nanobox-dashboard.js
```

![key](http://shots.delorum.com/client/view/Screen%20Shot%202015-06-01%20at%2010.47.26%20AM.png)


##Usage
```jade
img.shadow-icon( data-src="logo-horizontal" )
img.shadow-icon( data-src="xbtn" )
img.shadow-icon( data-src="small-add-btn" )
img.shadow-icon( data-src="add-btn" )
img.shadow-icon( data-src="engine-icon" )
img.shadow-icon( data-src="circle-add-btn" )
img.shadow-icon( data-src="search" )
img.shadow-icon( data-src="star" )
img.shadow-icon( data-src="check" )
img.shadow-icon( data-src="up-arrow" )
img.shadow-icon( data-src="down-arrow" )
img.shadow-icon( data-src="left-arrow" )
img.shadow-icon( data-src="right-arrow" )
img.shadow-icon( data-src="mail" )
```

This must be called after the page has loaded:
```coffeescript
shadowIcons = new pxicons.ShadowIcons()
# Pass in the jquery html element to search for .shadow-icon img tags.
shadowIconsInstance.svgReplaceWithString pxSvgIconString, $("body")
```
