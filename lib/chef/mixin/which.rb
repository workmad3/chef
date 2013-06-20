#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  module Mixin
    module Which

      # Acts like a shell 'which' command in ruby.
      #
      # === Parameters
      # command<String>:: the command to search the PATH for
      #
      # === Returns
      # path<String> or nil
      def which(command)

        # Windows fills PATHEXT with things like ".COM", ".EXE", ".BAT", etc
        extlist = ENV['PATHEXT'].split(';')) if ENV['PATHEXT']
        commandlist = extlist ? extlist.map { |e| "#{command}#{e}" } : [ command ]
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |dir|
          commandpaths = commandlist.map { |cmd| File.join(dir, cmd) }
          commandpaths.each do |path|
            return path if File.executable? path
          end
        end
        nil
      end

    end
  end
end
