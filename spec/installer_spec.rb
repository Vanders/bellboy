# encoding: utf-8
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'bellboy'

describe 'installer' do
  include UsesTempFiles

  context "with non-empty Berksfile" do

    in_directory_with_file('Berksfile')

    before (:each) do
      content_for_file("source 'http://example.com'")
      @berksfile = Bellboy.berks_from_file('Berksfile')
    end

    it 'should not throw any exceptions' do
      Bellboy::Installer.install(@berksfile, {:bellboyfile => '/dev/null'})
    end

  end
end
