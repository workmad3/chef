

class Chef
  class ProviderCollection
    include Enumerable

    # This got stripped down from an implementation which turned Chef::Provider into an
    # enumerable collection, but which would have held onto class variables pointing at
    # providers -- suffering from global state issues and probably leaking LWRPs and
    # other sharp edges with LWRPs and running with intervals.
    #
    # It pretty useless as a stand alone object now, but iterating through ObjectSpace and
    # the class heirarchy is a bit ugly.  If left like this, I'd slurp it into
    # Chef::ProviderResolver, otherwise we could wire it up so that providers registered
    # and deregistered into this collection.
    def each
      ObjectSpace.each_object(Class) do |klass|
        yield klass if klass < Chef::Provider
      end
    end
  end
end
