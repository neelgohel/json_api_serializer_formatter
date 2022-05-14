module FastJsonapi
  module ObjectSerializer
    def hash_for_one_record
      serializable_hash = { data: nil }
      serializable_hash[:meta] = @meta if @meta.present?
      serializable_hash[:links] = @links if @links.present?

      return serializable_hash unless @resource

      serializable_hash[:data] = self.class.record_hash(@resource, @fieldsets[self.class.record_type.to_sym], @includes, @params)
      serializable_hash[:included] = self.class.get_included_records(@resource, @includes, @known_included_objects, @fieldsets, @params) if @includes.present?
      @included = serializable_hash.dig(:included)

      relationships = serializable_hash.dig(:data, :relationships)
      attrs = serializable_hash.dig(:data, :attributes)
      @includes.map(&:to_s).each do |relation_tree|
        fill_attribute_data(attrs, relationships, relation_tree.split('.'))
      end if @includes.present?
      attrs
    end

    def hash_for_collection
      serializable_hash = {}

      data = []
      included = []
      fieldset = @fieldsets[self.class.record_type.to_sym]
      @resource.each do |record|
        data << self.class.record_hash(record, fieldset, @includes, @params)
        included.concat self.class.get_included_records(record, @includes, @known_included_objects, @fieldsets, @params) if @includes.present?
      end

      serializable_hash[:data] = data
      serializable_hash[:included] = included if @includes.present?
      serializable_hash[:meta] = @meta if @meta.present?
      serializable_hash[:links] = @links if @links.present?
      @included = serializable_hash.dig(:included)
      serializable_hash[:data].map do |sh|
        relationships = sh.dig(:relationships)
        attrs = sh.dig(:attributes)
        @includes.map(&:to_s).each do |relation_tree|
          fill_attribute_data(attrs, relationships, relation_tree.split('.'))
        end if @includes.present?
        attrs
      end
    end

    def fill_attribute_data(attrs, relationships, remaining_relation_tree)
      key = remaining_relation_tree.first
      return if key.blank? || relationships.blank?

      data = relationships.dig(key.to_sym, :data)

      if data.is_a?(Array)
        attrs[key.to_sym] = [] if attrs[key.to_sym].blank?
        data.each do |record_data|
          relation_tree = Array.new(remaining_relation_tree)
          record = @included.select { |x| x[:id] == record_data[:id] && x[:type] == record_data[:type] }.first
          next if record.blank?

          new_attrs = record[:attributes].clone
          present_attrs = attrs[key.to_sym].select { |r| new_attrs[:id] == r[:id] }.first
          if present_attrs.present?
            new_attrs = present_attrs
          else
            attrs[key.to_sym] << new_attrs
          end
          relation_tree.shift
          fill_attribute_data(new_attrs, record[:relationships], relation_tree)
        end
      else
        attrs[key.to_sym] = nil if attrs[key.to_sym].blank?
        return if data.nil?

        record = @included.select { |p| data && p[:type] == data[:type] && p[:id] == data[:id] }.first || @included.select { |p| p[:type] == key.to_sym }.first || {}
        if record.present?
          if attrs[key.to_sym].blank?
            new_attrs = record[:attributes].clone
          else
            new_attrs = attrs[key.to_sym]
          end
          attrs[key.to_sym] = new_attrs
          remaining_relation_tree.shift
          fill_attribute_data(new_attrs, record[:relationships], remaining_relation_tree)
        end
      end
    end
  end
end
