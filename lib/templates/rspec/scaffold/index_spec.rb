<%- list_of_associations = [] -%>
require 'rails_helper'

RSpec.describe '<%= table_name -%>/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    <%- attributes.map(&:name).each do |attr_name| -%>
    <%- if attr_name[-3..-1] == '_id' -%><%- list_of_associations << attr_name -%>
    @<%= attr_name[0..-4] -%> = FactoryGirl.create(:<%= attr_name[0..-4] -%>)
    <%- end -%>
    <%- end -%>
    temp_<%= table_name -%> = FactoryGirl.create_list(:<%= singular_table_name %>, 2<%= list_of_associations.map { |a| ', ' + a + ': @' + a.gsub('_id','.id') }.join('') -%>)
    @<%= table_name %> = <%= singular_table_name.camelcase -%>.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of <%= table_name -%>' do
    render
    <%- attributes.each do |attr| -%>
    <%- if attr.type.to_s == 'boolean' -%>
    expect(rendered).to match(/nice_boolean/)
    <%- elsif attr.type.to_s == 'datetime' -%>
    expect(rendered).to match(/#{@<%= table_name %>.first.<%= attr.name -%>.strftime(t('controllers.application.date_formats.standard'))}/)
    <%- else -%>
    expect(rendered).to match(/#{@<%= table_name %>.first.<%= attr.name.gsub('_id','.name') %>.to_s}/)
    <%- end -%>
    <%- end -%>
  end
end
