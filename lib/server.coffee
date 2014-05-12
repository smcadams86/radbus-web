express = require 'express'
morgan = require 'morgan'
compress = require 'compression'
thisPackage = require '../package'

LOG_PREFIX = 'SERVER: ';

# create server
server = express()
server.set 'title', thisPackage.description
server.set 'appVersion', thisPackage.version

# configure logging
loggingFormat = "#{LOG_PREFIX}:remote-addr \":method :url HTTP/:http-version\" :status :res[content-length] request-id=:req[X-Request-ID] \":referrer\" \":user-agent\""
server.use morgan(loggingFormat)

# require HTTPS
server.use (req, res, next) ->
  hostPort = req.get('Host')
  host = /^(.+?)(:\d+)?$/.exec(hostPort)[1]
  isSecure = req.secure or (req.get('x-forwarded-proto') is 'https')
  isLocalhost = host is 'localhost'

  if not isSecure and not isLocalhost
    res.redirect 301, "https://#{hostPort}#{req.url}"

  else
    next()

# enable gzip compression
server.use compress()

module.exports = server
