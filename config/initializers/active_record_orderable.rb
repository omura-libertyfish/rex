concern :ActiveRecordOrderable do
  class_methods do
    def has_order(method_name, columns:)
      define_method method_name do
        values = columns.map{|column| __send__(column)}
        values.compact.sort!
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecordOrderable)
