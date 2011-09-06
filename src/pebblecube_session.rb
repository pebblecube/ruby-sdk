#!/usr/bin/env ruby
#
# Copyright 2011 Pebblecube
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
module Pebblecube
  class PebblecubeSession
    attr_accessor :api, :session_id, :started_at, :elapsed_time, :stopped_at
  
    def initialize(pebble = nil)
      @api = pebble
    end
  
    def start(params = nil)
      result = @api.request("/sessions/start", "GET", nil)
      if result
        @session_id = result["k"]
        @started_at = result["t"]
      else
        raise pebblecube.PebblecubeException "invalid session"
      end
    end
    
    def stop(params = nil)
      result = @api.request("/sessions/stop", "GET", { "session_key" => @session_id })
      if result
        @elapsedTime = result["t"]
        @stoppped_at = @stopped_at + @elapsed_time
      else
        raise pebblecube.PebblecubeException "session not started"
      end
    end
    
  end
end