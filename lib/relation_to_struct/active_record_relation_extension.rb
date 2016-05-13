module RelationToStruct::ActiveRecordRelationExtension
  extend ::ActiveSupport::Concern

  def to_structs(struct_class)
    raise '' unless self.select_values.present?

    relation = spawn
    result = klass.connection.select_all(relation.arel, nil, relation.arel.bind_values + bind_values)

    if result.columns.size != struct_class.members.size
      raise ArgumentError, 'Expected struct fields and columns lengths to be equal'
    end

    if result.columns.size != result.columns.uniq.size
      raise ArgumentError, 'Expected column names to be unique'
    end

    attribute_types = ActiveRecord.version < Gem::Version.new("5.0.0.rc1") ? klass.column_types : klass.attribute_types
    result.cast_values(attribute_types)

    if result.columns.size == 1
      result.cast_values(attribute_types).map do |tuple|
        struct_class.new(tuple)
      end
    else
      result.cast_values(attribute_types).map do |tuple|
        struct_class.new(*tuple)
      end
    end
  end
end

::ActiveRecord::Relation.send(:include, RelationToStruct::ActiveRecordRelationExtension)
