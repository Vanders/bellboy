# encoding: utf-8
#
# Copyright 2014 Dyn Inc.
#
# Authors: Kristian Van Der Vliet <kvandervliet@dyn.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'bellboy'
require 'databag_version'

module Bellboy
  # Process any data bag templates into versioned data bag items
  class Versioner
    class << self
      def version(berksfile, options = {})
        local_sources = Bellboy.berks_sources(berksfile)

        local_sources.each do |source|
          Bellboy.logger.debug "Source: #{source.path}"

          DatabagVersion.process_all(options[:verbose], "#{source.path}/data_bags") if
            Dir.exists?("#{source.path}/data_bags")
        end
      end
    end
  end
end
