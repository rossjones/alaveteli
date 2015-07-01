require 'singleton'

class DatabaseCollation
    include Singleton

    MINIMUM_POSTGRES_VERSION = 90112

    def self.supports?(locale)
        instance.supports?(locale)
    end

    attr_reader :connection

    def initialize
        @connection = ActiveRecord::Base.connection
    end

    def supports?(locale)
        exist? && supported_collations.include?(locale)
    end

    private

    def exist?
        postgres? && postgres_version >= MINIMUM_POSTGRES_VERSION
    end

    def postgres?
        adapter_name == 'PostgreSQL'
    end

    def postgres_version
        @postgres_version ||= connection.send(:postgresql_version) if postgres?
    end

    def supported_collations
        connection.
            execute(%(SELECT * FROM pg_collation;)).
                map { |row| row['collname'] }
    end

    def adapter_name
        @adapter_name ||= connection.adapter_name
    end
end
