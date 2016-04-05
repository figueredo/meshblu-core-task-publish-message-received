_ = require 'lodash'
uuid = require 'uuid'
redis = require 'fakeredis'
PublishMessageReceived = require '..'

describe 'MessageReceived', ->
  beforeEach ->
    @redisKey = uuid.v1()
    @uuidAliasResolver = resolve: sinon.stub().yields null, 'receiver-uuid'
    options = {
      cache: redis.createClient(@redisKey)
      @uuidAliasResolver
    }

    dependencies = {@request}

    @sut = new PublishMessageReceived options, dependencies
    @cache = redis.createClient @redisKey

  describe '->do', ->
    context 'when given a valid message', ->
      beforeEach (done) ->
        @cache.subscribe 'receiver-uuid', (error) => done error

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
          rawData: '{"does_not": "matter"}'

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
          expect(@message).to.deep.equal '{"does_not": "matter"}'
          done()
        , 100

    context 'when given a valid message with an alias', ->
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
            toUuid: 'muggle-mouth'
            fromUuid: 'sender-uuid'
            messageType: 'sent'
          rawData: '{"does_not": "matter"}'
        @uuidAliasResolver.resolve.yields null, 'receiver-uuid'
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
          expect(@message).to.deep.equal '{"does_not": "matter"}'
          done()
        , 100
