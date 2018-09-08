const gulp = require('gulp');
const elm = require('gulp-elm');
const nodemon = require('gulp-nodemon');
const runSequence = require('run-sequence');
const browserSync = require('browser-sync').create();


/// ELM

gulp.task('elm-init', elm.init);
gulp.task('elm', ['elm-init'], () => {
    return gulp
        .src(['elm/**/*.elm'])
        .pipe(elm.bundle('app.js', {debug: true}))
            .on('error', console.log)
        .pipe(gulp.dest('static/js/'));
});

gulp.task('elm-watch', ['elm'], () => {
    browserSync.reload();
});

/// START 
let serverStarted = false;
let streamOpts =
    { script: 'index.js'
    , env: { 'NODE_ENV': 'development'}
    };

gulp.task('start', cb => {
    return nodemon(streamOpts)
        .on('start', () => {
            if (!serverStarted) {
                console.log('Server started...');
                serverStarted = true;
                cb();
            }
        })
        .on('restart', () => {
            console.log('Server restarted...');
        });
});

/// WATCH

gulp.task('watch', () => {
    gulp.watch(['elm/**/*.elm'], ['elm-watch']);
});

/// DEFAULT

gulp.task('default', () => {
    process.env.NODE_ENV = 'development';

    // Serve files from the root of this project
    browserSync.init({
        open: false
        , port: 6401
        , browser: 'google chrome'
        , files: 'views/**/*.pug'
        , proxy: {
            target: 'localhost:6400'
        }
        , ui: {
            port: 6402
        }
    });

    runSequence('watch', 'start');
});
