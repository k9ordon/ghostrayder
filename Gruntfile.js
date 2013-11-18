module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        concat: {
            options: {
                separator: ';',
            },
            vendorJs: {
                src: [
                    'bower_components/jquery-mousewheel/jquery.mousewheel.js', 
                    'bower_components/Background-Check/background-check.js', 
                    'bower_components/jquery.hotkeys/jquery.hotkeys.js', 
                    'bower_components/color-thief/js/color-thief.js', 
                    'bower_components/jquery.columnizer/src/jquery.columnizer.js',
                    'bower_components/hammerjs/dist/jquery.hammer.js',
                    'bower_components/waitForImages/dist/jquery.waitForImages.js',
                    'bower_components/Blur.js/blur.js',
                    'bower_components/jquery.avgrund/jquery.avgrund.js'
                ],
                dest: 'assets/js/vendor.js'
            },
            vendorCss: {
                src: [
                    'bower_components/jquery.avgrund/style/avgrund.css' 
                ],
                dest: 'assets/css/vendor.css'
            }
        },

        sass: {
            app: {
                files: {
                    "assets/css/app.css": "src/sass/app.sass"
                }
            }
        },

        coffee: {
            app: {
                options: {
                    join: true,
                    sourceMap: true
                },
                files: {
                    'assets/js/app.js': [
                        'src/coffee/touch.coffee',
                        'src/coffee/mousewheel.coffee',
                        'src/coffee/keys.coffee',
                        'src/coffee/snapview.coffee',
                        'src/coffee/header.coffee',
                        'src/coffee/article.coffee',
                        'src/coffee/main.coffee',
                        'src/coffee/app.coffee'
                    ]
                }
            }
        },

        watch: {
            sys: {
                files: ['*'], 
                tasks: ['build']
            },
            sass: {
                files: ['src/sass/*.sass'],
                tasks: ['sass']
            },
            coffee: {
                files: ['src/coffee/*.coffee'],
                tasks: ['coffee']
            }
        },

        uglify: {
            options: {
                //mangle: false
            },
            dist: {
                files: {
                    'assets/js/vendor.js': ['assets/js/vendor.js']
                }
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-sass');
    grunt.loadNpmTasks('grunt-contrib-uglify');

    grunt.registerTask('build', ['sass', 'coffee', 'concat'/*, 'uglify'*/]);
    grunt.registerTask('default', 'build');
};