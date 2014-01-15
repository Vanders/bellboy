# encoding: utf-8
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'bellboy'

describe 'uploader' do
  before (:each) do
    @berksfile = Bellboy.berks_from_file('/dev/null')
  end

  it 'should not throw any exceptions' do
    Bellboy::Uploader.upload(@berksfile)
  end
end
