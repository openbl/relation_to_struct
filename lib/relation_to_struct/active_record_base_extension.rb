module RelationToStruct::ActiveRecordBaseExtension
  extend ::ActiveSupport::Concern

  module ClassMethods
    def structs_from_sql(struct_class, sql, binds=[])
      result = connection.select_all(sanitize_sql(sql, nil), "Structs SQL Load", binds)

      if result.columns.size != result.columns.uniq.size
        raise ArgumentError, 'Expected column names to be unique'
      end

      if result.columns != struct_class.members.collect(&:to_s)
        raise ArgumentError, 'Expected column names (and their order) to match struct attribute names'
      end

      if result.columns.size == 1
        result.cast_values().map do |tuple|
          struct_class.new(tuple)
        end
      else
        result.cast_values().map do |tuple|
          struct_class.new(*tuple)
        end
      end
    end

    def pluck_from_sql(sql, binds=[])
      result = connection.select_all(sanitize_sql(sql, nil), "Pluck SQL Load", binds)
      result.cast_values()
    end
  end

  if ActiveRecord.version >= Gem::Version.new("5.0.0.rc1")
    included do
      class << self
        def sanitize_sql_with_ignored_table_name(condition, table_name = nil)
          sanitize_sql_without_ignored_table_name(condition)
        end
        alias_method_chain :sanitize_sql, :ignored_table_name
      end
    end
  end
end

::ActiveRecord::Base.send(:include, RelationToStruct::ActiveRecordBaseExtension)
