#
# Author:: Lamont Granquist (<lamont@getchef.com>)
# Copyright:: Copyright (c) 2014 Opscode, Inc.
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

require 'spec_helper'

describe Chef::ProviderResolver do

  let(:node) do
    node = Chef::Node.new
    node.automatic_attrs[:platform] = platform
    node.automatic_attrs[:platform_family] = platform_family
    node.automatic_attrs[:platform_version] = platform_version
    node
  end

  let(:provider_resolver) { Chef::ProviderResolver.new(node) }

  let(:events) { Chef::EventDispatch::Dispatcher.new }

  let(:run_context) { Chef::RunContext.new(node, {}, events) }

  let(:resolved_provider) { provider_resolver.resolve(resource, action) }

  describe "resolving service resource" do

    let(:resource) { Chef::Resource::Service.new("ntp", run_context) }

    let(:action) { :start }

    describe "on Ubuntu 14.04" do
      let(:platform) { "ubuntu" }
      let(:platform_family) { "debian" }
      let(:platform_version) { "14.04" }

      before do
        allow(File).to receive(:exist?).with("/etc/init").and_return(true)
      end

      it "when only the SysV init script exists, it returns a Service::Debian provider" do
        allow(File).to receive(:exist?).with("/etc/init.d/ntp").and_return(true)
        allow(File).to receive(:exist?).with("/etc/init/ntp.conf").and_return(false)
        expect(provider_resolver).not_to receive(:maybe_chef_platform_lookup)
        expect(resolved_provider).to be_a(Chef::Provider::Service::Debian)
      end

      it "when both SysV and Upstart scripts exist, it returns a Service::Upstart provider" do
        allow(File).to receive(:exist?).with("/etc/init.d/ntp").and_return(true)
        allow(File).to receive(:exist?).with("/etc/init/ntp.conf").and_return(true)
        expect(provider_resolver).not_to receive(:maybe_chef_platform_lookup)
        expect(resolved_provider).to be_a(Chef::Provider::Service::Upstart)
      end

      it "when only the Upstart script exists, it returns a Service::Upstart provider" do
        allow(File).to receive(:exist?).with("/etc/init.d/ntp").and_return(false)
        allow(File).to receive(:exist?).with("/etc/init/ntp.conf").and_return(true)
        expect(provider_resolver).not_to receive(:maybe_chef_platform_lookup)
        expect(resolved_provider).to be_a(Chef::Provider::Service::Upstart)
      end

      it "when both do not exist, it calls the old style provider resolver and returns a Debian Provider" do
        allow(File).to receive(:exist?).with("/etc/init.d/ntp").and_return(false)
        allow(File).to receive(:exist?).with("/etc/init/ntp.conf").and_return(false)
        expect(provider_resolver).to receive(:maybe_chef_platform_lookup).with(resource, action).and_call_original
        expect(resolved_provider).to be_a(Chef::Provider::Service::Debian)
      end
    end
  end
end
