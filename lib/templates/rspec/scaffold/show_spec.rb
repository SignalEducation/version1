<%- list_of_associations = [] -%>
require 'rails_helper'

RSpec.describe '<%= table_name -%>/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    <%- attributes.map(&:name).each do |attr_name| -%>
    <%- if attr_name[-3..-1] == '_id' -%><%- list_of_associations << attr_name -%>
    @<%= attr_name[0..-4] -%> = FactoryGirl.create(:<%= attr_name[0..-4] -%>)
    <%- end -%>
    <%- end -%>
    @<%= singular_table_name -%> = FactoryGirl.create(:<%= singular_table_name %><%= list_of_associations.map {|a| ', ' + a + ': @' + a[0..-4] + '.id' }.join('') -%>)
  end

  it 'renders attributes' do
    render
    <%- attributes.each do |attr| -%>
    <%- if attr.type.to_s == 'boolean' -%>
    expect(rendered).to match(/nice_boolean/)
    <%- elsif attr.type.to_s == 'datetime' -%>
    expect(rendered).to match(/#{@<%= singular_table_name %>.<%= attr.name %>.to_s(:standard)}/)
    <%- elsif attr.name[-3..-1] == '_id' -%>
    expect(rendered).to match(/#{@<%= singular_table_name %>.<%= attr.name[0..-4] %>.name}/)
    <%- else -%>
    expect(rendered).to match(/#{@<%= singular_table_name %>.<%= attr.name %>}/)
    <%- end -%>
    <%- end -%>
  end
end
