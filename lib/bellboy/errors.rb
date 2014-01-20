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

# Exceptions that are specific to Bellboy
module Bellboy
  # Base class for all internal Bellboy errors
  class BellboyError < StandardError
  end

  # Base for all Read/Write/Create errors
  class BellboyIOError < BellboyError
    def initialize(filepath)
      @filepath = File.dirname(File.expand_path(filepath)) rescue filepath
    end
  end

  # Couldn't create or write to a new data bag item
  class DatabagWriteError < BellboyIOError
    def to_s
      "IO error writing to #{@filepath}"
    end
  end

  # Couldn't read from a manifest
  class DatabagReadError < BellboyIOError
    def to_s
      "IO error reading from #{@filepath}"
    end
  end

  # Base for all API errors
  class BellboyAPIError < BellboyError
    def initialize(location)
      @location = location
    end
  end

  # An error occured during a Chef API call
  class ChefConnectionError < BellboyAPIError
  end

  # An error occured during a Bellboy API call
  class DatabagAPIError < BellboyAPIError
    def to_s
      "Databag API call failed for #{@location}"
    end
  end

  # Invalid configuration file path
  class ConfigNotFound < BellboyError
    def initialize(configpath)
      @configpath = configpath
    end

    def to_s
      "Config file #{@configpath} does not exist"
    end
  end
end
