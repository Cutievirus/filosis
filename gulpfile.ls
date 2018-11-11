require! {
	\gulp
	\gulp-concat :concat
	\gulp-livescript :livescript
	\gulp-rename :rename
	\gulp-util :gutil
}

gulp.task \watch [\build-game] ->
	gulp.watch "src/game.*.ls" [\build-game]

gulp.task \build-game ->
	gulp.src "src/game.*.ls"
	.pipe concat \DEBUG.ls new-line:'\r\n\r\n'
	.pipe gulp.dest "src/"
	.pipe livescript bare:true header:false
	.on \error ->
		gutil.log it.message
		gutil.beep!
		@emit \end
	.pipe rename "game.js"
	.pipe gulp.dest "play/"