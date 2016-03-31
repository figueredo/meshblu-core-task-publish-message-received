_ = require 'lodash'
uuid = require 'uuid'
redis = require 'fakeredis'
MessageWebhook = require '../src/publish-message-received'

describe 'MessageReceived', ->
  beforeEach ->
    @redisKey = uuid.v1()
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    options = {
      cache: redis.createClient(@redisKey)
      @uuidAliasResolver
    }

    dependencies = {@request}

    @sut = new MessageWebhook options, dependencies
    @cache = redis.createClient @redisKey

  describe '->do', ->
    context 'when given a valid sent message', ->
      beforeEach (done) ->
        @cache.subscribe 'sender-uuid', (error) =>
          done error

      beforeEach ->
        @cache.once 'message', (channel, @message) =>

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
            auth:
              uuid: 'sender-uuid'
              token: 'sender-token'
            toUuid: 'sender-uuid'
            fromUuid: 'sender-uuid'
            messageType: 'sent'
          rawData: '{"devices":"*"}'

        @sut.do request, (error, @response) => done error

      it 'should return a 204', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse

      it 'should publish the message to redis', (done) ->
        _.delay =>
          expect(@message).to.deep.equal '{"devices":"*"}'
          done()
        , 100

    context 'when given a valid broadcast message', ->
      beforeEach (done) ->
        @cache.subscribe 'sender-uuid', (error) =>
          done error

      beforeEach ->
        @cache.once 'message', (channel, @message) =>

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
            auth:
              uuid: 'sender-uuid'
              token: 'sender-token'
            toUuid: 'sender-uuid'
            fromUuid: 'sender-uuid'
            messageType: 'broadcast'
          rawData: '{"devices":"*"}'

        @sut.do request, (error, @response) => done error

      it 'should return a 204', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse

      it 'should publish the message to redis', (done) ->
        _.delay =>
          expect(@message).to.deep.equal '{"devices":"*"}'
          done()
        , 100

    context 'when given a valid received message', ->
      beforeEach (done) ->
        @cache.subscribe 'receiver-uuid', (error) =>
          done error

      beforeEach ->
        @cache.once 'message', (channel, @message) =>

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
            auth:
              uuid: 'sender-uuid'
              token: 'sender-token'
            toUuid: 'receiver-uuid'
            fromUuid: 'sender-uuid'
            messageType: 'received'
          rawData: '{"devices":"*"}'

        @sut.do request, (error, @response) => done error

      it 'should return a 204', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse

      it 'should publish the message to redis', (done) ->
        _.delay =>
          expect(@message).to.deep.equal '{"devices":"*"}'
          done()
        , 100
