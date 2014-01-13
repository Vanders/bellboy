# encoding: utf-8
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'busboy'

describe 'logger' do
  it 'should log to stdout' do
    logger = Busboy::Logger.new( {} )
    content = capture(:stdout) { logger.log 'test message #1' }
    expect(content).to eq("test message #1\n")
  end

  it 'should not log to stdout when \'quiet\' is enabled' do
    logger = Busboy::Logger.new( {:quiet => true} )
    content = capture(:stdout) { logger.log 'test message #2' }
    expect(content).to eq("")
  end

  it 'should not log debug messages to stdout' do
    logger = Busboy::Logger.new( {} )
    content = capture(:stdout) { logger.debug 'test message #3' }
    expect(content).to eq("")
  end

  it 'should log debug messages when \'verbose\' is enabled' do
    logger = Busboy::Logger.new( {:verbose => true} )
    content = capture(:stdout) { logger.debug 'test message #4' }
    expect(content).to eq("test message #4\n")
  end
end
