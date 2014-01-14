# encoding: utf-8
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'busboy'

describe 'versioner' do
  before (:each) do
    @berksfile = Busboy.berks_from_file('/dev/null')
  end

  it 'should not throw any exceptions' do
    Busboy::Versioner.version(@berksfile)
  end
end
