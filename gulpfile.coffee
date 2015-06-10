bower        = require 'gulp-bower'
bump         = require 'gulp-bump'
clean        = require 'gulp-clean'
coffee       = require 'gulp-coffee'
concat       = require 'gulp-concat'
connect      = require 'connect'
declare      = require 'gulp-declare'
del          = require 'del'
fs           = require 'fs'
git          = require 'gulp-git'
gulp         = require 'gulp'
gutil        = require 'gulp-util'
http         = require 'http'
jade         = require 'gulp-jade'
livereload   = require 'gulp-livereload'
minifyCss    = require 'gulp-minify-css'
minifyHtml   = require 'gulp-minify-html'
open         = require "gulp-open"
plumber      = require 'gulp-plumber'
rev          = require 'gulp-rev'
rimraf       = require 'rimraf'
sass         = require 'gulp-sass'
shadow       = require 'gulp-shadow-library'
uglify       = require 'gulp-uglify'
usemin       = require 'gulp-usemin'
watch        = require 'gulp-watch'
wrap         = require 'gulp-wrap'

# Paths to source files

jadeStagePath     = 'stage/stage.jade'
cssStagePath      = 'stage/stage.scss'
coffeeStagePath   = 'stage/**/*.coffee'
svgPath           = 'app/assets/compiled/*.svg'

parseSVG = ->
  gulp.src svgPath
    .pipe shadow {cssDest:'./css/', jsDest:'./js/'}
    .pipe gulp.dest('./server/')

htmlStage = (cb)->
  gulp.src jadeStagePath
    .pipe jade()
    .pipe gulp.dest('./server/')
    .on('end', cb)

cssStage = (cb)->
  # Stage css - not included in build
  gulp.src( cssStagePath )
    .pipe sass({errLogToConsole: true})
    .pipe gulp.dest('./server/stage/css')
    .on('end', cb)

jsStage = (cb)->
  gulp.src coffeeStagePath
    .pipe plumber()
    .pipe coffee( bare: true ).on('error', gutil.log).on( 'error', gutil.beep )
    .pipe concat('init.js')
    .pipe gulp.dest('server/stage/js')
    .on('end', cb)

copyBowerLibs = ()->
  bower().pipe gulp.dest('./server/bower-libs/')

copyFilesToBuild = ->
  gulp.src( './server/js/*' ).pipe gulp.dest('./rel/')
  gulp.src( './server/css/main.css' ).pipe gulp.dest('./rel/')

pushViaGit = ->
  # Start out by reading the version number for commit msg, then git push, etc..
  fs.readFile './bower.json', 'utf8', (err, data) =>
    regex   = /version"\s*:\s*"(.+)"/
    version = data.match(regex)[1]
    gulp.src('./')
      .pipe git.add()
      .pipe git.commit("BUILD - #{version}")
      # .pipe git.push 'origin', 'master', (err)=> console.log( err)

bumpBowerVersion = ->
  gulp.src('./bower.json')
    .pipe bump( {type:'patch'} )
    .pipe(gulp.dest('./'));

minifyAndJoin = () ->
  gulp.src './server/stage.html'
    .pipe usemin
      css : [ minifyCss(), 'concat'],
      html: [ minifyHtml({empty: true})],
      js  : [ uglify(), rev()]
    .pipe(gulp.dest('rel/'));

copyJsAndCss = () ->
  gulp.src(['./server/css/*.css', './server/js/*.js'])
    .pipe gulp.dest('./rel/')


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Livereload Server
server = ->
  port      = 3591
  hostname  = null # allow to connect from anywhere
  base      = 'server'
  directory = 'server'
  app = connect()
    .use( connect.static(base) )
    .use( connect.directory(directory) )

  http.createServer(app).listen port, hostname

# Open in the browser
launch = ->
  gulp.src("./stage/stage.jade") # An actual file must be specified or gulp will overlook the task.
    .pipe(open("",
      url: "http://0.0.0.0:3591/stage.html",
      app: "google chrome"
    ))

# Livereload Server
watchAndCompileFiles = (cb)->
  count = 0
  onComplete = ()=> if ++count == 3 then cb()

  watch { glob:coffeeStagePath },  -> jsStage(onComplete).pipe    livereload()
  watch { glob:cssStagePath    },  -> cssStage(onComplete).pipe   livereload()
  watch { glob:jadeStagePath   },  -> htmlStage(onComplete).pipe  livereload()
  watch { glob:svgPath         },  -> parseSVG(onComplete).pipe   livereload()


# ----------- BUILD (rel) ----------- #

gulp.task 'rel:clean',                (cb)      -> rimraf('./rel', cb); console.log "!! IMPORTANT !! If you haven't already, make sure you run 'gulp' before 'gulp rel'"
gulp.task 'bumpVersion',              ()        -> bumpBowerVersion()
gulp.task 'copyFiles', ['rel:clean'], ()        -> copyJsAndCss()
gulp.task 'rel', [ 'bumpVersion', 'copyFiles'], -> pushViaGit()


  # ----------- MAIN ----------- #

gulp.task 'clean',                  (cb) -> rimraf './server/*', cb
gulp.task 'bowerLibs', ['clean'],   ()   -> copyBowerLibs()
gulp.task 'compile', ['bowerLibs'], (cb) -> watchAndCompileFiles(cb)
gulp.task 'server', ['compile'],    (cb) -> server(); launch();
gulp.task 'default', ['server']
