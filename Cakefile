cp = require('child_process')

task "dev", ->
  cp.spawn 'brunch', ['watch'], customFds: [0..2]
  cp.spawn 'nodemon', ['./app.coffee'], customFds: [0..2]
