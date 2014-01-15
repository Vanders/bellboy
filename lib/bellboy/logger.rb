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

module Bellboy
  LOG_LEVEL_NONE = 0
  LOG_LEVEL_INFO = 1
  LOG_LEVEL_DEBUG = 2

  # Simple stdout logger
  class Logger
    def initialize(options = {})
      @loglevel = level(options)
    end

    # Output a normal informational message
    def log(message)
      puts(message) unless @loglevel < Bellboy::LOG_LEVEL_INFO
    end

    # Output a debug message
    def debug(message)
      puts(message) unless @loglevel < Bellboy::LOG_LEVEL_DEBUG
    end
    alias_method :verbose, :debug

    private

    def level(options)
      if options[:quiet]
        Bellboy::LOG_LEVEL_NONE
      elsif options[:verbose]
        Bellboy::LOG_LEVEL_DEBUG
      else
        Bellboy::LOG_LEVEL_INFO
      end
    end
  end
end
