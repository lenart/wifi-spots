# Fix for auto reloading ApplicationHelper
# https://github.com/josevalim/inherited_resources/pull/118
module InheritedResources
  class Base < ::ApplicationController
    def self.inherited(klass)
      super
      klass.helper :all if klass.superclass == InheritedResources::Base
    end
  end
end