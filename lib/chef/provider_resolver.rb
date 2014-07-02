#
# Author:: Richard Manyanza (<liseki@nyikacraftsmen.com>)
# Copyright:: Copyright (c) 2014 Richard Manyanza.
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

require 'chef/provider_collection'

class Chef
  class ProviderResolver

    attr_reader :node

    def initialize(node)
      @provider_collection = Chef::ProviderCollection.new()
      @node = node
    end

    def resolve(resource, action)
      @provider_collection.sort {|a,b| a.to_s <=> b.to_s }.each do |klass|
        if klass.enabled?(node) && klass.implements?(resource) && klass.handles?(resource, action)
          provider = klass.new(resource, resource.run_context)
          provider.action = action
          return provider
        end
      end
      nil
    end
  end
end
