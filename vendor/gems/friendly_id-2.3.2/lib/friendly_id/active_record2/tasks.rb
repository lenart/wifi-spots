module FriendlyId
  class TaskRunner

    attr_accessor :days
    attr_accessor :klass
    attr_accessor :task_options

    OLD_SLUG_DAYS = 45

    def initialize(&block)
      self.klass = ENV["MODEL"]
      self.days  = ENV["DAYS"]
    end

    def method_missing(*args)
      klass.send(*args)
    end

    def days=(days)
      @days = days.blank? ? OLD_SLUG_DAYS : days.to_i
    end

    def klass=(klass)
      @klass = klass.to_s.classify.constantize unless klass.blank?
    end

    def make_slugs
      validate_uses_slugs
      options = {:limit => 100, :include => :slugs, :conditions => "slugs.id IS NULL"}.merge(task_options || {})
      while records = find(:all, options) do
        break if records.size == 0
        records.each do |record|
          record.save!
          yield(record) if block_given?
        end
      end
    end

    def delete_slugs
      validate_uses_slugs
      Slug.destroy_all(["sluggable_type = ?", klass.to_s])
      if column = friendly_id_config.cache_column
        update_all("#{column} = NULL")
      end
    end

    def delete_old_slugs
      conditions = ["created_at < ?", DateTime.now - days.days]
      if klass
        conditions[0] << " AND sluggable_type = ?"
        conditions << klass.to_s
      end
      Slug.all(:conditions => conditions).select(&:outdated?).map(&:destroy)
    end

    def validate_uses_slugs
      unless friendly_id_config.use_slug?
        raise "Class '%s' doesn't use slugs" % klass.to_s
      end
    rescue NoMethodError
      raise "Class '%s' doesn't use FriendlyId" % klass.to_s
    end

  end

end