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

  let(:platform) { "ubuntu" }

  let(:platform_family) { "debian" }

  let(:node) do
    node = Chef::Node.new
    node.automatic_attrs[:platform] = platform
    node.automatic_attrs[:platform_family] = platform_family
    node.automatic_attrs[:platform_version] = "14.04"
    node
  end

  let(:provider_resolver) { Chef::ProviderResolver.new(node) }

  let(:events) { Chef::EventDispatch::Dispatcher.new }

  let(:run_context) { Chef::RunContext.new(node, {}, events) }

  let(:resource) { Chef::Resource::Service.new("ntp", run_context) }

  let(:action) { :start }

  let(:resolved_provider) { provider_resolver.resolve(resource, action) }

  it "does a thing" do
    allow(File).to receive(:exist?).with("/etc/init").and_return(true)
    allow(File).to receive(:exist?).with("/etc/init.d/ntp").and_return(true)
    allow(File).to receive(:exist?).with("/etc/init/ntp.conf").and_return(false)
    expect(resolved_provider).to be_a(Chef::Provider::Service::Debian)
  end

  it "does a thing" do
    allow(File).to receive(:exist?).with("/etc/init").and_return(true)
    allow(File).to receive(:exist?).with("/etc/init.d/ntp").and_return(true)
    allow(File).to receive(:exist?).with("/etc/init/ntp.conf").and_return(true)
    expect(resolved_provider).to be_a(Chef::Provider::Service::Upstart)
  end

  it "does a thing" do
    allow(File).to receive(:exist?).with("/etc/init").and_return(true)
    allow(File).to receive(:exist?).with("/etc/init.d/ntp").and_return(false)
    allow(File).to receive(:exist?).with("/etc/init/ntp.conf").and_return(true)
    expect(resolved_provider).to be_a(Chef::Provider::Service::Upstart)
  end
end
