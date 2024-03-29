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
$: << File.join(File.dirname(__FILE__), "..", 'src')
require 'pebblecube'

key = "YOUR_KEY"
secret = "YOUR_SECRET"

pebble = Pebblecube::PebblecubeApi.new(key, secret, "192")

pebble.session.start()
puts "session_id: #{pebble.session.session_id}"
puts "started_at: #{pebble.session.started_at}"

#pebble.session.stop()
#puts pebble.session.stopped_at
#puts pebble.session.elapsed_time