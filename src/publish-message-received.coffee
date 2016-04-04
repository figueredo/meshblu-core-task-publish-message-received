_ = require 'lodash'
http = require 'http'

class PublishMessage
  constructor: (options={}) ->
    {@cache,@uuidAliasResolver} = options

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {toUuid, messageType, messageRoute} = request.metadata
    if _.some(messageRoute, type: 'message.received')
      return @_doCallback request, 204, callback

    message = request.rawData
    @_send {toUuid, messageType, message}, (error) =>
      return callback error if error?
      return @_doCallback request, 204, callback

  _send: ({toUuid, messageType, message}, callback=->) =>
    @uuidAliasResolver.resolve toUuid, (error, uuid) =>
      return callback error if error?
      @cache.publish "#{uuid}", message, callback

module.exports = PublishMessage
