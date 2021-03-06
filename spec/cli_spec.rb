# encoding: utf-8
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'bellboy'
require_relative 'spec-helpers'

describe 'cli' do
  include UsesTempFiles

  it 'should output help information if run with no arguments' do
    content = capture(:stdout) { Bellboy::Cli.start(%w[]) }
    expect(content).to match(/Commands:/)
  end
 
  it 'should output help information for the \'help\' command' do
    content = capture(:stdout) { Bellboy::Cli.start(%w[help]) }
    expect(content).to match(/Commands:/)
  end

  it 'should output help information for the \'version\' command' do
    content = capture(:stdout) { Bellboy::Cli.start(%w[help version]) }
    expect(content).to match(/Version all databag templates/)
  end

  it 'should output help information for the \'install\' command' do
    content = capture(:stdout) { Bellboy::Cli.start(%w[help install]) }
    expect(content).to match(/Install databags for all Cookbooks known by Berkshelf/)
  end

  it 'should output help information for the \'upload\' command' do
    content = capture(:stdout) { Bellboy::Cli.start(%w[help upload]) }
    expect(content).to match(/Upload all databags for all Cookbooks known by Berkshelf/)
  end

  it 'should fail to run with an invalid Berksfile' do
    content = capture(:stdout) { lambda{ Bellboy::Cli.start(%w[version -b /i/dont/exist]) }.should exit_with_code(0) }
    expect(content).to match(/could not be found/)
  end

  context "with non-empty Berksfile" do

    in_directory_with_file('Berksfile')

    before (:each) do
      content_for_file("source 'http://example.com'")
    end

    it 'should not fail to run the \'version\' command' do
      Bellboy::Cli.start(%w[version -b Berksfile])
    end

    it 'should not fail to run the \'install\' command' do
      Bellboy::Cli.start(%w[install -b Berksfile])
    end

    it 'should not fail to run the \'upload\' command' do
      Bellboy::Cli.start(%w[upload -b Berksfile])
    end

  end
end
