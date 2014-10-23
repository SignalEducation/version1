require 'rails_helper'

RSpec.describe '<%= table_name -%>/edit', type: :view do
  before(:each) do
    <%- attributes.map(&:name).each do |attr_name| -%>
    <%- if attr_name[-3..-1] == '_id' -%>
    x = FactoryGirl.create(:<%= attr_name[0..-4] -%>)
    @<%= attr_name[0..-4].pluralize -%> = <%= attr_name[0..-4].camelcase -%>.all
    <%- end -%>
    <%- end -%>
    @<%= singular_table_name -%> = FactoryGirl.create(:<%= singular_table_name %>)
  end

  it 'renders new <%= singular_table_name -%> form' do
    render
    assert_select 'form[action=?][method=?]', <%= singular_table_name -%>_path(id: @<%= singular_table_name -%>.id), 'post' do
      <%- attributes.each do |attr| -%>
      <%- if attr.name[-3..-1] == '_id'-%>
      assert_select 'select#<%= singular_table_name -%>_<%= attr.name -%>[name=?]', '<%= singular_table_name -%>[<%= attr.name -%>]'
      <%- elsif attr.type.to_s == 'text' -%>
      assert_select 'textarea#<%= singular_table_name -%>_<%= attr.name -%>[name=?]', '<%= singular_table_name -%>[<%= attr.name -%>]'
      <%- else -%>
      assert_select 'input#<%= singular_table_name -%>_<%= attr.name -%>[name=?]', '<%= singular_table_name -%>[<%= attr.name -%>]'
      <%- end -%>
      <%- end -%>
    end
  end
end
