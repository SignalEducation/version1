require 'rails_helper'

<% module_namespacing do -%>
describe <%= class_name %> do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  <%= class_name %>.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { <%= class_name %>.const_defined?(:CONSTANT_NAME) }

  # relationships
  <%- attributes.each do |attribute| -%>
  <%- if attribute.name[-3..-1] == '_id' -%>
  it { should belong_to(:<%= attribute.name.gsub('_id','') %>) }
  <%- end -%>
  <%- end -%>

  # validation
  <%- attributes.each do |attribute| -%>
  <%- if attribute.name[-3..-1] == '_id' -%>
  it { should validate_presence_of(:<%= attribute.name %>) }
  it { should validate_numericality_of(:<%= attribute.name %>) }

  <%- elsif attribute.type.to_s != 'boolean' -%>
  it { should validate_presence_of(:<%= attribute.name %>) }

  <%- end -%>
  <%- end -%>
  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(<%= class_name %>).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
<% end -%>
