require File.dirname(__FILE__) + '/test_helper'

module FriendlyId
  module Test
    module ActiveRecord2

      class CustomTableNameTest < ::Test::Unit::TestCase

        include FriendlyId::Test::Generic
        include FriendlyId::Test::Slugged
        include FriendlyId::Test::ActiveRecord2::Slugged
        include FriendlyId::Test::ActiveRecord2::Core

        def klass
          Place
        end

      end

    end
  end
end
